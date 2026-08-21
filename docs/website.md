# RiderMate 2.0 — Marketing & Support Website Documentation

## 1. Overview & Architecture

The RiderMate website is a high-performance single-page web portal designed to serve as the marketing hub, legal privacy compliance endpoint, and direct APK download distribution portal.

### Tech Stack & Rationale

| Layer | Technology | Rationale |
|---|---|---|
| **Framework** | **React 18 + Vite 6** | Ultra-fast build times, modular component hierarchy, and zero runtime overhead for static hosting. |
| **Styling** | **Tailwind CSS 3** | Utility-first styling matching RiderMate's dark glassmorphic design system (`#090A0D` background, `#FF6B00` Circuit Orange). |
| **Scroll Experience** | **HTML5 Canvas + GSAP ScrollTrigger** | Winding mountain road cockpit simulation scrubbing with scroll progress, dynamic speedometer, lean angle indicator, and altitude elevation. |
| **3D Rendering** | **Three.js + React Three Fiber (`@react-three/fiber`, `@react-three/drei`)** | Interactive, GPU-accelerated 3D telemetry cockpit canvas that responds to cursor and orientation. |
| **Routing** | **React Router 7** | Client-side routing with clean URLs and Azure Static Web Apps `staticwebapp.config.json` navigation fallback. |
| **Hosting** | **Azure Static Web Apps (Free Tier)** | Global high-speed CDN, automated SSL certificates, custom domain binding, and zero-cost hosting. |

---

## 2. Pages & Routing Architecture

1. **`/` (Landing Page)**: Hero section with cinematic scroll-scrubbed mountain road telemetry sequence, interactive 4-mode cockpit simulator (Turn Navigation, AI Copilot, Crash SOS, Squad Radar), real screenshots gallery, 6 feature deep dives, security highlights, and download CTA.
2. **`/download` (Download Portal)**: Direct APK download button from GitHub Release `v2.0.0-tester`, Android sideloading instructions, file size metadata (~160.4 MB), and SHA-256 integrity verification checksum.
3. **`/join` (Referral Route)**: Dynamic referral landing route (`/join?ref=CODE`) highlighting the inviter's referral code with a 1-click copy button and download link.
4. **`/privacy` (Privacy Policy)**: Accessible, plain-language breakdown of permissions, foreground/background location tracking, local-first storage, and account deletion rights.
5. **`/data-safety` (Data Safety Declaration)**: Structured transparency matrix matching the Google Play Console Data Safety form.

---

## 3. Single-Config Switch: GitHub Release ➔ Google Play Store

All download URLs and distribution behaviors are controlled by a single configuration file:  
**`website/src/config/downloadConfig.ts`**

```typescript
export const downloadConfig = {
  appName: "RiderMate 2.0",
  brandTagline: "CircuitRider — The High-Performance Motorcycle Cockpit",
  version: "2.0.0",
  buildNumber: 51530205,
  
  // Switch this single line when published on Play Store:
  // Options: 'github_release' | 'play_store' | 'direct_apk'
  activeDistribution: 'github_release', 

  links: {
    githubRelease: "https://github.com/rithwikkr0/Ridermate-2.0/releases/download/v2.0.0-tester/app-debug.apk",
    playStore: "https://play.google.com/store/apps/details?id=com.ridermate.ridermate",
    directApk: "https://github.com/rithwikkr0/Ridermate-2.0/releases/download/v2.0.0-tester/app-debug.apk",
    gitHubRepo: "https://github.com/rithwikkr0/Ridermate-2.0",
    gitHubReleasePage: "https://github.com/rithwikkr0/Ridermate-2.0/releases/tag/v2.0.0-tester",
  },
};
```

---

## 4. Automated QA Verification

Run the automated live QA suite anytime with:
```bash
node website/scripts/run_qa_audit.mjs
```
Verifies 11 live route endpoints, asset deliveries, and 160MB APK download streams.
