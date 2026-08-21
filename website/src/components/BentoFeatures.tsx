import React from 'react';
import { Navigation, ShieldAlert, Bot, Wrench, Users, Award, Radio, CheckCircle2, Lock, ArrowRight } from 'lucide-react';
import { Link } from 'react-router-dom';

export const BentoFeatures: React.FC = () => {
  return (
    <div className="w-full max-w-6xl mx-auto space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-12 gap-6">
        {/* Card 1: Turn Navigation (Large 7 cols) */}
        <div className="md:col-span-7 glass-panel glass-panel-hover rounded-3xl p-6 sm:p-8 border border-white/10 relative overflow-hidden flex flex-col justify-between group">
          <div className="space-y-4 relative z-10">
            <div className="w-12 h-12 rounded-2xl bg-circuitOrange/10 border border-circuitOrange/30 flex items-center justify-center text-circuitOrange group-hover:bg-circuitOrange group-hover:text-white transition-colors">
              <Navigation className="w-6 h-6" />
            </div>
            <span className="text-xs font-mono font-bold uppercase text-circuitOrange tracking-widest block">
              REAL VECTOR MAPS
            </span>
            <h3 className="text-2xl font-bold text-white group-hover:text-circuitOrange transition-colors">
              Turn Navigation & Live Vector HUD
            </h3>
            <p className="text-sm text-onSurfaceVariant leading-relaxed">
              Dynamic CartoDB Dark Matter tiles optimized for sunlight and dark helmet visors with offline route caching, speed limit alerts, and GPX trail export.
            </p>
          </div>

          <div className="mt-6 pt-4 border-t border-white/5 grid grid-cols-2 gap-3 text-xs font-mono text-onSurface relative z-10">
            <div className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-circuitOrange" />
              <span>Speed limit warnings</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-circuitOrange" />
              <span>Offline GPX caching</span>
            </div>
          </div>
        </div>

        {/* Card 2: Crash SOS (5 cols) */}
        <div className="md:col-span-5 glass-panel glass-panel-hover rounded-3xl p-6 sm:p-8 border border-red-500/30 relative overflow-hidden flex flex-col justify-between group bg-gradient-to-br from-red-950/20 to-transparent">
          <div className="space-y-4 relative z-10">
            <div className="w-12 h-12 rounded-2xl bg-red-500/10 border border-red-500/30 flex items-center justify-center text-red-400 group-hover:bg-red-500 group-hover:text-white transition-colors">
              <ShieldAlert className="w-6 h-6" />
            </div>
            <span className="text-xs font-mono font-bold uppercase text-red-400 tracking-widest block">
              ACCELEROMETER HEURISTICS
            </span>
            <h3 className="text-2xl font-bold text-white group-hover:text-red-400 transition-colors">
              Automatic Crash SOS
            </h3>
            <p className="text-sm text-onSurfaceVariant leading-relaxed">
              Multi-axis sensor impact detection with 15-second cancellable audio alarm and automated Azure SMS broadcast with precise GPS coordinates.
            </p>
          </div>

          <div className="mt-6 pt-4 border-t border-white/5 text-xs font-mono text-red-300">
            ✓ Automated 108 / 112 medical emergency dialer
          </div>
        </div>

        {/* Card 3: AI Safety Coach (4 cols) */}
        <div className="md:col-span-4 glass-panel glass-panel-hover rounded-3xl p-6 sm:p-8 border border-blue-500/30 relative overflow-hidden flex flex-col justify-between group bg-gradient-to-br from-blue-950/20 to-transparent">
          <div className="space-y-4 relative z-10">
            <div className="w-12 h-12 rounded-2xl bg-blue-500/10 border border-blue-500/30 flex items-center justify-center text-blue-400 group-hover:bg-blue-500 group-hover:text-white transition-colors">
              <Bot className="w-6 h-6" />
            </div>
            <span className="text-xs font-mono font-bold uppercase text-blue-400 tracking-widest block">
              AZURE AI COPILOT
            </span>
            <h3 className="text-xl font-bold text-white group-hover:text-blue-400 transition-colors">
              Defensive Safety Coach
            </h3>
            <p className="text-xs sm:text-sm text-onSurfaceVariant leading-relaxed">
              Real-time cockpit readiness scoring (0-100), weather suitability assessment, and defensive riding voice briefings.
            </p>
          </div>

          <div className="mt-6 pt-4 border-t border-white/5 text-xs font-mono text-blue-300">
            ✓ 0–100 Readiness Index
          </div>
        </div>

        {/* Card 4: Garage Intelligence (4 cols) */}
        <div className="md:col-span-4 glass-panel glass-panel-hover rounded-3xl p-6 sm:p-8 border border-white/10 relative overflow-hidden flex flex-col justify-between group">
          <div className="space-y-4 relative z-10">
            <div className="w-12 h-12 rounded-2xl bg-circuitOrange/10 border border-circuitOrange/30 flex items-center justify-center text-circuitOrange group-hover:bg-circuitOrange group-hover:text-white transition-colors">
              <Wrench className="w-6 h-6" />
            </div>
            <span className="text-xs font-mono font-bold uppercase text-circuitOrange tracking-widest block">
              GARAGE INTELLIGENCE
            </span>
            <h3 className="text-xl font-bold text-white group-hover:text-circuitOrange transition-colors">
              Lifecycle & Reminders
            </h3>
            <p className="text-xs sm:text-sm text-onSurfaceVariant leading-relaxed">
              Automated Insurance and PUC expiry countdowns, digital RC vault, and fuel mileage telemetry analytics.
            </p>
          </div>

          <div className="mt-6 pt-4 border-t border-white/5 text-xs font-mono text-onSurface">
            ✓ Automated expiry countdowns
          </div>
        </div>

        {/* Card 5: Squads & Privacy Mesh (4 cols) */}
        <div className="md:col-span-4 glass-panel glass-panel-hover rounded-3xl p-6 sm:p-8 border border-white/10 relative overflow-hidden flex flex-col justify-between group">
          <div className="space-y-4 relative z-10">
            <div className="w-12 h-12 rounded-2xl bg-circuitOrange/10 border border-circuitOrange/30 flex items-center justify-center text-circuitOrange group-hover:bg-circuitOrange group-hover:text-white transition-colors">
              <Users className="w-6 h-6" />
            </div>
            <span className="text-xs font-mono font-bold uppercase text-circuitOrange tracking-widest block">
              PRIVACY MESH
            </span>
            <h3 className="text-xl font-bold text-white group-hover:text-circuitOrange transition-colors">
              Squads & SHA-256 Match
            </h3>
            <p className="text-xs sm:text-sm text-onSurfaceVariant leading-relaxed">
              Match contacts with zero privacy leak. Raw phone numbers never leave your device.
            </p>
          </div>

          <div className="mt-6 pt-4 border-t border-white/5 text-xs font-mono text-onSurface">
            ✓ Cryptographic contact match
          </div>
        </div>
      </div>
    </div>
  );
};
