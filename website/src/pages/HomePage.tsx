import React from 'react';
import { Link } from 'react-router-dom';
import {
  Download,
  ShieldCheck,
  Zap,
  ArrowRight,
  Lock,
  Smartphone,
  CheckCircle2,
  ExternalLink,
  Sparkles
} from 'lucide-react';
import { CyberHeroCanvas } from '../components/CyberHeroCanvas';
import { CockpitSimulator } from '../components/CockpitSimulator';
import { ScreenshotShowcase } from '../components/ScreenshotShowcase';
import { BentoFeatures } from '../components/BentoFeatures';
import { getActiveDownloadUrl, getDownloadButtonLabel, downloadConfig } from '../config/downloadConfig';

export const HomePage: React.FC = () => {
  return (
    <div className="space-y-24 sm:space-y-32 pb-24 overflow-hidden">
      {/* ── 1. Hero Section (Glitch-Free Ambient 3D Canvas) ─────────────── */}
      <section className="relative min-h-[85vh] flex items-center pt-28 sm:pt-36">
        <CyberHeroCanvas />

        {/* Ambient Top Glow */}
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[550px] h-[550px] bg-circuitOrange/15 rounded-full blur-[140px] pointer-events-none" />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 w-full text-center space-y-8">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full glass-panel border border-circuitOrange/30 text-xs font-mono text-circuitOrange shadow-2xl">
            <span className="w-2 h-2 rounded-full bg-circuitOrange animate-ping" />
            <span>CIRCUITRIDER 2.0 • HIGH-PERFORMANCE MOTORCYCLE COCKPIT</span>
          </div>

          <div className="space-y-4 max-w-4xl mx-auto">
            <h1 className="text-4xl sm:text-6xl lg:text-7xl font-extrabold tracking-tight text-white leading-[1.08]">
              Engineered for the Open Road. <br />
              <span className="bg-gradient-to-r from-circuitOrange via-circuitOrangeGlow to-amber-400 bg-clip-text text-transparent">
                RiderMate 2.0
              </span>
            </h1>

            <p className="text-base sm:text-xl text-onSurfaceVariant max-w-2xl mx-auto leading-relaxed">
              Turn-by-turn vector navigation, multi-axis crash detection SOS, Azure AI defensive coaching, and privacy-preserving squad radar.
            </p>
          </div>

          {/* Primary Action Buttons */}
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-2">
            <a
              href={getActiveDownloadUrl()}
              className="w-full sm:w-auto inline-flex items-center justify-center gap-3 px-8 py-4 rounded-xl font-bold text-base text-white bg-gradient-to-r from-circuitOrange to-circuitOrangeGlow hover:scale-105 active:scale-95 transition-all shadow-xl shadow-circuitOrange/30 hover:shadow-circuitOrange/50"
            >
              <Download className="w-5 h-5" />
              <span>{getDownloadButtonLabel()}</span>
            </a>

            <Link
              to="/download"
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-4 rounded-xl font-semibold text-sm text-onSurface glass-panel glass-panel-hover"
            >
              <span>Release Info & Checksum</span>
              <ArrowRight className="w-4 h-4 text-circuitOrange" />
            </Link>
          </div>

          {/* Core Trust Pillars */}
          <div className="pt-8 border-t border-white/5 grid grid-cols-2 sm:grid-cols-4 gap-6 max-w-3xl mx-auto text-left">
            <div className="space-y-0.5">
              <span className="font-mono text-xl font-bold text-white">100%</span>
              <p className="text-xs text-onSurfaceVariant">Offline Capable Maps</p>
            </div>
            <div className="space-y-0.5">
              <span className="font-mono text-xl font-bold text-white">4.5G</span>
              <p className="text-xs text-onSurfaceVariant">Impact Crash Alert</p>
            </div>
            <div className="space-y-0.5">
              <span className="font-mono text-xl font-bold text-white">SHA-256</span>
              <p className="text-xs text-onSurfaceVariant">Private Squad Mesh</p>
            </div>
            <div className="space-y-0.5">
              <span className="font-mono text-xl font-bold text-white">Zero</span>
              <p className="text-xs text-onSurfaceVariant">Third-Party Tracking</p>
            </div>
          </div>
        </div>
      </section>

      {/* ── 2. Live Interactive Cockpit Simulator ───────────────────────── */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-6">
        <div className="text-center max-w-2xl mx-auto space-y-2">
          <span className="text-xs font-mono uppercase tracking-widest text-circuitOrange">
            INTERACTIVE PREVIEW
          </span>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-white">
            Experience the Digital Cockpit
          </h2>
          <p className="text-sm text-onSurfaceVariant">
            Switch between digital telemetry modes and test live cockpit alerts.
          </p>
        </div>

        <CockpitSimulator />
      </section>

      {/* ── 3. Real In-App Screenshots Gallery ───────────────────────────── */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
        <div className="text-center max-w-2xl mx-auto space-y-2">
          <span className="text-xs font-mono uppercase tracking-widest text-circuitOrange">
            DESIGNED FOR SUNLIGHT & GLOVES
          </span>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-white">
            High-Contrast Dark Glassmorphism
          </h2>
          <p className="text-sm text-onSurfaceVariant">
            Real production screens optimized for high-speed glanceability and dark helmet visors.
          </p>
        </div>

        <ScreenshotShowcase />
      </section>

      {/* ── 4. Core Features Bento Matrix ───────────────────────────────── */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
        <div className="text-center max-w-3xl mx-auto space-y-2">
          <h2 className="text-xs font-mono uppercase tracking-widest text-circuitOrange">
            FEATURE MODULES
          </h2>
          <p className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
            Comprehensive Intelligence for Every Ride
          </p>
        </div>

        <BentoFeatures />
      </section>

      {/* ── 5. Security & Privacy Guarantee ─────────────────────────────── */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="glass-panel rounded-3xl p-8 sm:p-12 border border-white/10 relative overflow-hidden">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
            <div className="lg:col-span-8 space-y-4">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-md bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 text-xs font-mono">
                <Lock className="w-3.5 h-3.5" />
                <span>Zero-Trust Privacy Standard</span>
              </div>
              <h3 className="text-2xl sm:text-3xl font-extrabold text-white">
                Your riding telemetry stays on your phone.
              </h3>
              <p className="text-sm sm:text-base text-onSurfaceVariant leading-relaxed">
                RiderMate 2.0 utilizes an encrypted SQLite local-first database on your device. When cloud sync is enabled, data transmitted to RiderMate Cloud (Microsoft Azure App Service and Azure Database for PostgreSQL) is secured via TLS 1.3 in-transit and AES-256 encryption at rest. We never sell riding location habits or personal profiles to data brokers.
              </p>
              <div className="flex flex-wrap gap-4 pt-2">
                <Link
                  to="/privacy"
                  className="inline-flex items-center gap-2 text-xs font-semibold text-circuitOrange hover:underline"
                >
                  <span>Read Full Privacy Policy</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </Link>
                <Link
                  to="/data-safety"
                  className="inline-flex items-center gap-2 text-xs font-semibold text-circuitOrange hover:underline"
                >
                  <span>View Google Play Data Safety Declaration</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </Link>
              </div>
            </div>

            <div className="lg:col-span-4 flex justify-center">
              <div className="w-48 h-48 rounded-2xl bg-circuitOrange/10 border border-circuitOrange/30 flex flex-col items-center justify-center p-6 text-center shadow-2xl">
                <ShieldCheck className="w-12 h-12 text-circuitOrange mb-3" />
                <span className="font-mono text-xs font-bold text-white uppercase">End-to-End</span>
                <span className="text-[11px] text-onSurfaceVariant mt-1">Verified & Hardened</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── 6. Bottom Call to Action ────────────────────────────────────── */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="relative rounded-3xl bg-gradient-to-br from-surfaceContainerHigh to-surface border border-circuitOrange/30 p-8 sm:p-14 text-center space-y-6 overflow-hidden shadow-2xl">
          <div className="absolute top-0 right-0 w-64 h-64 bg-circuitOrange/10 rounded-full blur-3xl pointer-events-none" />

          <h2 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
            Ready to mount your high-performance cockpit?
          </h2>

          <p className="text-sm sm:text-base text-onSurfaceVariant max-w-xl mx-auto">
            Download the official Android release directly from GitHub Releases. Connect your bike and ride with your squad.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4">
            <a
              href={getActiveDownloadUrl()}
              className="w-full sm:w-auto inline-flex items-center justify-center gap-3 px-8 py-4 rounded-xl font-bold text-base text-white bg-circuitOrange hover:bg-circuitOrangeGlow hover:scale-105 active:scale-95 transition-all shadow-xl shadow-circuitOrange/30"
            >
              <Download className="w-5 h-5" />
              <span>{getDownloadButtonLabel()}</span>
            </a>

            <Link
              to="/join"
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-4 rounded-xl font-semibold text-sm text-onSurface glass-panel glass-panel-hover"
            >
              <span>Have a referral code? Join here</span>
              <ArrowRight className="w-4 h-4 text-circuitOrange" />
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
};
