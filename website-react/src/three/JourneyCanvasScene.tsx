import { Canvas } from '@react-three/fiber'
import { JourneyScene } from './JourneyScene'
import type { ScenePropsBase } from './LazyCanvas'

export default function JourneyCanvasScene({ lowPower }: ScenePropsBase) {
  return (
    <Canvas
      dpr={[1, lowPower ? 1.5 : 2]}
      gl={{ antialias: true, alpha: true }}
      camera={{ position: [0, 0, 7], fov: 45 }}
      style={{ position: 'absolute', inset: 0 }}
    >
      <JourneyScene lowPower={lowPower} />
    </Canvas>
  )
}
