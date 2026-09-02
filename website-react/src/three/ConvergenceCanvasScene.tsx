import { Canvas } from '@react-three/fiber'
import { ConvergenceScene } from './ConvergenceScene'
import type { ScenePropsBase } from './LazyCanvas'

export default function ConvergenceCanvasScene({ lowPower }: ScenePropsBase) {
  return (
    <Canvas
      dpr={[1, lowPower ? 1.5 : 2]}
      gl={{ antialias: true, alpha: true }}
      camera={{ position: [0, 0, 6], fov: 42 }}
      style={{ position: 'absolute', inset: 0 }}
    >
      <ConvergenceScene lowPower={lowPower} />
    </Canvas>
  )
}
