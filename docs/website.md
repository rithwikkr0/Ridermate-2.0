# RiderMate 2.0 — Marketing & Support Website Documentation

## 1. Overview & Architecture

The RiderMate website is a high-performance, accessible, responsive single-page web portal designed to serve as the marketing hub, legal privacy compliance endpoint, and direct APK download distribution portal.

### Tech Stack & Rationale

| Layer | Technology | Rationale |
|---|---|---|
| **Framework** | **React 18 + Vite 6** | Ultra-fast build times, modular component hierarchy, and zero runtime overhead for static hosting. |
| **Styling** | **Tailwind CSS 3** | Utility-first styling matching RiderMate's dark glassmorphic design system (`#090A0D` background, `#FF6B00` Circuit Orange). |
| **3D Rendering** | **Three.js + React Three Fiber (`@react-three/fiber`, `@react-three/drei`)** | Interactive, GPU-accelerated 3D telemetry cockpit canvas that responds to cursor and orientation. |
| **Routing** | **React Router 7** | Client-side routing with clean URLs and Azure Static Web Apps `staticwebapp.config.json` navigation fallback. |
| **Hosting** | **Azure Static Web Apps (Free Tier)** | Global high-speed CDN, automated SSL certificates, custom domain binding, and zero-cost hosting. |

---

## 2. Pages & Routing Architecture

1. **`/` (Landing Page)**: Hero section with interactive 3D telemetry visualization, live telemetry stats, 6 core feature deep dives, security highlights, and download CTA.
2. **`/download` (Download Portal)**: Direct APK download button, Android sideloading instructions, file size metadata, and SHA-256 integrity verification checksum.
3. **`/join` (Referral Route)**: Dynamic referral landing route (`/join?ref=CODE`) highlighting the inviter's referral code with a 1-click copy button and download link.
4. **`/privacy` (Privacy Policy)**: Accessible, plain-language breakdown of permissions, foreground/background location tracking, local-first storage, and account deletion rights.
5. **`/data-safety` (Data Safety Declaration)**: Structured transparency matrix matching the Google Play Console Data Safety form.

---

## 3. How to Run Locally & Build

### Prerequisites
- Node.js `v20+` or `v24+`
- NPM `v10+`

### Development Server
```bash
cd website
npm install
npm run dev
```
Open `http://localhost:3000` in your browser.

### Production Build
```bash
cd website
npm run build
```
Build output is emitted to `website/dist/`.

---

## 4. Single-Config Switch: GitHub Release ➔ Google Play Store

All download URLs and distribution behaviors are controlled by a single configuration file:
**`website/src/config/downloadConfig.ts`**

```typescript
export const downloadConfig = {
  version: "2.0.0",
  buildNumber: 51524378,
  
  // Switch this single line when published on Play Store:
  // Options: 'github_release' | 'play_store' | 'direct_apk'
  activeDistribution: 'github_release', 

  links: {
    githubRelease: "https://github.com/rithwikkr0/Ridermate-2.0/releases/latest/download/app-debug.apk",
    playStore: "https://play.google.com/store/apps/details?id=com.ridermate.ridermate",
    directApk: "https://github.com/rithwikkr0/Ridermate-2.0/releases/download/v2.0.0/app-debug.apk",
    gitHubRepo: "https://github.com/rithwikkr0/Ridermate-2.0",
  },
};
```

When changing `activeDistribution: 'play_store'`, all download buttons, hero CTAs, and referral pages automatically switch to the Google Play Store link.

---

## 5. Deployment to Azure Static Web Apps

1. **Automated CI/CD**: Pushes to `main` trigger `.github/workflows/azure-static-web-apps.yml`.
2. **Azure Configuration**: Set the repository secret `AZURE_STATIC_WEB_APPS_API_TOKEN` obtained from the Azure Portal static web app resource.
3. **Subdomain**: The site is reachable at `https://<unique-app-name>.azurestaticapps.net` with free automated SSL.
4. **Custom Domain**: Under Azure Portal > Static Web App > Custom Domains, add your apex or `www` domain with a simple CNAME/TXT DNS record.

---

## 6. Accessibility & Performance Guardrails (WCAG 2.1 AA)

- **Prefers-Reduced-Motion**: `Hero3D.tsx` detects `prefers-reduced-motion` media queries and disables rotation and particle movement.
- **High Contrast**: Text colors meet WCAG 2.1 AA standards (minimum 4.5:1 contrast ratio against dark panels).
- **Keyboard Navigable**: All interactive buttons, cards, and links provide visible `:focus-visible` orange rings.
- **Semantic HTML**: Uses landmarks (`header`, `main`, `footer`, `nav`, `section`, `h1`-`h3`).
