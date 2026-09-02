import { Canvas } from '@react-three/fiber'
import { ConvergenceScene } from './ConvergenceScene'
import type { ScenePropsBase } from './LazyCanvas'

/** Creator-tinted variant of ConvergenceCanvasScene — same scene, violet
 * accent instead of orange, for pages centred on the Creator side. */
export default function ConvergenceCanvasSceneViolet({ lowPower }: ScenePropsBase) {
  return (
    <Canvas
      dpr={[1, lowPower ? 1.5 : 2]}
      gl={{ antialias: true, alpha: true }}
      camera={{ position: [0, 0, 6], fov: 42 }}
      style={{ position: 'absolute', inset: 0 }}
    >
      <ConvergenceScene lowPower={lowPower} color="#8b5cf6" />
    </Canvas>
  )
}
