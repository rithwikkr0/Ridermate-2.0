import React from 'react';
import { Link } from 'react-router-dom';
import {
  Download,
  Navigation,
  ShieldAlert,
  Bot,
  Wrench,
  Users,
  Award,
  Zap,
  CheckCircle2,
  Smartphone,
  Sparkles,
  ArrowRight,
  Radio,
  Lock,
  BatteryCharging
} from 'lucide-react';
import { Hero3D } from '../components/Hero3D';
import { FeatureCard } from '../components/FeatureCard';
import { getActiveDownloadUrl, getDownloadButtonLabel, downloadConfig } from '../config/downloadConfig';

export const HomePage: React.FC = () => {
  return (
    <div className="space-y-24 sm:space-y-32 pb-24 overflow-hidden">
      {/* ── 1. Hero Section ─────────────────────────────────────────────── */}
      <section className="relative min-h-[90vh] flex items-center pt-28 sm:pt-32 lg:pt-36">
        {/* Background ambient radial gradients */}
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-circuitOrange/15 rounded-full blur-[140px] pointer-events-none" />
        <div className="absolute top-1/3 right-10 w-[350px] h-[350px] bg-blue-500/10 rounded-full blur-[100px] pointer-events-none" />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 w-full">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
            {/* Left Column: Headlines & CTA */}
            <div className="lg:col-span-7 space-y-6 text-center lg:text-left">
              <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full glass-panel border border-circuitOrange/30 text-xs font-mono text-circuitOrange shadow-inner">
                <span className="w-2 h-2 rounded-full bg-circuitOrange animate-pulse" />
                <span>RIDERMATE 2.0 IS LIVE</span>
              </div>

              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight text-white leading-[1.1]">
                Your High-Performance <br />
                <span className="bg-gradient-to-r from-circuitOrange via-circuitOrangeGlow to-amber-400 bg-clip-text text-transparent">
                  Motorcycle Cockpit.
                </span>
              </h1>

              <p className="text-base sm:text-lg text-onSurfaceVariant max-w-2xl mx-auto lg:mx-0 leading-relaxed">
                Engineered for serious riders. Offline-first turn-by-turn navigation, real-time g-force crash detection SOS, Azure AI safety coaching, group squad radar, and comprehensive garage telemetry.
              </p>

              {/* Action Buttons */}
              <div className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4 pt-2">
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
                  <span>Installation & Checksum</span>
                  <ArrowRight className="w-4 h-4 text-circuitOrange" />
                </Link>
              </div>

              {/* Trust Badges */}
              <div className="pt-6 border-t border-white/5 grid grid-cols-3 gap-4 max-w-lg mx-auto lg:mx-0 text-left">
                <div>
                  <span className="block font-mono text-xl font-bold text-white">100%</span>
                  <span className="text-xs text-onSurfaceVariant">Offline Capable</span>
                </div>
                <div>
                  <span className="block font-mono text-xl font-bold text-white">0 ms</span>
                  <span className="text-xs text-onSurfaceVariant">Background Crash SOS</span>
                </div>
                <div>
                  <span className="block font-mono text-xl font-bold text-white">Zero</span>
                  <span className="text-xs text-onSurfaceVariant">Ad-Tracking</span>
                </div>
              </div>
            </div>

            {/* Right Column: 3D Interactive Centerpiece */}
            <div className="lg:col-span-5 relative">
              <div className="glass-panel rounded-3xl p-3 border border-white/10 relative overflow-hidden shadow-2xl">
                <Hero3D />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── 2. Live Telemetry Strip ────────────────────────────────────── */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="glass-panel rounded-2xl p-6 sm:p-8 border border-circuitOrange/20 shadow-xl relative">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
            <div className="space-y-1">
              <div className="flex items-center justify-center gap-2 text-circuitOrange mb-1">
                <Navigation className="w-5 h-5" />
                <span className="text-xs font-mono uppercase tracking-wider text-onSurfaceVariant">Navigation</span>
              </div>
              <p className="text-2xl font-bold text-white font-mono">CartoDB Dark</p>
              <p className="text-xs text-onSurfaceVariant">Dynamic theme-aware vector tiles</p>
            </div>

            <div className="space-y-1">
              <div className="flex items-center justify-center gap-2 text-circuitOrange mb-1">
                <ShieldAlert className="w-5 h-5" />
                <span className="text-xs font-mono uppercase tracking-wider text-onSurfaceVariant">Crash Detection</span>
              </div>
              <p className="text-2xl font-bold text-white font-mono">4.5G Threshold</p>
              <p className="text-xs text-onSurfaceVariant">Multi-axis sensor telemetry</p>
            </div>

            <div className="space-y-1">
              <div className="flex items-center justify-center gap-2 text-circuitOrange mb-1">
                <Bot className="w-5 h-5" />
                <span className="text-xs font-mono uppercase tracking-wider text-onSurfaceVariant">AI Safety Coach</span>
              </div>
              <p className="text-2xl font-bold text-white font-mono">Azure OpenAI</p>
              <p className="text-xs text-onSurfaceVariant">Pre-ride briefings & readiness</p>
            </div>

            <div className="space-y-1">
              <div className="flex items-center justify-center gap-2 text-circuitOrange mb-1">
                <Radio className="w-5 h-5" />
                <span className="text-xs font-mono uppercase tracking-wider text-onSurfaceVariant">Squad Radar</span>
              </div>
              <p className="text-2xl font-bold text-white font-mono">Live Sync</p>
              <p className="text-xs text-onSurfaceVariant">P2P contact match via SHA-256</p>
            </div>
          </div>
        </div>
      </section>

      {/* ── 3. Core Capabilities Deep Dive ──────────────────────────────── */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
        <div className="text-center max-w-3xl mx-auto space-y-4">
          <h2 className="text-xs font-mono uppercase tracking-widest text-circuitOrange">
            Feature Deep Dive
          </h2>
          <p className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
            Built from scratch for the demands of motorcycle riding.
          </p>
          <p className="text-sm sm:text-base text-onSurfaceVariant leading-relaxed">
            Every screen, algorithm, and background service is tailored for vibration resistance, glove touch ergonomics, and instant high-contrast readability.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8">
          <FeatureCard
            icon={Navigation}
            badge="OFFLINE MAPS"
            title="Turn-by-Turn Real Navigation"
            description="High-contrast CartoDB Dark Matter tiles optimized for sunlight readability and dark helmet visors with offline route caching."
            benefits={[
              "Instant dynamic dark / light mode tile switching",
              "Speed limit alerts & real-time telemetry HUD",
              "GPX ride export & GPX trail import"
            ]}
          />

          <FeatureCard
            icon={ShieldAlert}
            badge="REAL SENSORS"
            title="Emergency SOS & Crash Detection"
            description="Accelerometer-driven multi-axis high-G impact heuristics that automatically broadcast live GPS coordinates to emergency contacts."
            benefits={[
              "15-second cancellable audio countdown",
              "Automated Azure Communication Services SMS broadcast",
              "Instant 108 / 112 direct emergency dialer"
            ]}
            gradient="from-red-500/20 to-transparent"
          />

          <FeatureCard
            icon={Bot}
            badge="AZURE AI"
            title="AI Pre-Ride & Safety Coach"
            description="Real-time ride intelligence that evaluates tire temperatures, weather telemetry, riding habits, and previous safety violations."
            benefits={[
              "Dynamic cockpit readiness score (0-100)",
              "Voice briefing before departure",
              "Tailored riding tips after every trip"
            ]}
            gradient="from-blue-500/20 to-transparent"
          />

          <FeatureCard
            icon={Wrench}
            badge="GARAGE COCKPIT"
            title="Vehicle Intelligence & Reminders"
            description="Full lifecycle management for your motorcycle. Track maintenance logs, service intervals, fuel logs, and official challans."
            benefits={[
              "Automated Insurance and PUC expiry countdowns",
              "Document vault for RC & policy storage",
              "Fuel mileage and cost telemetry analytics"
            ]}
          />

          <FeatureCard
            icon={Users}
            badge="PRIVACY-FIRST"
            title="Squads & Contact-Based Matching"
            description="Find riders and join squads using cryptographic SHA-256 phone hashing. Your phone book never leaves your device in raw text."
            benefits={[
              "Invite friends with personal referral code",
              "Earn the 'Squad Recruiter' achievement badge",
              "Group chat & real-time squad map tracking"
            ]}
          />

          <FeatureCard
            icon={Award}
            badge="GAMIFICATION"
            title="Rider Milestones & Achievements"
            description="Level up your pilot profile from Novice to Legend as you complete safe rides, mileage milestones, and community challenges."
            benefits={[
              "No double-awarding idempotency engine",
              "Weekly & weekend warrior challenges",
              "Local leaderboard & XP tracking"
            ]}
            gradient="from-amber-500/20 to-transparent"
          />
        </div>
      </section>

      {/* ── 4. Architecture & Security Guarantee ────────────────────────── */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="glass-panel rounded-3xl p-8 sm:p-12 border border-white/10 relative overflow-hidden">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
            <div className="lg:col-span-8 space-y-4">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-md bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 text-xs font-mono">
                <Lock className="w-3.5 h-3.5" />
                <span>Zero-Trust Privacy Standard</span>
              </div>
              <h3 className="text-2xl sm:text-3xl font-extrabold text-white">
                Your riding telemetry stays in your hands.
              </h3>
              <p className="text-sm sm:text-base text-onSurfaceVariant leading-relaxed">
                RiderMate 2.0 utilizes an encrypted SQLite local-first database on your phone. When connected, synchronization with Microsoft Azure Cloud uses TLS 1.3 in-transit and AES-256 encryption at rest. We never sell riding location habits or personal profiles to data brokers.
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
                <ShieldAlert className="w-12 h-12 text-circuitOrange mb-3" />
                <span className="font-mono text-xs font-bold text-white uppercase">End-to-End</span>
                <span className="text-[11px] text-onSurfaceVariant mt-1">Verified & Hardened</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── 5. Final CTA Banner ────────────────────────────────────────── */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="relative rounded-3xl bg-gradient-to-br from-surfaceContainerHigh to-surface border border-circuitOrange/30 p-8 sm:p-14 text-center space-y-6 overflow-hidden shadow-2xl">
          <div className="absolute top-0 right-0 w-64 h-64 bg-circuitOrange/10 rounded-full blur-3xl pointer-events-none" />
          
          <h2 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
            Ready to elevate your motorcycle experience?
          </h2>
          
          <p className="text-sm sm:text-base text-onSurfaceVariant max-w-xl mx-auto">
            Download the Android APK now. Connect your bike, monitor service schedules, and explore routes with your squad.
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
