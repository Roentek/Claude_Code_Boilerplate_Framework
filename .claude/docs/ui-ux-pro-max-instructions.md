# UI/UX Pro Max — Design Intelligence Instructions

> Source: [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) · v2.5.0 · MIT  
> This file is the authoritative reference for the `ui-ux-pro-max` skill in this project.

---

## What This Skill Provides

A searchable design intelligence database covering:

- **67 UI Styles** — Glassmorphism, Minimalism, Brutalism, Neumorphism, Bento Grid, Dark Mode, Claymorphism, Skeuomorphism, Flat Design, AI-native UI, and more
- **161 Color Palettes** — Aligned to industry-specific product types (SaaS, Fintech, Healthcare, E-commerce, Creative, Lifestyle, Emerging Tech)
- **57 Font Pairings** — Google Fonts integrations with heading/body personality matching
- **99 UX Guidelines** — Accessibility, Touch & Interaction, Performance, Animation, Navigation, Forms & Feedback
- **25 Chart Types** — With library recommendations and accessible color rules
- **161 Industry Reasoning Rules** — Covering Tech & SaaS, Finance, Healthcare, E-commerce, Services, Creative, Lifestyle, Emerging Tech
- **15+ Tech Stacks** — React, Next.js, Vue, Nuxt, Svelte, Astro, Angular, SwiftUI, React Native, Flutter, HTML+Tailwind, shadcn/ui, Jetpack Compose

---

## When to Apply This Skill

### Must Use

- Designing new pages (Landing Page, Dashboard, Admin, SaaS, Mobile App)
- Creating or refactoring UI components (buttons, modals, forms, tables, charts)
- Choosing color schemes, typography systems, spacing standards, or layout systems
- Reviewing UI code for user experience, accessibility, or visual consistency
- Implementing navigation structures, animations, or responsive behavior
- Making product-level design decisions (style, information hierarchy, brand expression)
- Improving perceived quality, clarity, or usability of interfaces

### Recommended

- UI looks "not professional enough" but the reason is unclear
- Receiving feedback on usability or experience
- Pre-launch UI quality optimization
- Aligning cross-platform design (Web / iOS / Android)
- Building design systems or reusable component libraries

### Skip

- Pure backend logic development
- Only involving API or database design
- Performance optimization unrelated to the interface
- Infrastructure or DevOps work
- Non-visual scripts or automation tasks

**Decision rule:** If the task changes how a feature **looks, feels, moves, or is interacted with** — use this skill.

---

## Prerequisites

Python 3.x is required (no external dependencies):

```bash
python3 --version || python --version
```

The skill's search scripts live at: `.claude/skills/ui-ux-pro-max/scripts/search.py`

---

## Core Workflow

Use this order for every frontend task:

### Step 1: Analyze User Requirements

Extract from the user request:

- **Product type** — SaaS, e-commerce, portfolio, healthcare, fintech, entertainment, etc.
- **Target audience** — consumer, enterprise, age group, usage context
- **Style keywords** — playful, vibrant, minimal, dark mode, content-first, immersive
- **Tech stack** — which framework/platform is in use

### Step 2: Generate Design System (REQUIRED)

Always start with `--design-system` to get full recommendations with reasoning:

```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<product_type> <industry> <keywords>" --design-system [-p "Project Name"]
```

This runs parallel searches across product, style, color, landing, and typography domains, applies industry-specific reasoning rules, and returns:

- Recommended pattern, style, colors, typography, and effects
- Anti-patterns to avoid
- A pre-delivery checklist

**Example:**

```bash
python3 skills/ui-ux-pro-max/scripts/search.py "beauty spa wellness service" --design-system -p "Serenity Spa"
```

#### Persist the Design System (optional but recommended)

```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system --persist -p "Project Name"
```

Creates:

- `design-system/MASTER.md` — Global Source of Truth
- `design-system/pages/` — Page-specific overrides

Page override:

```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system --persist -p "Project Name" --page "dashboard"
```

**Hierarchical retrieval prompt:**

```text
I am building the [Page Name] page. Please read design-system/MASTER.md.
Also check if design-system/pages/[page-name].md exists.
If the page file exists, prioritize its rules.
If not, use the Master rules exclusively.
```

### Step 3: Supplement with Domain Searches

```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<keyword>" --domain <domain> [-n <max_results>]
```

