# RiderMate v2.0 — Flutter Handoff & Design QA Report

## 1. Design System Overview
- **Brand Name:** RiderMate
- **Design Philosophy:** Kinetic Precision
- **Core Aesthetic:** Glassmorphism, Material 3 (M3) Logic, Layered Elevation.
- **Device Type:** Mobile (Flutter Universal)

## 2. Design Tokens
### Colors
- `surface`: #121414 (Dark), #FFFFFF (Light)
- `primary`: #ff6b00 (Circuit Orange)
- `accent`: #ffb693 (Soft Orange)
- `on-surface`: #E2E2E2 (High Contrast)
- `border`: white/10 (Dark Mode), black/5 (Light Mode)

### Typography
- **Headers:** Hanken Grotesk (Semi-Bold/Bold)
- **Body/Utility:** Inter (Regular/Medium)
- **Monospace:** JetBrains Mono (Label Caps, Stats)

### Spacing & Radius
- **Grid:** 8pt base grid.
- **Corner Radius:** 24px (Large Cards), 16px (Buttons/Small Cards), Full (Pills/Tabs).
- **Glass Blur:** 30px backdrop-filter.

## 3. Motion Tokens
- `entrance`: Ease-Out, 300ms, 20px slide-up.
- `interaction`: Spring (Stiffness: 300, Damping: 20).
- `ambient`: Neural Pulse (2000ms loop, 0.98 -> 1.02 scale).

## 4. Component Library Status
- [x] TopNav (Frosted)
- [x] BottomNav (Floating Capsule)
- [x] Telemetry Cards (Layered)
- [x] AI Assistant (3D Neural Orb)
- [x] Charts (Area/Bar Standardized)

## 5. Screen Inventory (120+ Screens)
- **Modules:** Auth, Onboarding, Dashboard, Nav, AI Copilot, Social, Safety, Journal, Settings.
- **Theme Parity:** 100% (Dark/Light/System Support).

## 6. Implementation Notes for Flutter
- Use `BackdropFilter` with `ImageFilter.blur` for glass effects.
- Implement custom `Painter` for neural shaders.
- Map `Design Tokens` to `ThemeData`.
- All icons sourced from Material Symbols (Rounded).
