# Roentek Robot — Spline Build Guide

Recreate the coded Three.js character in Spline's browser editor.
Open Spline at [spline.design](https://spline.design) → New File.

---

## Brand Colors

| Swatch | Hex |
| -------- | ----- |
| Background | `#0a0a0a` |
| Body metal | `#1c1c1e` |
| Dark accents | `#0e0e0f` |
| Red primary | `#E53935` |
| Screen | `#060606` |

---

## Scene Setup

1. **Background** → Scene properties → Color → `#0a0a0a`
2. **Fog** → Enable → Type: Exponential → Color `#0a0a0a` → Density: 0.04

---

## Lighting

| Light | Type | Color | Intensity | Position |
| ------- | ------ | ------ | ----------- | ---------- |
| Key | Directional | `#ffffff` | 1.8 | (4, 6, 4) |
| Fill | Ambient | `#ffffff` | 0.3 | — |
| Rim | Directional | `#1a0000` | 1.2 | (-4, 2, -4) |
| Eye glow | Point | `#E53935` | 4 | (0, 0.5, 1.2) |
| Antenna | Point | `#E53935` | 2.5 | (0, 1.6, 0) |

---

## Step 1 — Head

1. Add → Box → rename "Head"
2. **Size:** W: 1.25 · H: 1.05 · D: 1.05
3. **Position:** Y: 0.53
4. **Material:** PBR Standard
   - Color: `#1c1c1e`
   - Metalness: 85%
   - Roughness: 25%

---

## Step 2 — TV Screen Face

1. Add → Box → rename "Screen"
2. **Size:** W: 0.9 · H: 0.68 · D: 0.06
3. **Position:** Y: 0.52 · Z: 0.55 (front face of head)
4. **Material:** PBR
   - Color: `#060606`
   - Roughness: 90%

---

## Step 3 — Eye (Circular Glow)

1. Add → Circle → rename "Eye"
2. **Radius:** 0.2
3. **Position:** Y: 0.52 · Z: 0.585
4. **Material:** PBR
   - Color: `#ff4040`
   - Emission: `#E53935` · Strength: 2.5

### Eye Ring

1. Add → Torus → rename "EyeRing"
2. **Inner radius:** 0.2 · **Outer radius:** 0.26 · **Segments:** 40
3. **Position:** Match Eye Z exactly
4. **Material:** Emission `#E53935` · Strength: 1.8

---

## Step 4 — Lightning Bolt

1. Add → **SVG** → paste this SVG path OR draw with Pen tool:

```svg
<svg viewBox="-1 -5 2 10" xmlns="http://www.w3.org/2000/svg">
  <path d="M0.95 4.2 L-0.25 0.6 L0.65 0.6 L-0.95 -4.2 L0.25 -0.6 L-0.65 -0.6 Z" />
</svg>
```

2. Select path → **Extrude** → Depth: 0.065
3. **Position:** Y: 0.52 · Z: 0.62
4. **Rotation Z:** -7°
5. **Scale:** 1.45 uniform
6. **Material:** PBR
   - Color: `#E53935`
   - Emission: `#E53935` · Strength: 0.6
   - Metalness: 20%

---

## Step 5 — Antenna

1. **Base:** Add → Cylinder → W: 0.09 · H: 0.18 · Position Y: 1.12
   - Material: `#0e0e0f` metalness 90%
2. **Rod:** Add → Cylinder → W: 0.044 · H: 0.38 · Position Y: 1.38
   - Material: body metal
3. **Orb:** Add → Sphere → Radius: 0.075 · Position Y: 1.61
   - Material: Emission `#E53935` · Strength: 1.2

---

## Step 6 — Body

1. Add → Box → rename "Body"
2. **Size:** W: 0.9 · H: 0.72 · D: 0.8
3. **Position:** Y: -0.36
4. **Material:** Same body metal as head

### Body Panels (horizontal groove lines)

Add 3 thin boxes:

- W: 0.52 · H: 0.05 · D: 0.81
- Positions Y: -0.18, -0.35, -0.52
- Material: `#111113`

---

## Step 7 — Arms

Two boxes, left and right:

- **Size:** W: 0.22 · H: 0.58 · D: 0.24
- **Position X:** ±0.6 · **Y:** -0.3
- Same body metal material

---

## Step 8 — Floor

1. Add → Plane → Size: 12×12 · Position Y: -0.75
2. **Material:** `#0d0d0d` · Metalness: 40% · Roughness: 70%

---

## Step 9 — Group & Name

1. Select all parts → Group → rename "Robot"
2. Set group pivot to center

---

## Step 10 — Animations

### Idle Float

1. Select "Robot" group → **State machine**
2. Add → **Idle** state
3. Keyframe 1 (0s): Y position = 0
4. Keyframe 2 (1.2s): Y position = 0.09
5. Keyframe 3 (2.4s): Y position = 0
6. **Easing:** Sine In-Out · **Loop:** Yes

### Eye Pulse

1. Select "Eye" → Add state → Animate Emission Strength
2. 0s → strength 2.0 · 0.5s → 3.2 · 1s → 2.0 · Loop
3. Same for EyeRing

### Antenna Bob

1. Select "Orb" → Animate Y position
2. 0s → Y 1.61 · 0.4s → Y 1.635 · 0.8s → Y 1.61 · Loop

### Mouse Follow (Rotation)

1. Select "Robot" group → Events → **Mouse Move**
2. **Look At Cursor** → Axis: XY · Strength: 20% · Smooth: 0.1

---

## Step 11 — Export

1. Top right → **Export** → **Code**
2. Copy scene URL
3. Embed in your site:

```html
<!-- Iframe (simplest) -->
<iframe
  src="https://my.spline.design/YOUR_SCENE_ID/"
  frameborder="0"
  width="100%"
  height="600">
</iframe>
```

```tsx
// React component
import Spline from '@splinetool/react-spline';

export default function RobotHero() {
  return (
    <div style={{ width: '100%', height: '100vh' }}>
      <Spline scene="https://prod.spline.design/YOUR_SCENE_ID/scene.splinecode" />
    </div>
  );
}
```

---

## Optimization Checklist

- [ ] Polygon count under 80k (View → Performance panel)
- [ ] No more than 5 lights active
- [ ] Enable geometry compression on export
- [ ] Test on mobile — hide 3D on screens < 768px if laggy

---

## Community Shortcut

Search Spline Community for "robot character" or "TV head" — you may find a base mesh to adapt rather than building from scratch. Roentek's style is closest to:

- Dark metallic robot
- Single eye / cyclops
- Retro box-head form factor

Filter by: **Characters** category.
