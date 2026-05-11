# React & Next.js Integration

Detailed guide for integrating Spline 3D scenes into React and Next.js projects.

---

## Installation

```bash
npm install @splinetool/react-spline @splinetool/runtime
```

> Always install both packages together to avoid version conflicts.

---

## Basic Usage

```tsx
import Spline from '@splinetool/react-spline';

function Hero() {
  return (
    <div style={{ width: '100%', height: '100vh' }}>
      <Spline scene="https://prod.spline.design/YOUR_ID/scene.splinecode" />
    </div>
  );
}
```

---

## Recommended: Lazy-Loaded Wrapper Component

The Spline runtime is **~500KB+**. Always lazy-load it to avoid blocking your initial page render.

```tsx
'use client'; // Required for Next.js app router

import { Suspense, lazy } from 'react';

const Spline = lazy(() => import('@splinetool/react-spline'));

interface SplineSceneProps {
  scene: string;
  className?: string;
  onLoad?: (app: any) => void;
}

export function SplineScene({ scene, className, onLoad }: SplineSceneProps) {
  return (
    <Suspense
      fallback={
        <div
          style={{
            width: '100%',
            height: '100%',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <span className="loader" />
        </div>
      }
    >
      <Spline scene={scene} className={className} onLoad={onLoad} />
    </Suspense>
  );
}
```

### Usage

```tsx
<SplineScene
  scene="https://prod.spline.design/YOUR_ID/scene.splinecode"
  className="w-full h-full"
  onLoad={(app) => console.log('Scene ready!', app)}
/>
```

---

## Interactivity with `onLoad`

The `onLoad` callback gives you a reference to the Spline Application object. Use it to interact with the scene:

```tsx
import { useRef, useCallback } from 'react';
import Spline from '@splinetool/react-spline';

function InteractiveScene() {
  const splineRef = useRef(null);

  const handleLoad = useCallback((app) => {
    splineRef.current = app;

    // Find objects
    const cube = app.findObjectByName('MyCube');
    console.log('Cube position:', cube?.position);

    // Listen for events
    app.addEventListener('mouseDown', (e) => {
      console.log('Clicked:', e.target.name);
    });
  }, []);

  // External control function
  const triggerAnimation = () => {
    if (splineRef.current) {
      splineRef.current.emitEvent('mouseDown', 'PlayButton');
    }
  };

  return (
    <div>
      <button onClick={triggerAnimation}>Play</button>
      <div style={{ width: '100%', height: '80vh' }}>
        <Spline
          scene="https://prod.spline.design/YOUR_ID/scene.splinecode"
          onLoad={handleLoad}
        />
      </div>
    </div>
  );
}
```

---

## Variables — Connecting React State to 3D

Spline variables let you drive 3D animations from your React state:

```tsx
function DataDrivenScene() {
  const splineRef = useRef(null);
  const [progress, setProgress] = useState(0);

  const handleLoad = (app) => {
    splineRef.current = app;
  };

  // Sync React state with Spline variable
  useEffect(() => {
    if (splineRef.current) {
      splineRef.current.setVariable('progress', progress);
    }
  }, [progress]);

  return (
    <div>
      <input
        type="range"
        min={0}
        max={100}
        value={progress}
        onChange={(e) => setProgress(Number(e.target.value))}
      />
      <Spline
        scene="https://prod.spline.design/YOUR_ID/scene.splinecode"
        onLoad={handleLoad}
      />
    </div>
  );
}
```

---

## Next.js Specifics

### App Router (Next.js 14+)

The Spline component uses browser APIs, so it must be a **client component**:

```tsx
'use client';

import Spline from '@splinetool/react-spline/next';

export default function Hero() {
  return (
    <div style={{ width: '100%', height: '100vh' }}>
      <Spline scene="https://prod.spline.design/YOUR_ID/scene.splinecode" />
    </div>
  );
}
```

