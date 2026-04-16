---
name: site-teardown
description: "Reverse engineer any website into a complete build blueprint. Analyzes the HTML structure, fetches and extracts all animation/interaction code from the site's JavaScript, and pulls the complete design system from the CSS. Outputs a structured teardown document with tech stack, every visual effect and how it's implemented, design tokens, assets needed, and a section-by-section build plan. Use this skill whenever the user wants to analyze how a website was built, reverse engineer a site, clone or recreate a website, understand what tech stack or animations a site uses, do a site teardown, deconstruct a page, figure out how an effect works on a website, or says things like 'steal this website', 'break down this site', 'how did they build this', 'website blueprint', 'analyze this site for me', or gives you a URL and asks you to figure out how it works. Also trigger when the user pastes raw HTML source code and asks what's going on or how to recreate it."
---

# Site Teardown

Reverse engineer any website into a complete build blueprint — tech stack, every visual effect with implementation details, full design system, and a section-by-section build plan. The output should be thorough enough that someone could hand it to Claude Code in a fresh session and build a clone without ever visiting the original site.

## When This Skill Activates

**Activate when the user wants to:**

- Analyze how a website was built
- Reverse engineer or deconstruct a site
- Clone or recreate a website's design and animations
- Understand what tech stack, libraries, or animation techniques a site uses
- Get a build blueprint for a website they want to recreate
- Understand how a specific effect on a website works (and the site hasn't been analyzed yet)

**Example triggers:**

- "Tear down this site: <https://example.com>"
- "How did they build this website?"
- "Analyze this site for me"
- "Reverse engineer this page"
- "I want to steal this website's design"
- "Clone this site analysis"
- "Website blueprint for [URL]"
- "Break down this page"
- "Deconstruct this site"
- `/site-teardown`
- `/site-teardown [URL]`
- User pastes raw HTML and asks how to recreate it

## Pipeline

### Step 1 — Get the HTML

The HTML is the foundation. It tells you what's on the page — the elements, the classes, the structure, the image/video paths, the SVGs.

**If the user pastes raw HTML source code:**

- Use it directly. Pasted HTML is more complete than a WebFetch for large pages because WebFetch processes content through a sub-model that may summarize details.
- Scan the HTML and extract key structural information:
  - All section/component class names
  - Image and video source paths
  - SVG elements (logos, icons, decorative shapes)
  - Form structures
  - Navigation structure
  - Meta tags (author, description, title)
  - Any inline styles or inline scripts

**If the user only provides a URL:**

- Use WebFetch on the URL with this prompt: "Return the complete HTML structure of this page. Include all class names, element hierarchy, image/video src paths, SVG elements, meta tags, script src paths, stylesheet href paths, and any inline styles or scripts. Preserve the exact class names and data attributes. Do not summarize the structure — return as much detail as possible."
- Note to user: for the most complete analysis, they can paste the raw HTML (Ctrl+U → Ctrl+A → Ctrl+C on the page).

### Step 2 — Find the JS and CSS File Paths

From the HTML, locate the main application JavaScript and CSS files. These are what contain the actual behavior and styling.

**Look for:**

```html
<!-- CSS - usually in <head> -->
<link rel="stylesheet" href="/path/to/main.css">

<!-- JS - usually before </body> -->
<script src="/path/to/main.js"></script>
<script type="module" src="/dist/assets/app.js"></script>
```

**Filter out third-party scripts** — skip these, they're not the site's custom code:

- Google Tag Manager, Google Analytics, gtag
- Cookie consent (iubenda, OneTrust, CookieBot)
- reCAPTCHA, hCaptcha
- CDN-hosted libraries (cdnjs, unpkg, jsdelivr) — note what libraries they use but don't fetch them
- Social media widgets, chat widgets
- WordPress core scripts (`/wp-includes/js/`)

**Keep the main application files** — these are what you want:

- Files from `/dist/`, `/build/`, `/assets/`, `/static/`
- Files with names like `main.js`, `app.js`, `bundle.js`, `index.js`
- Same pattern for CSS: `main.css`, `app.css`, `style.css`, `styles.css`
- Modulepreload hints also point to important files: `<link rel="modulepreload" href="...">`

Construct the full URLs by combining the site's domain with the file paths.

### Step 3 — Fetch the JavaScript

Use WebFetch on the main JS file. The goal is to extract every interaction, animation, and behavior on the site.

Build the prompt dynamically using class names found in the HTML. Start with this base prompt and append the site-specific class names:

**Base prompt:**

```text
Extract ALL animation code, event listeners, scroll effects, mouse interactions,
click handlers, and GSAP/animation library usage from this JavaScript file.

Include:
- Every function that manipulates the DOM, changes styles, or responds to user input
- All ScrollTrigger/scroll-based animation configurations
- All timeline definitions and animation sequences
- All mousemove/mouseenter/mouseleave/click/touch handlers
- All class toggling and DOM manipulation
- All IntersectionObserver usage
- All CSS custom property manipulation
- All Lenis/locomotive/smooth scroll configurations
- All Barba.js/Swup/page transition code
- All slider/carousel/draggable configurations
- All parallax implementations
- All image sequence/frame animation logic
- All cursor/pointer customization
- All preloader/loading animations
- All lazy loading logic
- All form interaction handlers
- All accordion/toggle/menu animations
- Custom easing functions and timing values

Also look for any code targeting these class names from the HTML:
[INSERT COMMA-SEPARATED LIST OF KEY CLASS NAMES FROM THE HTML]

Return actual code snippets with context about what elements they target.
Do not summarize — return as much raw code as possible.
```

Replace the class name placeholder with real classes extracted from the HTML in Step 1. Focus on classes that suggest interactivity — things with words like: hero, animate, scroll, slide, reveal, split, parallax, hover, active, open, toggle, frame, moon, star, video, zoom, marquee, cursor, loader, transition, etc.

### Step 4 — Fetch the CSS

Use WebFetch on the main CSS file. The goal is to extract the complete design system.

Again, build the prompt dynamically using actual class names from the HTML:

**Base prompt:**

```text
Extract the COMPLETE design system from this CSS file:

Include:
- Every color value (hex, rgb, hsl, CSS custom properties)
- Every @font-face declaration with font-family names, src paths, weights, and styles
- Every font-family assignment and which elements use them
- Every @keyframes animation with full keyframe definitions
- Every CSS custom property (--variable) definition and usage
- Every media query breakpoint and what changes at each
- All transform and transition properties
- All position:fixed and position:sticky elements
- All z-index values and stacking context
- The spacing/sizing system (padding, margin, gap patterns)
- Border-radius values used across the site
- Box-shadow and text-shadow values
- Gradient definitions
- Mix-blend-mode and filter usage
- The responsive typography system (font sizes at different breakpoints)
- Any CSS animations or transitions on pseudo-elements (::before, ::after)
- Grid and flexbox layout patterns for major sections
- Any mask-image or clip-path usage
- The noise/grain/texture overlay implementation if present

Also extract all CSS rules for classes containing these terms:
[INSERT COMMA-SEPARATED LIST OF KEY CLASS NAME STEMS FROM THE HTML]

Return actual CSS rules and values. Do not summarize — return as much raw CSS as possible.
```

Replace the class name placeholder with stems extracted from the HTML. For example, if the HTML has `.home-hero__moon-inner`, include `hero`, `moon`. If it has `.circle-slider__wheel`, include `circle`, `slider`, `wheel`.

### Step 5 — Assemble the Teardown Document

Combine findings from all three sources (HTML, JS, CSS) into a structured markdown file.

**Save to:** The user's working directory at `research/YYYY-MM-DD-{site-slug}-teardown.md`

If the working directory doesn't have a `research/` folder, save to the current directory instead.

**Use this template:**

```markdown
# Site Teardown: {Site Name}

**URL:** {url}
**Built by:** {agency/developer if identifiable from meta tags or footer}
**Platform:** {WordPress/Next.js/custom/etc — inferred from HTML structure}
**Date analyzed:** {YYYY-MM-DD}

## Tech Stack (Confirmed from Source)

| Technology | Evidence | Purpose |
|---|---|---|
| {library} | {where you saw it — script tag, code reference, etc.} | {what it does on this site} |

## Design System

### Colors
| Name/Usage | Value |
|---|---|
| {Primary background} | {#hex} |

### Typography
| Role | Font Family | Weight | Letter-spacing | Sizes |
|---|---|---|---|---|
| {Headings} | {font name} | {weight} | {spacing} | {size range} |

Font files: {list actual font file paths if found in @font-face}

### Spacing System
{Describe the spacing approach — CSS custom properties, fluid sizing with min()/clamp(), fixed values, etc.}

### Responsive Approach
{Media query strategy — breakpoints, orientation-based, container queries, etc.}

## Effects Breakdown

| Effect | Implementation | Complexity | Cloneable? |
|---|---|---|---|
| {effect name} | {how it works — 1-2 sentences} | {Low/Med/High} | {Yes/Partially/Hard} |

## Implementation Details

### {Most Impressive Effect #1}

```text
{Detailed explanation of how it works}
{Code snippets from the JS/CSS fetch}
{The key insight that makes it work}
```

### {Most Impressive Effect #2}

```text
{Same structure}
```

{Repeat for each major effect worth detailing}

## Assets Needed to Recreate

1. **{Asset type}** — {description, suggested source (Midjourney prompt, stock site, generate with code, etc.)}

## Build Plan

### Recommended Stack

- {Framework}: {why}
- {Styling}: {why}
- {Animation library}: {why}
- {Other packages}: {why}

### NPM Packages

```bash
npm install {packages1} {package2} {package3}
```

### Section-by-Section Build Order

**Section 1: {name}**  

- {what it contains}
- {key interactions/animations}
- {implementation approach}

**Section 2: {name}**  

- {same structure}

{Continue for all sections}

## Notes

- {Any gotchas, premium plugins needed, licensing concerns}
- {Things that can't be cloned easily and suggested alternatives}
- {Performance considerations}

### Filling the Template — Guidance

When assembling the teardown, keep these principles in mind:

**Be specific, not vague.** "GSAP ScrollTrigger with scrub:true pinned to .hero, scaling from 1 to 0.3" is useful. "Uses scroll animations" is not. The person reading this needs to build it without seeing the original site.

**Include the "reveal" for each effect.** The most valuable part of a teardown is showing that an impressive-looking effect has a simple implementation. If the moon illumination is just 54 images swapped on mousemove, say that clearly. If the parallax is just `translateX(mouseX / 50)`, include that formula.

**Distinguish confirmed vs inferred.** If you found the exact GSAP config in the JS, say "confirmed from source." If you're inferring from HTML class names and general patterns, say "inferred" so the builder knows what's solid and what might need adjustment.

**Group effects by section.** The effects table gives the overview, but the implementation details should follow the page flow top-to-bottom so the builder can work section by section.

**Be practical about assets.** Don't just say "needs images." Say how many, what kind, suggest Midjourney prompts or stock photo search terms, and note if any can be generated with code (SVGs, noise textures, gradients).

## Common Patterns to Watch For

These are the most common "impressive-looking but simple" patterns found on award-winning sites:

- **Image sequences on scroll/mouse** — Preloaded frames, swap visibility based on input. Looks like video/3D, it's just images.
- **SplitText character reveals** — GSAP SplitText wraps each character in a span, then staggers their opacity/transform.
- **Parallax layers** — Multiple elements moving at different speeds on mousemove or scroll. Just different multipliers on transform.
- **Scroll-scrubbed animations** — GSAP ScrollTrigger with `scrub: true`. Ties any animation to scroll position.
- **CSS custom property animations** — JS updates a `--progress` variable, CSS uses `calc()` with it. Clean separation of behavior and style.
- **Smooth scrolling** — Lenis or Locomotive Scroll wrapping the page. Just a library init.
- **Page transitions** — Barba.js or Swup. Overlay fades in, content swaps, overlay fades out.
- **Noise/grain overlay** — A fixed div with a noise texture image and `mix-blend-mode: overlay`.
- **Custom cursors** — GSAP `quickSetter` tracking mouse position on a fixed element.
- **Marquee text** — CSS or GSAP infinite horizontal translation loop.
- **Magnetic buttons** — Element subtly follows cursor when hovering nearby. Just mousemove + transform on the button.
- **Reveal on scroll** — IntersectionObserver or ScrollTrigger adding a class, CSS handles the transition.
