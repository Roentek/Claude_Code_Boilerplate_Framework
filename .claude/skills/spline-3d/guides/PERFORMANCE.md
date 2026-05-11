# Performance Optimization

The #1 complaint about Spline on the web is **performance**. A poorly exported scene can add 5+ seconds to your page load and kill mobile performance. This guide covers how to avoid that.

---

## Understanding the Cost

When you embed a Spline scene, here's what gets loaded:

| Asset | Typical Size | Can Optimize? |
| ------- | ------------- | --------------- |
| `@splinetool/runtime` (JS) | ~500KB | Lazy load it |
| `.splinecode` file (scene data) | 1-10MB | Compress in Spline editor |
| Textures/images in the scene | 0-20MB+ | Reduce in Spline editor |

**Total:** A typical scene adds **1-5MB** to your page. An unoptimized one can be **20MB+**.

---

## Spline Editor Optimizations (Before Export)

These are the most impactful. Do them **before** you export.

### 1. Use the Performance Panel

Open it via **View → Performance** in the Spline editor. It shows:

- Total polygon count
- Number of objects, materials, and lights
- Specific recommendations for your scene

### 2. Reduce Polygons

| Scene Type | Target Polygons |
| ----------- | ---------------- |
| Hero background | 50k - 100k |
| Product viewer | 80k - 150k |
| Simple icon/logo | Under 30k |
| Mobile scene | Under 50k |

**How to reduce:**

- Lower **segments** on smooth objects (spheres, cylinders, torus)
- Simplify complex shapes
- Delete small details users won't notice at web scale

### 3. Limit Lights

Each light source multiplies the rendering work.

| Lights | Impact |
| -------- | -------- |
| 1-2 | ✅ Good performance |
| 3 | ⚠️ Acceptable |
| 4+ | ❌ Noticeable slowdown |

**Alternatives to extra lights:**

- **Matcap materials** — Bake lighting into the material. Looks great, costs nothing to render.
- **Fresnel layers** — Simulate edge lighting without an actual light source.
- **Emissive materials** — Make objects glow without a light.

### 4. Clean Up Hidden Objects

Objects that are hidden (eye icon toggled off) still get exported and loaded. Delete them if you don't need them for animation states.

### 5. Minimize Textures

Each image/texture in a material increases the file size.

- Use solid colors where possible
- If you need textures, keep them under 1024x1024
- Avoid multiple textures per material

---

## Export Settings

When exporting from Spline:

### Geometry Quality

- **Performance** — Recommended for web. Reduces polygon precision.
- **Balanced** — Middle ground.
- **Quality** — Use only if visual precision matters more than performance.

### Image Compression

- Enable compression for all textures
- Higher compression = smaller file, slightly lower quality
- Usually compression at 70-80% is unnoticeable

### Geometry Compression

- **Enable this.** It can reduce scene file size by 50-80%.
- Very high compression may cause visible artifacts on smooth surfaces — test it

---

## Code-Side Optimizations

### Lazy Loading (Critical)

**Never** load the Spline runtime eagerly. It's ~500KB of JavaScript.

#### React

```tsx
import { Suspense, lazy } from 'react';
const Spline = lazy(() => import('@splinetool/react-spline'));

// Show a loader while the heavy JS downloads
<Suspense fallback={<div className="loader" />}>
  <Spline scene="..." />
</Suspense>
```

#### Next.js

```tsx
import dynamic from 'next/dynamic';
const Spline = dynamic(() => import('@splinetool/react-spline'), {
  ssr: false,
  loading: () => <div className="loader" />,
});
```

#### Vanilla JS — Intersection Observer

Only load the scene when user scrolls to it:

```js
const canvas = document.getElementById('canvas3d');

const observer = new IntersectionObserver(async (entries) => {
  if (entries[0].isIntersecting) {
    observer.disconnect();

    const { Application } = await import('https://esm.sh/@splinetool/runtime');
    const spline = new Application(canvas);
    await spline.load('https://prod.spline.design/YOUR_ID/scene.splinecode');
  }
}, { threshold: 0.1 });

observer.observe(canvas);
```

