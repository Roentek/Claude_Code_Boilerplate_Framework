# Vanilla JavaScript Integration

Guide for embedding Spline 3D scenes in plain HTML/JavaScript projects — no React or framework required.

---

## Installation

### Option 1: CDN (Recommended for quick starts)

No install needed. Use a CDN like esm.sh or jsDelivr:

```html
<script type="module">
  import { Application } from 'https://esm.sh/@splinetool/runtime';
</script>
```

### Option 2: npm

```bash
npm install @splinetool/runtime
```

```js
import { Application } from '@splinetool/runtime';
```

---

## Basic Setup

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Spline Scene</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { overflow: hidden; }
    #canvas3d {
      width: 100vw;
      height: 100vh;
      display: block;
    }
  </style>
</head>
<body>
  <canvas id="canvas3d"></canvas>

  <script type="module">
    import { Application } from 'https://esm.sh/@splinetool/runtime';

    const canvas = document.getElementById('canvas3d');
    const spline = new Application(canvas);

    spline.load('https://prod.spline.design/YOUR_SCENE_ID/scene.splinecode')
      .then(() => {
        console.log('Scene loaded successfully!');
      });
  </script>
</body>
</html>
```

---

## Core API

### Loading a Scene

```js
const canvas = document.getElementById('canvas3d');
const spline = new Application(canvas);

// Load returns a Promise
await spline.load('https://prod.spline.design/YOUR_ID/scene.splinecode');
```

### Finding Objects

```js
// By name (matches the name in Spline editor)
const cube = spline.findObjectByName('MyCube');

// By ID
const obj = spline.findObjectById('some-uuid');

// Get all objects
const allObjects = spline.getAllObjects();
console.log('Total objects:', allObjects.length);
```

### Modifying Objects

```js
const cube = spline.findObjectByName('Cube');

// Position
cube.position.x = 5;
cube.position.y = 2;
cube.position.z = -3;

// Rotation (in radians)
cube.rotation.x = 0;
cube.rotation.y = Math.PI / 2; // 90 degrees
cube.rotation.z = 0;

// Scale
cube.scale.x = 2;
cube.scale.y = 2;
cube.scale.z = 2;

// Visibility
cube.visible = false; // hide
cube.visible = true;  // show
```

---

## Events

### Listening to Scene Events

```js
// Mouse events
spline.addEventListener('mouseDown', (e) => {
  console.log('Clicked:', e.target.name);
});

spline.addEventListener('mouseUp', (e) => {
  console.log('Released:', e.target.name);
});

spline.addEventListener('mouseHover', (e) => {
  console.log('Hovering:', e.target.name);
  canvas.style.cursor = 'pointer';
});

// Keyboard events (if set up in Spline editor)
spline.addEventListener('keyDown', (e) => {
  console.log('Key pressed:', e.target.name);
});
```

### Triggering Events from Code

Trigger events that are defined in the Spline editor:

```js
// Trigger by object name
spline.emitEvent('mouseDown', 'PlayButton');

// Trigger by object ID
spline.emitEventReverse('mouseDown', 'object-uuid-here');
```

---

## Variables

### Reading & Writing

```js
// Set a variable (updates scene in real-time)
spline.setVariable('score', 100);
spline.setVariable('isActive', true);
spline.setVariable('playerName', 'User');

// Read a variable
const score = spline.getVariable('score');
console.log('Current score:', score);
```

### Use Case: Connect to External Data

```js
// Fetch data and update the 3D scene
async function updateFromAPI() {
  const data = await fetch('/api/stats').then(r => r.json());

  spline.setVariable('revenue', data.revenue);
  spline.setVariable('growth', data.growthPercent);
}

// Update every 10 seconds
setInterval(updateFromAPI, 10000);
```

---

## Animation Loop

For continuous animations or updates, use `requestAnimationFrame`:

```js
let time = 0;

function animate() {
  time += 0.01;

  const cube = spline.findObjectByName('Cube');
  if (cube) {
    // Gentle float animation
    cube.position.y = Math.sin(time) * 0.5;
    cube.rotation.y += 0.005;
  }

  requestAnimationFrame(animate);
}

// Start after scene loads
spline.load('...').then(() => {
  animate();
});
```

---

## Scroll-Driven Animations

Connect scroll position to Spline variables:

```js
spline.load('...').then(() => {
  window.addEventListener('scroll', () => {
    const maxScroll = document.body.scrollHeight - window.innerHeight;
    const progress = Math.min(window.scrollY / maxScroll, 1);

    // Send scroll position to Spline (0 to 1)
    spline.setVariable('scrollProgress', progress);
  });
});
```

In the Spline editor, create a variable called `scrollProgress` and bind it to animations.

---

## Loading States

Show a loader while the scene downloads:

```html
<div id="loader" style="position:absolute; inset:0; display:flex; align-items:center; justify-content:center; background:#111;">
  <p style="color:white;">Loading 3D scene...</p>
</div>
<canvas id="canvas3d" style="width:100vw; height:100vh; opacity:0; transition: opacity 0.5s;"></canvas>

<script type="module">
  import { Application } from 'https://esm.sh/@splinetool/runtime';

  const canvas = document.getElementById('canvas3d');
  const loader = document.getElementById('loader');
  const spline = new Application(canvas);

  spline.load('https://prod.spline.design/YOUR_ID/scene.splinecode')
    .then(() => {
      loader.style.display = 'none';
      canvas.style.opacity = '1';
    });
</script>
```

---

## Self-Hosting the Scene File

If you hit CORS issues, or want faster loading from your own CDN:

1. In Spline editor, click **Export**
2. Click **Download** to get the `.splinecode` file
3. Place it in your project's `public/` or `assets/` folder
4. Reference it locally:

```js
spline.load('/assets/my-scene.splinecode');
```

---

## Multiple Scenes on One Page

**Not recommended** for performance, but if you must:

```js
// Each scene needs its own canvas and Application instance
const canvas1 = document.getElementById('scene1');
const canvas2 = document.getElementById('scene2');

const app1 = new Application(canvas1);
const app2 = new Application(canvas2);

// Load sequentially to reduce GPU pressure
await app1.load('https://prod.spline.design/SCENE_1/scene.splinecode');
await app2.load('https://prod.spline.design/SCENE_2/scene.splinecode');
```

**Tips:**

- Load scenes sequentially, not in parallel
- Keep each scene very lightweight (under 50k polygons)
- Use `IntersectionObserver` to only load scenes when they're visible