| Need | Domain | Example |
| ------ | -------- | --------- |
| Product type patterns | `product` | `--domain product "entertainment social"` |
| Style options | `style` | `--domain style "glassmorphism dark"` |
| Color palettes | `color` | `--domain color "entertainment vibrant"` |
| Font pairings | `typography` | `--domain typography "playful modern"` |
| Chart recommendations | `chart` | `--domain chart "real-time dashboard"` |
| UX best practices | `ux` | `--domain ux "animation accessibility"` |
| Google Fonts lookup | `google-fonts` | `--domain google-fonts "sans serif variable"` — browse catalog at [`google fonts`](https://fonts.google.com/) |
| Landing page structure | `landing` | `--domain landing "hero social-proof"` |
| React/Next.js perf | `react` | `--domain react "rerender memo list"` |
| App interface a11y | `web` | `--domain web "accessibilityLabel touch safe-areas"` |
| AI prompt / CSS keywords | `prompt` | `--domain prompt "minimalism"` |

### Step 4: Stack-Specific Guidelines

```bash
python3 skills/ui-ux-pro-max/scripts/search.py "<keyword>" --stack <stack>
```

Available stacks: `html-tailwind`, `react`, `nextjs`, `astro`, `vue`, `nuxtjs`, `nuxt-ui`, `svelte`, `swiftui`, `react-native`, `flutter`, `shadcn`, `jetpack-compose`

---

## Scenario Routing

| Scenario | Trigger Examples | Start From |
| ---------- | ----------------- | ------------ |
| New project / page | "Build a landing page", "Build a dashboard" | Step 1 → Step 2 |
| New component | "Create a pricing card", "Add a modal" | Step 3 (domain: style, ux) |
| Choose style / color / font | "What style fits a fintech app?" | Step 2 |
| Review existing UI | "Review this page for UX issues" | Quick Reference checklist |
| Fix a UI bug | "Button hover is broken" | Quick Reference → relevant section |
| Improve / optimize | "Make this faster", "Improve mobile experience" | Step 3 (domain: ux) |
| Implement dark mode | "Add dark mode support" | Step 3 (domain: style "dark mode") |
| Add charts / data viz | "Add an analytics dashboard chart" | Step 3 (domain: chart) |
| Stack best practices | "React performance tips" | Step 4 (stack search) |

---

## Output Formats

```bash
# ASCII box (default) — best for terminal display
python3 skills/ui-ux-pro-max/scripts/search.py "fintech crypto" --design-system

# Markdown — best for documentation
python3 skills/ui-ux-pro-max/scripts/search.py "fintech crypto" --design-system -f markdown
```

---

## Rule Categories by Priority

| Priority | Category | Impact | Domain | Key Checks | Anti-Patterns |
| ---------- | ---------- | -------- | -------- | ------------ | --------------- |
| 1 | Accessibility | CRITICAL | `ux` | Contrast 4.5:1, Alt text, Keyboard nav, Aria-labels | Removing focus rings, Icon-only buttons without labels |
| 2 | Touch & Interaction | CRITICAL | `ux` | Min size 44×44px, 8px+ spacing, Loading feedback | Reliance on hover only, Instant state changes (0ms) |
| 3 | Performance | HIGH | `ux` | WebP/AVIF, Lazy loading, Reserve space (CLS < 0.1) | Layout thrashing, Cumulative Layout Shift |
| 4 | Style Selection | HIGH | `style`, `product` | Match product type, Consistency, SVG icons (no emoji) | Mixing flat & skeuomorphic randomly, Emoji as icons |
| 5 | Layout & Responsive | HIGH | `ux` | Mobile-first breakpoints, Viewport meta, No horizontal scroll | Horizontal scroll, Fixed px widths, Disable zoom |
| 6 | Typography & Color | MEDIUM | `typography`, `color` | Base 16px, Line-height 1.5, Semantic color tokens | Text < 12px body, Gray-on-gray, Raw hex in components |
| 7 | Animation | MEDIUM | `ux` | Duration 150–300ms, Motion conveys meaning | Decorative-only animation, Animating width/height |
| 8 | Forms & Feedback | MEDIUM | `ux` | Visible labels, Error near field, Progressive disclosure | Placeholder-only label, Errors only at top |
| 9 | Navigation Patterns | HIGH | `ux` | Predictable back, Bottom nav ≤5, Deep linking | Overloaded nav, Broken back behavior |
| 10 | Charts & Data | LOW | `chart` | Legends, Tooltips, Accessible colors | Relying on color alone to convey meaning |

---

## Quick Reference by Category

### 1. Accessibility (CRITICAL)

- Minimum 4.5:1 contrast ratio (large text: 3:1)
- Visible focus rings on all interactive elements (2–4px)
- Descriptive alt text for all meaningful images
- `aria-label` for icon-only buttons
- Tab order matches visual order; full keyboard support
- `label` with `for` attribute on all form fields
- Skip-to-main-content link for keyboard users
- Sequential `h1→h6` heading hierarchy (no skipping)
- Never convey information by color alone — add icon or text
- Support `prefers-reduced-motion` and system text scaling
- Meaningful `accessibilityLabel`/`accessibilityHint` for screen readers
- Provide cancel/back in all modals and multi-step flows

### 2. Touch & Interaction (CRITICAL)

- Min 44×44pt (Apple) / 48×48dp (Material) touch targets
- 8px+ gap between adjacent touch targets
- Use tap/click for primary interactions — never hover-only
- Disable buttons during async operations; show spinner
- `cursor-pointer` on all clickable web elements
- `touch-action: manipulation` to eliminate 300ms tap delay
- Haptic feedback for confirmations (don't overuse)
- Keep primary touch targets away from notch, gesture bar, screen edges
- Provide visible controls for all gesture-only interactions

### 3. Performance (HIGH)

- Use WebP/AVIF with `srcset/sizes`; declare `width`/`height`
- `font-display: swap/optional` to prevent invisible text (FOIT)
- Inline critical CSS; lazy-load below-the-fold components
- Split code by route/feature (React Suspense / Next.js dynamic)
- Load third-party scripts `async`/`defer`
- Virtualize lists with 50+ items
- Keep per-frame work under ~16ms for 60fps
- Skeleton screens for operations >1s
- Input latency under ~100ms

### 4. Style Selection (HIGH)

- Match style to product type (use `--design-system`)
- Use same style system across all pages — no mixing
- SVG icons only (Heroicons, Lucide) — no emojis as UI icons
- Choose palette from product/industry (`--domain color`)
- One icon set/visual language across the entire product
- Each screen has exactly one primary CTA; others are subordinate

### 5. Layout & Responsive (HIGH)

- `width=device-width, initial-scale=1` — never disable zoom
- Mobile-first design; scale up to tablet and desktop
- Systematic breakpoints: 375 / 768 / 1024 / 1440
- Minimum 16px body text on mobile (prevents iOS auto-zoom)
- No horizontal scroll on mobile
- 4pt/8dp incremental spacing system
- Consistent `max-w-6xl` / `max-w-7xl` on desktop
- `min-h-dvh` instead of `100vh` on mobile
- Keep layout readable in landscape orientation

### 6. Typography & Color (MEDIUM)

- Line-height 1.5–1.75 for body text
- 65–75 characters per line on desktop; 35–60 on mobile
- Semantic color tokens only — no raw hex in components
- Font-weight hierarchy: Bold headings (600–700), Regular body (400), Medium labels (500)
- Dark mode: desaturated/lighter tonal variants, not inverted colors
- Tabular/monospaced figures for data columns, prices, timers

### 7. Animation (MEDIUM)

- Micro-interactions: 150–300ms; complex transitions ≤400ms
- Animate `transform` and `opacity` only — never `width`/`height`/`top`/`left`
- Ease-out for entering; ease-in for exiting — never linear for UI
- Every animation must express cause-effect — no purely decorative motion
- Spring/physics-based curves preferred for natural feel
- Exit animations ~60–70% of enter duration
- Stagger list items 30–50ms apart
- All animations interruptible; UI stays interactive during animation
- Respect `prefers-reduced-motion`

### 8. Forms & Feedback (MEDIUM)

- Visible label per input (never placeholder-only)
- Show errors below the related field
- Loading → success/error state on submit
- Mark required fields (asterisk)
- Helpful empty states with next action
- Auto-dismiss toasts in 3–5s
- Confirm before destructive actions
- Validate on blur (not keystroke)
- Semantic input types (`email`, `tel`, `number`) for correct mobile keyboards
- Password show/hide toggle
- Undo support for destructive/bulk actions
- Error messages must state cause + how to fix

### 9. Navigation Patterns (HIGH)

- Bottom navigation max 5 items; use labels with icons
- Back navigation must be predictable and restore scroll/state
- All key screens must be reachable via deep link
- Current location must be visually highlighted in navigation
- Modals must offer a clear close/dismiss affordance
- Support system gesture navigation (iOS swipe-back, Android predictive back)
- Never mix Tab + Sidebar + Bottom Nav at the same hierarchy level
- Adaptive: sidebar on ≥1024px; bottom/top nav on mobile

### 10. Charts & Data (LOW)

- Match chart type to data: trend → line, comparison → bar, proportion → pie/donut
- Accessible color palettes; supplement with patterns/textures for colorblind users
- Always show legend; provide table alternative for screen readers
- Tooltips on hover (web) / tap (mobile)
- Label axes with units; avoid rotated labels on mobile
- Charts must reflow on small screens
- Meaningful empty state ("No data yet" + guidance) — not a blank chart
- Avoid pie/donut for >5 categories; switch to bar chart

---

## Pre-Delivery Checklist

Run `--domain ux "animation accessibility z-index loading"` as a final UX validation pass before implementation.

### Visual Quality

- [ ] No emojis used as icons (SVG only)
- [ ] All icons from a consistent icon family and style
- [ ] Official brand assets used with correct proportions
- [ ] Pressed-state visuals do not shift layout bounds or cause jitter
- [ ] Semantic theme tokens used (no ad-hoc hardcoded colors)

### Interaction

- [ ] All tappable elements provide clear pressed feedback
- [ ] Touch targets ≥44×44pt (iOS) / ≥48×48dp (Android)
- [ ] Micro-interaction timing 150–300ms with native-feeling easing
- [ ] Disabled states are visually clear and non-interactive
- [ ] Screen reader focus order matches visual order with descriptive labels
- [ ] Gesture regions avoid nested/conflicting interactions

### Light/Dark Mode

- [ ] Primary text contrast ≥4.5:1 in both modes
- [ ] Secondary text contrast ≥3:1 in both modes
- [ ] Dividers/borders distinguishable in both modes
- [ ] Modal/drawer scrim opacity 40–60% black
- [ ] Both themes tested before delivery

### Layout

- [ ] Safe areas respected for headers, tab bars, and bottom CTAs
- [ ] Scroll content not hidden behind fixed/sticky bars
- [ ] Verified on 375px small phone, large phone, and tablet (portrait + landscape)
- [ ] Horizontal insets/gutters adapt by device size and orientation
- [ ] 4/8dp spacing rhythm maintained throughout
- [ ] Long-form text measure readable on larger devices

### Accessibility

- [ ] All meaningful images/icons have accessibility labels
- [ ] Form fields have labels, hints, and clear error messages
- [ ] Color is not the only indicator for any state or meaning
- [ ] Reduced motion and dynamic text size supported without layout breakage
- [ ] Accessibility traits/roles/states announced correctly

---

## Common Sticking Points

| Problem | Solution |
| --------- | ---------- |
| Can't decide on style/color | Re-run `--design-system` with different keywords |
| Dark mode contrast issues | Quick Reference §6: `color-dark-mode` + `color-accessible-pairs` |
| Animations feel unnatural | Quick Reference §7: `spring-physics` + `easing` + `exit-faster-than-enter` |
| Form UX is poor | Quick Reference §8: `inline-validation` + `error-clarity` + `focus-management` |
| Navigation feels confusing | Quick Reference §9: `nav-hierarchy` + `bottom-nav-limit` + `back-behavior` |
| Layout breaks on small screens | Quick Reference §5: `mobile-first` + `breakpoint-consistency` |
| Performance / jank | Quick Reference §3: `virtualize-lists` + `main-thread-budget` + `debounce-throttle` |

---

## Icons & Visual Elements Reference

| Rule | Standard | Avoid |
| ------ | ---------- | ------- |
| No Emoji as Icons | Vector-based icons (Lucide, Heroicons, react-native-vector-icons) | Emojis (🎨 🚀 ⚙️) for navigation or system controls |
| Vector-Only Assets | SVG or platform vector icons | Raster PNG icons that blur or pixelate |
| Stable Interaction States | Color/opacity/elevation transitions for press | Layout-shifting transforms that move surrounding content |
| Correct Brand Logos | Official brand assets, correct proportions | Guessing paths, recoloring unofficially |
| Consistent Icon Sizing | Design tokens (icon-sm, icon-md=24pt, icon-lg) | Arbitrary mixing of 20pt / 24pt / 28pt |
| Stroke Consistency | Consistent stroke width per visual layer | Mixing thick and thin strokes arbitrarily |
| Filled vs Outline Discipline | One icon style per hierarchy level | Mixing filled and outline at same hierarchy level |
| Touch Target Minimum | ≥44×44pt interactive area (use `hitSlop` if icon is smaller) | Small icons without expanded tap area |

---

## Usage Notes for This Project

- The skill is installed at `.claude/skills/ui-ux-pro-max/` via the `ui-ux-pro-max-skill` marketplace
- Search scripts are at `.claude/skills/ui-ux-pro-max/scripts/search.py`
- Python 3.x required — no pip installs needed
- This file lives in `.claude/docs/` — **not auto-loaded**. Read on demand when doing frontend work.
- Always invoke `--design-system` before writing any UI code
- For web projects in this repo, default stack is `html-tailwind` unless specified otherwise
