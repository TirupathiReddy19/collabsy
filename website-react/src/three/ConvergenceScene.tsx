import { useMemo, useRef } from 'react'
import { useFrame } from '@react-three/fiber'
import * as THREE from 'three'

/**
 * A field of scattered particles drifting inward toward one bright,
 * pulsing core — "every view, every engagement, resolving into one
 * outcome." Used behind final CTAs and the Brands hero ("Get sales, not
 * just views"), where the message is specifically about many signals
 * converging on a single result.
 */
function seededRandom(seed: number) {
  let s = seed
  return () => {
    s = (s * 9301 + 49297) % 233280
    return s / 233280
  }
}

// Pulled down and back from dead-centre so the bright core sits low in the
// frame, clear of the headline/button column every usage centres in the
// middle of — it used to project straight onto that text.
const ANCHOR = new THREE.Vector3(0, -1.35, -0.4)

export function ConvergenceScene({
  lowPower = false,
  color = '#f97316',
}: {
  lowPower?: boolean
  color?: string
}) {
  // Halved from 60/140 — every one of these particles' position is
  // recomputed every single frame (see useFrame below), so this count is a
  // direct, continuous tax on every page using this scene, not just a
  // one-time setup cost. See NetworkScene.tsx for the measured TBT context.
  const count = lowPower ? 35 : 75
  const pointsRef = useRef<THREE.Points>(null)
  const coreRef = useRef<THREE.Mesh>(null)
  const groupRef = useRef<THREE.Group>(null)

  const { positions, radii, speeds, angles } = useMemo(() => {
    const rand = seededRandom(17)
    const positions = new Float32Array(count * 3)
    const radii = new Float32Array(count)
    const speeds = new Float32Array(count)
    const angles = new Float32Array(count * 2)
    for (let i = 0; i < count; i++) {
      const r = 1.8 + rand() * 2.6
      const theta = rand() * Math.PI * 2
      const phi = Math.acos(rand() * 2 - 1)
      positions[i * 3] = r * Math.sin(phi) * Math.cos(theta)
      positions[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta)
      positions[i * 3 + 2] = r * Math.cos(phi) * 0.6
      radii[i] = r
      speeds[i] = 0.04 + rand() * 0.08
      angles[i * 2] = theta
      angles[i * 2 + 1] = phi
    }
    return { positions, radii, speeds, angles }
  }, [count])

  useFrame((state, delta) => {
    if (groupRef.current) {
      groupRef.current.rotation.y += delta * 0.03
      groupRef.current.rotation.x = THREE.MathUtils.lerp(
        groupRef.current.rotation.x,
        state.pointer.y * 0.1,
        0.03,
      )
    }
    if (coreRef.current) {
      const pulse = 1 + Math.sin(state.clock.elapsedTime * 2) * 0.12
      coreRef.current.scale.setScalar(pulse)
    }
    if (pointsRef.current) {
      const posAttr = pointsRef.current.geometry.attributes.position.array as Float32Array
      for (let i = 0; i < count; i++) {
        radii[i] -= speeds[i] * delta
        if (radii[i] < 0.3) radii[i] = 1.8 + ((i * 37) % 100) / 100 * 2.6
        const theta = angles[i * 2] + state.clock.elapsedTime * 0.02
        const phi = angles[i * 2 + 1]
        posAttr[i * 3] = radii[i] * Math.sin(phi) * Math.cos(theta)
        posAttr[i * 3 + 1] = radii[i] * Math.sin(phi) * Math.sin(theta)
        posAttr[i * 3 + 2] = radii[i] * Math.cos(phi) * 0.6
      }
      pointsRef.current.geometry.attributes.position.needsUpdate = true
    }
  })

  return (
    <group ref={groupRef} position={ANCHOR}>
      <points ref={pointsRef}>
        <bufferGeometry>
          <bufferAttribute attach="attributes-position" args={[positions, 3]} />
        </bufferGeometry>
        <pointsMaterial
          size={0.045}
          color={color}
          transparent
          opacity={0.75}
          sizeAttenuation
          depthWrite={false}
          blending={THREE.AdditiveBlending}
        />
      </points>

      {/* Three nested, low-opacity shells instead of one solid ball — reads
          as a soft glow with no hard silhouette, so it never looks like a
          stray disc wherever it ends up relative to text (a single opaque
          sphere here used to look like a floating spotlight). */}
      <mesh ref={coreRef}>
        <sphereGeometry args={[0.07, 24, 24]} />
        <meshBasicMaterial color="#ffffff" transparent opacity={0.45} blending={THREE.AdditiveBlending} depthWrite={false} />
      </mesh>
      <mesh>
        <sphereGeometry args={[0.32, 32, 32]} />
        <meshBasicMaterial color={color} transparent opacity={0.14} blending={THREE.AdditiveBlending} depthWrite={false} />
      </mesh>
      <mesh>
        <sphereGeometry args={[0.75, 32, 32]} />
        <meshBasicMaterial
          color={color}
          transparent
          opacity={0.06}
          blending={THREE.AdditiveBlending}
          depthWrite={false}
        />
      </mesh>

      <ambientLight intensity={0.5} />
      <pointLight position={[0, 0, 3]} intensity={25} color={color} />
    </group>
  )
}
