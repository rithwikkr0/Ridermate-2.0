---
name: RiderMate Cinematic Dark
colors:
  surface: '#121414'
  surface-dim: '#121414'
  surface-bright: '#38393a'
  surface-container-lowest: '#0d0e0f'
  surface-container-low: '#1a1c1c'
  surface-container: '#1e2020'
  surface-container-high: '#282a2b'
  surface-container-highest: '#333535'
  on-surface: '#e2e2e2'
  on-surface-variant: '#e2bfb0'
  inverse-surface: '#e2e2e2'
  inverse-on-surface: '#2f3131'
  outline: '#a98a7d'
  outline-variant: '#5a4136'
  surface-tint: '#ffb693'
  primary: '#ffb693'
  on-primary: '#561f00'
  primary-container: '#ff6b00'
  on-primary-container: '#572000'
  inverse-primary: '#a04100'
  secondary: '#c6c6c6'
  on-secondary: '#2f3131'
  secondary-container: '#454747'
  on-secondary-container: '#b5b5b5'
  tertiary: '#c6c6c6'
  on-tertiary: '#2f3131'
  tertiary-container: '#989999'
  on-tertiary-container: '#2f3131'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdbcc'
  primary-fixed-dim: '#ffb693'
  on-primary-fixed: '#351000'
  on-primary-fixed-variant: '#7a3000'
  secondary-fixed: '#e2e2e2'
  secondary-fixed-dim: '#c6c6c6'
  on-secondary-fixed: '#1a1c1c'
  on-secondary-fixed-variant: '#454747'
  tertiary-fixed: '#e2e2e2'
  tertiary-fixed-dim: '#c6c6c6'
  on-tertiary-fixed: '#1a1c1c'
  on-tertiary-fixed-variant: '#454747'
  background: '#121414'
  on-background: '#e2e2e2'
  surface-variant: '#333535'
  background-deep: '#0A0A0A'
  surface-glass: rgba(18, 20, 20, 0.6)
  surface-glass-elevated: rgba(18, 20, 20, 0.7)
  border-white-low: rgba(255, 255, 255, 0.1)
  glow-orange: rgba(255, 107, 0, 0.4)
typography:
  display-stat:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  stat-label:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 20px
  gutter: 16px
  unit: 4px
---

## Brand & Style

RiderMate evokes a high-performance, premium athletic aesthetic designed for the modern cyclist. The brand personality is **technical, focused, and moody**, mirroring the intensity of a dawn ride or the sleek engineering of carbon fiber equipment. 

The visual style is a sophisticated blend of **Glassmorphism** and **High-Contrast Dark Mode**. It utilizes deep charcoal surfaces, vibrant neon-orange accents, and multi-layered translucency to create a sense of immersion. The UI feels like a high-end telemetry dashboard, utilizing ambient glows and blurred backdrops to soften the technical data and create an "atmospheric" user experience.

## Colors

The palette is built on a "Total Dark" foundation using `#0A0A0A` to ensure maximum contrast for the primary accent.

- **Primary (`#ff6b00`):** A high-visibility "Signal Orange" used for active states, primary actions, and critical data points. It is often paired with an outer glow.
- **Surface Strategy:** Instead of solid grays, use semi-transparent variants of `#121414` with a blur to create depth.
- **Accents:** Secondary data utilizes "On-Surface-Variant" (`#e2bfb0`)—a muted, warm-tinted gray that keeps the interface feeling organic rather than clinical.
- **Background Gradients:** Apply subtle radial gradients (5% opacity Primary) to the background to break the flat black and simulate ambient lighting.

## Typography

The typographic system uses a three-tier font hierarchy to balance readability with a technical aesthetic:
- **Hanken Grotesk:** Used for high-impact displays and headlines. Its sharp, modern geometry conveys speed and precision.
- **Inter:** The workhorse for body text and status information, ensuring clarity in high-vibration environments (mobile usage).
- **JetBrains Mono:** Reserved for metadata, timestamps, and categories. The monospaced nature reinforces the "telemetry/data" feel of the app.

**Scale adjustments:** For mobile devices, `display-stat` should be capped at `32px` within bento-grid components to avoid overflow.

## Layout & Spacing

The system follows a **Fluid Content Canvas** approach with a maximum container width of `672px` (2xl) for readability on larger screens.

- **Grid:** On mobile, use a single-column stack with `20px` side margins. Inside cards, use a 2-column bento grid for stats.
- **Rhythm:** An 8pt spacing system is the baseline, but a tighter 4pt `unit` is used for internal component relationships (e.g., label-to-value distance).
- **Safe Areas:** The Top App Bar is fixed at `90px` height (including padding) to ensure clear separation from the status bar and OS-level interactions.
- **Horizontal Scrolling:** Lists of "Recent Rides" should use a `-20px` negative margin to bleed to the edge of the screen, with `snap-x` alignment.

## Elevation & Depth

Depth is communicated through **Refractive Glassmorphism** rather than traditional drop shadows.

1.  **Level 0 (Base):** Deep black `#0A0A0A` with subtle primary-colored radial glows.
2.  **Level 1 (Panels):** `glass-panel` style. `backdrop-blur(12px)`, `1px` border of `rgba(255,255,255,0.1)`.
3.  **Level 2 (Active/Elevated):** `glass-panel-elevated` style. Higher blur `(20px)`, slightly more opaque border, and a subtle `glow-orange` shadow to simulate light emission.
4.  **Level 3 (Navigation):** Bottom navigation uses a high-density blur `(30px)` to appear "floating" above all content.

## Shapes

The shape language is "Sport-Modern"—primarily utilizing large, comfortable radii with occasional full-pill shapes for interactive elements.

- **Cards/Bento Boxes:** Use `rounded-xl` (1.5rem / 24px) to create a premium, soft feel.
- **Buttons/Tabs:** Use `rounded-full` (9999px). The "Pill" shape is the standard for all primary touch targets.
- **Avatars/Icons:** Strict circles for profile images; icons within circular backgrounds for secondary status indicators.

## Components

### Buttons & FABs
Primary actions use a circular "FAB" style with a `primary-container` background and a heavy `glow-active` animation. Secondary buttons should be glass-based with low-opacity borders.

### Bento Grid Cards
Cards are the primary container. They must include a subtle `border-b` divider for headers and use `label-caps` for section titles.

### Bottom Navigation
A floating pill-shaped bar. Active states are indicated by a `primary/10` background pill and a color shift to `#ff6b00`.

### Data Visualization
Telemetry lines and elevation profiles should be rendered in `primary` with varying opacities. Backgrounds of cards can feature low-opacity (20%) images with `mix-blend-luminosity` to add texture without distracting from text.

### Status Indicators
Small, pill-shaped glass chips containing a 16px icon and `stat-label` text for environmental data (Weather, Battery, Time).