### One Scene Per Page

Multiple Spline scenes compete for the GPU. Each canvas creates a separate WebGL context.

| Scenes on Page | Expected Performance |
| --------------- | --------------------- |
| 1 | ✅ Smooth |
| 2 (simple) | ⚠️ Usually fine if under 50k polys each |
| 3+ | ❌ Likely to cause jank |

If you need multiple 3D elements, consider:

- Putting them all in **one scene** with different camera angles
- Using static **images/videos** for non-interactive ones
- Loading scenes **sequentially** and destroying off-screen ones

---

## Mobile Strategy

Mobile GPUs are **10-50x weaker** than desktop GPUs. Plan for this.

### Option 1: Simplified Mobile Scene

Create two versions of your scene — one for desktop, one for mobile:

```tsx
const isMobile = window.innerWidth < 768;

<Spline
  scene={
    isMobile
      ? 'https://prod.spline.design/MOBILE_ID/scene.splinecode'
      : 'https://prod.spline.design/DESKTOP_ID/scene.splinecode'
  }
/>
```

### Option 2: Static Image Fallback

Replace the 3D scene with a screenshot on mobile:

```tsx
function SmartScene({ scene, mobileFallback }) {
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    setIsMobile(window.innerWidth < 768);
  }, []);

  if (isMobile) {
    return <img src={mobileFallback} alt="3D scene" className="w-full h-full object-cover" />;
  }

  return <SplineScene scene={scene} />;
}
```

### Option 3: Reduced Quality Thresholds

For mobile scenes:

- Under **50k polygons**
- **1 light** only
- No physics simulation
- No particle effects
- Disable post-processing

---

## Measuring Impact

### Lighthouse Score Impact

A Spline scene typically affects:

| Metric | Impact | Mitigation |
| -------- | -------- | ----------- |
| **LCP** (Largest Contentful Paint) | +1-3s | Lazy load, show placeholder |
| **TBT** (Total Blocking Time) | +200-500ms | Lazy load JS |
| **CLS** (Cumulative Layout Shift) | Minimal if sized properly | Set explicit container dimensions |

### How to Test

1. Run Lighthouse with and without the Spline scene
2. Check the **Performance** tab in Chrome DevTools for:
   - GPU memory usage
   - Frame rate (aim for 60fps on desktop, 30fps on mobile)
   - Network waterfall (how big is the .splinecode file?)

---

## Optimization Checklist

Use this before shipping any page with a Spline scene:

```text
Pre-Export (Spline Editor):
□ Polygon count under target (150k desktop, 50k mobile)
□ 3 or fewer lights
□ No hidden/unused objects
□ Textures under 1024x1024
□ Performance panel shows no red flags

Export Settings:
□ Geometry Quality set to "Performance"
□ Geometry Compression enabled
□ Image Compression enabled (70-80%)

Code:
□ Spline component is lazy-loaded
□ Loading state shown while scene downloads
□ Container has explicit width and height
□ Mobile fallback implemented (image or simplified scene)
□ Only 1 complex scene per page

Testing:
□ Scene loads in under 3 seconds on desktop
□ Scene loads in under 5 seconds on mobile (or falls back)
□ 60fps on desktop, 30fps+ on mobile
□ Lighthouse score acceptable
```

---

## When NOT to Use Spline

Sometimes 3D isn't the right choice. Consider alternatives when:

- The 3D scene is purely decorative (no interaction) → **Use a video or animated GIF instead**
- The page already has heavy assets → **The Spline scene will push it over the edge**
- Most of your users are on mobile → **Consider CSS 3D transforms or Lottie animations**
- You need the page to score 90+ on Lighthouse → **3D will make this very difficult**

An alternative approach: Export a **video** of your Spline scene and use that. You get the visual impact without the runtime cost.
