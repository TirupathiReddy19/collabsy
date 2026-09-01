import { Canvas } from '@react-three/fiber'
import { NetworkScene } from './NetworkScene'

export default function CanvasScene({ lowPower }: { lowPower: boolean }) {
  return (
    <Canvas
      dpr={[1, lowPower ? 1.5 : 2]}
      gl={{ antialias: true, alpha: true, powerPreference: 'high-performance' }}
      camera={{ position: [0, 0, 7.5], fov: 42 }}
      style={{ position: 'absolute', inset: 0 }}
    >
      <fog attach="fog" args={['#0b0b0d', 6, 13]} />
      <NetworkScene lowPower={lowPower} />
    </Canvas>
  )
}
