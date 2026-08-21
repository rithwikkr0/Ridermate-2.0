import React, { useState } from 'react';
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
  BatteryCharging,
  Gauge,
  Layers,
  FileCheck2
} from 'lucide-react';
import { CinematicScrollCanvas } from '../components/CinematicScrollCanvas';
import { InteractiveCockpitDemo } from '../components/InteractiveCockpitDemo';
import { FeatureCard } from '../components/FeatureCard';
import { getActiveDownloadUrl, getDownloadButtonLabel, downloadConfig } from '../config/downloadConfig';

export const HomePage: React.FC = () => {
  const [scrollProgress, setScrollProgress] = useState(0);

  const screenshots = [
    {
      src: '/screenshots/cockpit_dashboard.png',
      title: 'Cockpit Dashboard',
      subtitle: 'Live speedometer, battery telemetry, weather suitability score, and quick actions.',
    },
    {
      src: '/screenshots/navigation_ride.png',
      title: 'Turn Navigation & HUD',
      subtitle: 'High-contrast CartoDB Dark Matter maps with speed alerts and GPX trail recording.',
    },
    {
      src: '/screenshots/squads_community.png',
      title: 'Squads & Contact Matching',
      subtitle: 'Real-time pilot radar, group chats, and privacy-preserving SHA-256 phone matching.',
    },
    {
      src: '/screenshots/pilot_profile.png',
      title: 'Pilot Profile & Milestones',
      subtitle: 'XP progression from Novice to Legend, achievement badges, and safety history.',
    },
    {
      src: '/screenshots/memories_journal.png',
      title: 'Memories Journal',
      subtitle: 'Voice note captures, high-res ride photos, and interactive map memory pins.',
    },
  ];

  return (
    <div className="space-y-24 sm:space-y-32 pb-24 overflow-hidden">
      {/* ── 1. Hero & Cinematic Scroll Section ───────────────────────────── */}
      <section className="relative">
        <CinematicScrollCanvas
          onProgressUpdate={(p) => setScrollProgress(p)}
        />

        {/* Floating Hero Content Overlay */}
        <div className="absolute top-28 sm:top-36 left-0 right-0 z-20 pointer-events-none">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center space-y-6">
            <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full glass-panel border border-circuitOrange/40 text-xs font-mono text-circuitOrange shadow-2xl pointer-events-auto">
              <span className="w-2 h-2 rounded-full bg-circuitOrange animate-ping" />
              <span>CIRCUITRIDER 2.0 • HIGH-PERFORMANCE COCKPIT</span>
            </div>

            <h1 className="text-4xl sm:text-6xl lg:text-7xl font-extrabold tracking-tight text-white leading-[1.05] drop-shadow-2xl">
              Engineered for the Open Road. <br />
              <span className="bg-gradient-to-r from-circuitOrange via-circuitOrangeGlow to-amber-400 bg-clip-text text-transparent">
                RiderMate 2.0
              </span>
            </h1>

            <p className="text-base sm:text-xl text-onSurfaceVariant max-w-2xl mx-auto leading-relaxed drop-shadow">
              Turn-by-turn vector navigation, multi-axis crash detection SOS, Azure AI safety coaching, and privacy-preserving squad radar.
            </p>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4 pointer-events-auto">
              <a
                href={getActiveDownloadUrl()}
                className="w-full sm:w-auto inline-flex items-center justify-center gap-3 px-8 py-4 rounded-xl font-bold text-base text-white bg-gradient-to-r from-circuitOrange to-circuitOrangeGlow hover:scale-105 active:scale-95 transition-all shadow-2xl shadow-circuitOrange/50 hover:shadow-circuitOrange/70"
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
          </div>
        </div>
      </section>

      {/* ── 2. Interactive Cockpit Simulator ────────────────────────────── */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <InteractiveCockpitDemo />
      </section>

      {/* ── 3. Real In-App Screenshots Gallery ───────────────────────────── */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-10">
        <div className="text-center max-w-2xl mx-auto space-y-3">
          <span className="text-xs font-mono uppercase tracking-widest text-circuitOrange">
            DESIGNED FOR GLOVES & SUNLIGHT
          </span>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-white">
            High-Contrast Dark Glassmorphism
          </h2>
          <p className="text-sm sm:text-base text-onSurfaceVariant">
            Real production screens optimized for helmet visor glare and high-speed glanceability.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {screenshots.map((s, idx) => (
            <div
              key={idx}
              className="glass-panel glass-panel-hover rounded-2xl p-4 sm:p-5 border border-white/10 space-y-4 group overflow-hidden"
            >
              <div className="relative rounded-xl overflow-hidden bg-black/60 aspect-[9/16] max-h-96 flex items-center justify-center">
                <img
                  src={s.src}
                  alt={s.title}
                  loading="lazy"
                  className="w-full h-full object-cover object-top group-hover:scale-105 transition-transform duration-500"
                />
              </div>
              <div>
                <h3 className="text-base font-bold text-white group-hover:text-circuitOrange transition-colors">
                  {s.title}
                </h3>
                <p className="text-xs text-onSurfaceVariant mt-1 leading-relaxed">
                  {s.subtitle}
                </p>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* ── 4. Core Capabilities Deep Dive ──────────────────────────────── */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
        <div className="text-center max-w-3xl mx-auto space-y-4">
          <h2 className="text-xs font-mono uppercase tracking-widest text-circuitOrange">
            FEATURE HIGHLIGHTS
          </h2>
          <p className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
            Engineered from ground up for motorcycle riders.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8">
          <FeatureCard
            icon={Navigation}
            badge="OFFLINE MAPS"
            title="Turn Navigation & Vector HUD"
            description="Dynamic CartoDB Dark tiles with offline route caching, speed limit alerts, and GPX trail export."
            benefits={[
              "Instant theme-aware dark / light tile switching",
              "Live Haversine distance telemetry",
              "Turn-by-turn guidance banner"
            ]}
          />

          <FeatureCard
            icon={ShieldAlert}
            badge="HARDWARE SENSORS"
            title="Emergency SOS & Crash Heuristics"
            description="Multi-axis accelerometer impact detection with 15-second cancellable audio alarm and automated Azure SMS broadcast."
            benefits={[
              "15-second cancellable audio countdown",
              "Automated SMS dispatch with GPS location",
              "Direct 108 / 112 medical emergency dialer"
            ]}
            gradient="from-red-500/20 to-transparent"
          />

          <FeatureCard
            icon={Bot}
            badge="AZURE AI"
            title="AI Pre-Ride & Safety Coach"
            description="Real-time cockpit readiness scoring (0-100), weather suitability assessment, and defensive riding voice briefings."
            benefits={[
              "Dynamic cockpit readiness score (0-100)",
              "Voice briefing before departure",
              "Defensive coaching tips after every ride"
            ]}
            gradient="from-blue-500/20 to-transparent"
          />

          <FeatureCard
            icon={Wrench}
            badge="GARAGE INTELLIGENCE"
            title="Vehicle Lifecycle & Reminders"
            description="Motorcycle garage manager with automated Insurance and PUC expiry countdowns, service logs, and official challan tracking."
            benefits={[
              "Insurance & PUC expiry countdowns",
              "Digital document vault for RC and policies",
              "Fuel mileage and cost analytics"
            ]}
          />

          <FeatureCard
            icon={Users}
            badge="PRIVACY MESH"
            title="Squads & Cryptographic Matching"
            description="Discover fellow riders and coordinate group rides using cryptographic SHA-256 on-device phone hashing."
            benefits={[
              "Share referral codes with 1-click links",
              "Earn the 'Squad Recruiter' achievement badge",
              "Group chat & real-time squad map tracking"
            ]}
          />

          <FeatureCard
            icon={Award}
            badge="PILOT ROSTER"
            title="Rider Milestones & Leveling"
            description="Advance your pilot rank from Novice to Legend as you log safe rides, distance milestones, and community challenges."
            benefits={[
              "Idempotency engine prevents duplicate XP",
              "Weekly & weekend warrior challenges",
              "Local leaderboard & XP tracking"
            ]}
            gradient="from-amber-500/20 to-transparent"
          />
        </div>
      </section>

      {/* ── 5. Trust, Privacy & Local-First Architecture ────────────────── */}
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
                <ShieldAlert className="w-12 h-12 text-circuitOrange mb-3" />
                <span className="font-mono text-xs font-bold text-white uppercase">End-to-End</span>
                <span className="text-[11px] text-onSurfaceVariant mt-1">Verified & Hardened</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── 6. Final Call to Action ─────────────────────────────────────── */}
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
