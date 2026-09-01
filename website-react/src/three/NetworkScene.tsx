import { useMemo, useRef } from 'react'
import { useFrame } from '@react-three/fiber'
import * as THREE from 'three'

/**
 * The visual language the whole hero rests on: two loose node clusters —
 * Creators (violet) on the left, Brands (blue) on the right — bridged by a
 * handful of connecting lines, with small particles travelling along those
 * bridges toward a single bright point at the centre. That point is the
 * literal visual answer to "Brands ↔ Creators ↔ Content ↔ Sales": every
 * connection this platform makes resolves into one outcome. Deliberately
 * abstract geometry only — no literal icons — per the brand's own request.
 */

interface NodeDef {
  position: THREE.Vector3
  scale: number
  side: 'creator' | 'brand'
  shape: 'ico' | 'octa'
}

function seededRandom(seed: number) {
  let s = seed
  return () => {
    s = (s * 9301 + 49297) % 233280
    return s / 233280
  }
}

function buildNodes(count: number): NodeDef[] {
  const rand = seededRandom(42)
  const nodes: NodeDef[] = []
  for (let i = 0; i < count; i++) {
    const side: 'creator' | 'brand' = i % 2 === 0 ? 'creator' : 'brand'
    const xBase = side === 'creator' ? -2.6 : 2.6
    const x = xBase + (rand() - 0.5) * 3.2
    const y = (rand() - 0.5) * 3.4
    const z = (rand() - 0.5) * 2.6
    nodes.push({
      position: new THREE.Vector3(x, y, z),
      scale: 0.09 + rand() * 0.1,
      side,
      shape: rand() > 0.5 ? 'ico' : 'octa',
    })
  }
  return nodes
}

const CREATOR_COLOR = new THREE.Color('#8b5cf6')
const BRAND_COLOR = new THREE.Color('#0ea5e9')
const BRIDGE_COLOR = new THREE.Color('#f97316')
const CONVERGENCE = new THREE.Vector3(0, -1.6, 0.6)

export function NetworkScene({ lowPower = false }: { lowPower?: boolean }) {
  const nodeCount = lowPower ? 16 : 34
  const nodes = useMemo(() => buildNodes(nodeCount), [nodeCount])
  const bridgeCount = lowPower ? 5 : 9
  const bridges = useMemo(() => {
    const rand = seededRandom(7)
    const creators = nodes.filter((n) => n.side === 'creator')
    const brands = nodes.filter((n) => n.side === 'brand')
    const list: [THREE.Vector3, THREE.Vector3][] = []
    for (let i = 0; i < bridgeCount; i++) {
      const a = creators[Math.floor(rand() * creators.length)]
      const b = brands[Math.floor(rand() * brands.length)]
      if (a && b) list.push([a.position, b.position])
    }
    return list
  }, [nodes, bridgeCount])

  const groupRef = useRef<THREE.Group>(null)
  const pointer = useRef({ x: 0, y: 0 })
  const prefersReducedMotion = useMemo(
    () => window.matchMedia('(prefers-reduced-motion: reduce)').matches,
    [],
  )

  useFrame((state, delta) => {
    if (!groupRef.current) return
    if (!prefersReducedMotion) {
      groupRef.current.rotation.y += delta * 0.06
      pointer.current.x = state.pointer.x
      pointer.current.y = state.pointer.y
      groupRef.current.rotation.x = THREE.MathUtils.lerp(
        groupRef.current.rotation.x,
        pointer.current.y * 0.15,
        0.04,
      )
      groupRef.current.rotation.z = THREE.MathUtils.lerp(
        groupRef.current.rotation.z,
        -pointer.current.x * 0.08,
        0.04,
      )
    }
  })

  const bridgeLineGeoms = useMemo(
    () =>
      bridges.map(([a, b]) => {
        const mid = a.clone().lerp(b, 0.5).lerp(CONVERGENCE, 0.35)
        const curve = new THREE.QuadraticBezierCurve3(a, mid, b)
        return new THREE.TubeGeometry(curve, 24, 0.006, 5, false)
      }),
    [bridges],
  )

  return (
    <group ref={groupRef}>
      {/* ambient depth particles */}
      <DustField count={lowPower ? 90 : 220} />

      {nodes.map((node, i) => (
        <mesh key={i} position={node.position} scale={node.scale}>
          {node.shape === 'ico' ? (
            <icosahedronGeometry args={[1, 0]} />
          ) : (
            <octahedronGeometry args={[1, 0]} />
          )}
          <meshStandardMaterial
            color={node.side === 'creator' ? CREATOR_COLOR : BRAND_COLOR}
            emissive={node.side === 'creator' ? CREATOR_COLOR : BRAND_COLOR}
            emissiveIntensity={0.6}
            roughness={0.35}
            metalness={0.2}
          />
        </mesh>
      ))}

      {bridgeLineGeoms.map((geom, i) => (
        <mesh key={i} geometry={geom}>
          <meshBasicMaterial
            color={BRIDGE_COLOR}
            transparent
            opacity={0.28}
            blending={THREE.AdditiveBlending}
            depthWrite={false}
          />
        </mesh>
      ))}

      {!prefersReducedMotion && (
        <TravelingSparks bridges={bridges} count={lowPower ? 6 : 14} />
      )}

      {/* the convergence point — where every bridge visually resolves */}
      <mesh position={CONVERGENCE}>
        <sphereGeometry args={[0.14, 24, 24]} />
        <meshBasicMaterial color="#ffffff" />
      </mesh>
      <mesh position={CONVERGENCE}>
        <sphereGeometry args={[0.34, 24, 24]} />
        <meshBasicMaterial
          color={BRIDGE_COLOR}
          transparent
          opacity={0.35}
          blending={THREE.AdditiveBlending}
          depthWrite={false}
        />
      </mesh>

      <ambientLight intensity={0.5} />
      <pointLight position={[3, 3, 4]} intensity={40} color="#ffffff" />
      <pointLight position={[-4, -2, 2]} intensity={20} color={CREATOR_COLOR} />
      <pointLight position={[4, -1, 2]} intensity={20} color={BRAND_COLOR} />
    </group>
  )
}