> **Note:** Import from `@splinetool/react-spline/next` for the Next.js-optimized version. It includes server-side rendering support with blurred placeholder rendering.

### Pages Router

Works the same as standard React. Use dynamic import to avoid SSR issues:

```tsx
import dynamic from 'next/dynamic';

const Spline = dynamic(() => import('@splinetool/react-spline'), {
  ssr: false,
  loading: () => <div className="spinner" />,
});

export default function Page() {
  return (
    <div style={{ width: '100%', height: '100vh' }}>
      <Spline scene="https://prod.spline.design/YOUR_ID/scene.splinecode" />
    </div>
  );
}
```

---

## TypeScript Types

The Spline App object doesn't ship with great types. Here's a useful type reference:

```tsx
import type { Application } from '@splinetool/runtime';

// Common object type (approximate)
interface SplineObject {
  name: string;
  id: string;
  position: { x: number; y: number; z: number };
  rotation: { x: number; y: number; z: number };
  scale: { x: number; y: number; z: number };
  visible: boolean;
}

// Event type (approximate)
interface SplineEvent {
  target: SplineObject;
}

// Usage with onLoad
const handleLoad = (app: Application) => {
  const obj = app.findObjectByName('Cube');
  if (obj) {
    obj.position.x = 2;
  }
};
```

---

## Responsive Design Patterns

### Fill Container

```tsx
<div style={{ width: '100%', height: '100vh', position: 'relative' }}>
  <SplineScene scene="..." className="absolute inset-0" />
</div>
```

### Mobile Fallback

Show a static image on mobile for better performance:

```tsx
import { useEffect, useState } from 'react';

function ResponsiveScene({ scene, fallbackImage }) {
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    const check = () => setIsMobile(window.innerWidth < 768);
    check();
    window.addEventListener('resize', check);
    return () => window.removeEventListener('resize', check);
  }, []);

  if (isMobile && fallbackImage) {
    return (
      <img
        src={fallbackImage}
        alt="3D scene"
        style={{ width: '100%', height: '100%', objectFit: 'cover' }}
      />
    );
  }

  return <SplineScene scene={scene} />;
}
```

### Fade-In on Load

```tsx
function FadeInScene({ scene }) {
  const [loaded, setLoaded] = useState(false);

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      {!loaded && (
        <div className="absolute inset-0 flex items-center justify-center bg-black/50">
          <div className="spinner" />
        </div>
      )}
      <SplineScene
        scene={scene}
        onLoad={() => setLoaded(true)}
        className={`transition-opacity duration-500 ${loaded ? 'opacity-100' : 'opacity-0'}`}
      />
    </div>
  );
}
```

---

## Common Mistakes

### 1. Container Has No Height

```tsx
// ❌ BAD — Spline fills its parent, but parent has 0 height
<div>
  <Spline scene="..." />
</div>

// ✅ GOOD — Parent has explicit height
<div style={{ width: '100%', height: '100vh' }}>
  <Spline scene="..." />
</div>
```

### 2. Not Lazy Loading

```tsx
// ❌ BAD — Loads 500KB+ on initial render
import Spline from '@splinetool/react-spline';

// ✅ GOOD — Only loads when component renders
const Spline = lazy(() => import('@splinetool/react-spline'));
```

### 3. SSR Crashes in Next.js

```tsx
// ❌ BAD — Spline uses `window`, crashes on server
import Spline from '@splinetool/react-spline';

// ✅ GOOD — Skip SSR
import dynamic from 'next/dynamic';
const Spline = dynamic(() => import('@splinetool/react-spline'), { ssr: false });

// ✅ ALSO GOOD — Use the Next.js-specific import
import Spline from '@splinetool/react-spline/next';
```

### 4. Missing 'use client' in App Router

```tsx
// ❌ BAD — Server component by default in Next.js 14+
import Spline from '@splinetool/react-spline';

// ✅ GOOD — Mark as client component
'use client';
import Spline from '@splinetool/react-spline';
```
