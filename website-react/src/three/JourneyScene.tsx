import { useEffect, useMemo, useRef } from 'react'
import { useFrame, useThree } from '@react-three/fiber'
import * as THREE from 'three'
import { ScrollTrigger } from '../lib/gsap'

/**
 * The "campaign journey" visual — reused wherever the site shows a
 * numbered step sequence (Home's How it works, Brands' 4-step process,
 * Creators' 4 steps): four waypoints along a gentle curve, with a bright
 * marker travelling between them as the section scrolls past. The actual
 * step numbers/titles stay real HTML text next to this — the scene is
 * atmosphere, not the information itself.
 */

// Kept within the camera's actual frustum at JourneyCanvasScene's
// [0,0,7]/fov 45 framing (half-width there is ~2.9) — the previous ±3.4
// spread put the two outer nodes off-screen entirely.
const WAYPOINTS = [
  new THREE.Vector3(-2.6, 0.55, 0),
  new THREE.Vector3(-0.85, -0.45, 0.4),
  new THREE.Vector3(0.85, 0.45, 0.4),
  new THREE.Vector3(2.6, -0.55, 0),
]

export function JourneyScene({
  lowPower = false,
  color = '#f97316',
}: {
  lowPower?: boolean
  color?: string
}) {
  const progress = useRef(0)
  const markerRef = useRef<THREE.Mesh>(null)
  const trailRef = useRef<THREE.Points>(null)
  const groupRef = useRef<THREE.Group>(null)

  const curve = useMemo(() => new THREE.CatmullRomCurve3(WAYPOINTS, false, 'catmullrom', 0.5), [])
  const tubeGeometry = useMemo(() => new THREE.TubeGeometry(curve, 64, 0.008, 6, false), [curve])

  const trailCount = lowPower ? 24 : 48
  const trailPositions = useMemo(() => new Float32Array(trailCount * 3), [trailCount])

  const { gl } = useThree()

  useEffect(() => {
    // Ties marker progress to how far the *section this scene lives in*
    // has scrolled through the viewport. Found generically by walking up
    // from this canvas's own DOM node to the nearest `.section` ancestor
    // — every page section already carries that class — so this scene
    // stays drop-in reusable without any page passing it a ref/selector.
    const sectionEl = gl.domElement.closest<HTMLElement>('.section') ?? undefined
    const trigger = ScrollTrigger.create({
      trigger: sectionEl,
      start: 'top bottom',
      end: 'bottom top',
      scrub: 0.6,
      onUpdate: (self) => {
        progress.current = self.progress
      },
    })
    return () => trigger.kill()
  }, [gl])

  useFrame((state) => {
    if (!groupRef.current) return
    groupRef.current.rotation.y = Math.sin(state.clock.elapsedTime * 0.08) * 0.15

    const t = progress.current
    const point = curve.getPoint(t)
    if (markerRef.current) {
      markerRef.current.position.copy(point)
      const scale = 1 + Math.sin(state.clock.elapsedTime * 4) * 0.15
      markerRef.current.scale.setScalar(scale)
    }
    if (trailRef.current) {
      const positions = trailRef.current.geometry.attributes.position.array as Float32Array
      for (let i = 0; i < trailCount; i++) {
        const trailT = Math.max(0, t - i * 0.012)
        const p = curve.getPoint(trailT)
        positions[i * 3] = p.x
        positions[i * 3 + 1] = p.y
        positions[i * 3 + 2] = p.z
      }
      trailRef.current.geometry.attributes.position.needsUpdate = true
    }
  })

  return (
    <group ref={groupRef}>
      <mesh geometry={tubeGeometry}>
        <meshBasicMaterial color={color} transparent opacity={0.32} depthWrite={false} />
      </mesh>

      {WAYPOINTS.map((p, i) => (
        <mesh key={i} position={p}>
          <icosahedronGeometry args={[0.22, 0]} />
          <meshStandardMaterial
            color={color}
            emissive={color}
            emissiveIntensity={0.85}
            roughness={0.35}
          />
        </mesh>
      ))}

      <points ref={trailRef}>
        <bufferGeometry>
          <bufferAttribute attach="attributes-position" args={[trailPositions, 3]} />
        </bufferGeometry>
        <pointsMaterial
          size={0.07}
          color={color}
          transparent
          opacity={0.8}
          sizeAttenuation
          depthWrite={false}
          blending={THREE.AdditiveBlending}
        />
      </points>

      <mesh ref={markerRef}>
        <sphereGeometry args={[0.13, 20, 20]} />
        <meshStandardMaterial color="#ffffff" emissive={color} emissiveIntensity={0.6} />
      </mesh>

      <ambientLight intensity={0.6} />
      <pointLight position={[0, 2, 4]} intensity={30} />
    </group>
  )
}