/** Small emissive sprites that ride each Brand↔Creator bridge toward the
 * convergence point — the "content/engagement" signal moving through the
 * network, ending at "sales." */
function TravelingSparks({
  bridges,
  count,
}: {
  bridges: [THREE.Vector3, THREE.Vector3][]
  count: number
}) {
  const meshRef = useRef<THREE.InstancedMesh>(null)
  const progress = useRef<number[]>(
    Array.from({ length: count }, (_, i) => i / count),
  )
  const curves = useMemo(
    () =>
      bridges.map(([a, b]) => {
        const mid = a.clone().lerp(b, 0.5).lerp(CONVERGENCE, 0.35)
        return new THREE.QuadraticBezierCurve3(a, mid, b)
      }),
    [bridges],
  )
  const dummy = useMemo(() => new THREE.Object3D(), [])

  useFrame((_, delta) => {
    if (!meshRef.current || curves.length === 0) return
    for (let i = 0; i < count; i++) {
      progress.current[i] = (progress.current[i] + delta * 0.15) % 1
      const curve = curves[i % curves.length]
      const t =
        progress.current[i] < 0.5
          ? progress.current[i] * 2
          : 2 - progress.current[i] * 2
      const point = curve.getPoint(Math.abs(Math.sin(progress.current[i] * Math.PI)))
      dummy.position.copy(point)
      dummy.scale.setScalar(0.5 + t * 0.5)
      dummy.updateMatrix()
      meshRef.current.setMatrixAt(i, dummy.matrix)
    }
    meshRef.current.instanceMatrix.needsUpdate = true
  })

  if (curves.length === 0) return null

  return (
    <instancedMesh ref={meshRef} args={[undefined, undefined, count]}>
      <sphereGeometry args={[0.028, 8, 8]} />
      <meshBasicMaterial
        color="#ffd9b3"
        transparent
        opacity={0.9}
        blending={THREE.AdditiveBlending}
        depthWrite={false}
      />
    </instancedMesh>
  )
}

function DustField({ count }: { count: number }) {
  const positions = useMemo(() => {
    const rand = seededRandom(101)
    const arr = new Float32Array(count * 3)
    for (let i = 0; i < count; i++) {
      arr[i * 3] = (rand() - 0.5) * 12
      arr[i * 3 + 1] = (rand() - 0.5) * 8
      arr[i * 3 + 2] = (rand() - 0.5) * 6 - 1
    }
    return arr
  }, [count])

  return (
    <points>
      <bufferGeometry>
        <bufferAttribute attach="attributes-position" args={[positions, 3]} />
      </bufferGeometry>
      <pointsMaterial
        size={0.018}
        color="#ffffff"
        transparent
        opacity={0.35}
        sizeAttenuation
        depthWrite={false}
      />
    </points>
  )
}
