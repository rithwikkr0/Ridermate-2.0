import React from 'react';
import { Link } from 'react-router-dom';
import { Shield, Github, Heart, Sparkles, Zap, Lock } from 'lucide-react';
import { downloadConfig } from '../config/downloadConfig';

export const Footer: React.FC = () => {
  return (
    <footer className="border-t border-white/10 bg-surface/50 backdrop-blur-xl relative overflow-hidden">
      {/* Background glow */}
      <div className="absolute -top-32 left-1/2 -translate-x-1/2 w-96 h-96 bg-circuitOrange/10 rounded-full blur-3xl pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 lg:py-16 relative z-10">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8 lg:gap-12">
          {/* Col 1: Brand & Tagline */}
          <div className="md:col-span-1 space-y-4">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-lg overflow-hidden bg-surface border border-circuitOrange/40 shadow-lg shadow-circuitOrange/30">
                <img
                  src="/app_icon.png"
                  alt="RiderMate 2.0 Icon"
                  className="w-full h-full object-cover"
                />
              </div>
              <span className="font-extrabold text-lg tracking-tight text-white">
                RiderMate <span className="text-xs text-circuitOrange font-mono">2.0</span>
              </span>
            </div>
            <p className="text-xs leading-relaxed text-onSurfaceVariant">
              The high-performance cockpit for motorcycle riders. Engineered with offline-first telemetry, live group squad radar, crash detection SOS, and AI safety intelligence.
            </p>
            <div className="flex items-center gap-3 pt-2">
              <a
                href={downloadConfig.links.gitHubRepo}
                target="_blank"
                rel="noopener noreferrer"
                className="w-8 h-8 rounded-lg bg-white/5 hover:bg-white/10 border border-white/10 flex items-center justify-center text-onSurfaceVariant hover:text-white transition-colors"
                aria-label="GitHub Repository"
              >
                <Github className="w-4 h-4" />
              </a>
              <span className="text-[11px] font-mono text-onSurfaceVariant/80 border border-white/10 rounded px-2 py-0.5 bg-white/5">
                v{downloadConfig.version} ({downloadConfig.commitHash})
              </span>
            </div>
          </div>

          {/* Col 2: Navigation */}
          <div>
            <h4 className="text-xs font-mono font-bold tracking-widest text-onSurface uppercase mb-4">Platform</h4>
            <ul className="space-y-2.5 text-xs text-onSurfaceVariant">
              <li>
                <Link to="/" className="hover:text-circuitOrange transition-colors">Features & Intelligence</Link>
              </li>
              <li>
                <Link to="/download" className="hover:text-circuitOrange transition-colors">Download for Android</Link>
              </li>
              <li>
                <Link to="/join" className="hover:text-circuitOrange transition-colors">Join Squad with Code</Link>
              </li>
              <li>
                <a href={`${downloadConfig.links.gitHubRepo}/releases`} target="_blank" rel="noopener noreferrer" className="hover:text-circuitOrange transition-colors">
                  Release Notes
                </a>
              </li>
            </ul>
          </div>

          {/* Col 3: Safety & Legal */}
          <div>
            <h4 className="text-xs font-mono font-bold tracking-widest text-onSurface uppercase mb-4">Trust & Compliance</h4>
            <ul className="space-y-2.5 text-xs text-onSurfaceVariant">
              <li>
                <Link to="/privacy" className="hover:text-circuitOrange transition-colors flex items-center gap-1.5">
                  <Shield className="w-3.5 h-3.5 text-circuitOrange" />
                  <span>Privacy Policy</span>
                </Link>
              </li>
              <li>
                <Link to="/data-safety" className="hover:text-circuitOrange transition-colors flex items-center gap-1.5">
                  <Lock className="w-3.5 h-3.5 text-circuitOrange" />
                  <span>Data Safety Declaration</span>
                </Link>
              </li>
              <li>
                <span className="text-onSurfaceVariant/60">Zero Ad-Tracking Guarantee</span>
              </li>
              <li>
                <span className="text-onSurfaceVariant/60">Local-First Encryption</span>
              </li>
            </ul>
          </div>

          {/* Col 4: Architecture */}
          <div>
            <h4 className="text-xs font-mono font-bold tracking-widest text-onSurface uppercase mb-4">Architecture</h4>
            <div className="space-y-2 text-[11px] text-onSurfaceVariant leading-relaxed">
              <p>
                Mobile client built with Flutter 3 & SQLite. Cloud backend orchestrated on Microsoft Azure App Service and Azure Database for PostgreSQL with Alembic migrations.
              </p>
              <div className="pt-2">
                <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 font-mono text-[10px]">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                  All Cloud Services Operational
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="mt-12 pt-6 border-t border-white/5 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-onSurfaceVariant/80">
          <p>© 2026 RiderMate Platform. Open source under MIT License.</p>
          <p className="flex items-center gap-1">
            Engineered with <Heart className="w-3 h-3 text-circuitOrange fill-circuitOrange" /> for motorcycle riders worldwide.
          </p>
        </div>
      </div>
    </footer>
  );
};
