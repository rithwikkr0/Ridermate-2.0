import React, { useState, useEffect } from 'react';
import {
  Navigation,
  Bot,
  ShieldAlert,
  Users,
  Gauge,
  Zap,
  Radio,
  AlertTriangle,
  Play,
  RotateCcw,
  Sparkles,
  ChevronRight,
  Battery,
  Wifi,
  CloudSun
} from 'lucide-react';

export const CockpitSimulator: React.FC = () => {
  const [activeMode, setActiveMode] = useState<'hud' | 'nav' | 'ai' | 'sos'>('hud');
  const [speed, setSpeed] = useState(84);
  const [gear, setGear] = useState(5);
  const [rpm, setRpm] = useState(7800);
  const [lean, setLean] = useState(-18.4);
  const [isAccelerating, setIsAccelerating] = useState(false);

  // SOS state
  const [sosCountdown, setSosCountdown] = useState<number | null>(null);
  const [sosSent, setSosSent] = useState(false);

  // Dynamic throttle simulation
  useEffect(() => {
    let interval: number;
    if (isAccelerating) {
      interval = window.setInterval(() => {
        setSpeed((s) => (s >= 148 ? 148 : s + 2));
        setRpm((r) => (r >= 10500 ? 10500 : r + 150));
        setGear((g) => (g < 6 && speed > 110 ? 6 : g));
      }, 50);
    } else {
      interval = window.setInterval(() => {
        setSpeed((s) => (s <= 84 ? 84 : s - 1));
        setRpm((r) => (r <= 7800 ? 7800 : r - 80));
        setGear(5);
      }, 80);
    }
    return () => clearInterval(interval);
  }, [isAccelerating, speed]);

  // SOS countdown
  useEffect(() => {
    let timer: number;
    if (sosCountdown !== null && sosCountdown > 0) {
      timer = window.setTimeout(() => setSosCountdown(sosCountdown - 1), 1000);
    } else if (sosCountdown === 0) {
      setSosSent(true);
    }
    return () => clearTimeout(timer);
  }, [sosCountdown]);

  const triggerSos = () => {
    setSosSent(false);
    setSosCountdown(15);
  };

  const cancelSos = () => {
    setSosCountdown(null);
    setSosSent(false);
  };

  return (
    <div className="w-full max-w-5xl mx-auto space-y-6">
      {/* Top Mode Selector Tabs */}
      <div className="flex flex-wrap items-center justify-between gap-3 p-2 rounded-2xl glass-panel border border-white/10">
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() => setActiveMode('hud')}
            className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
              activeMode === 'hud'
                ? 'bg-circuitOrange text-white shadow-lg shadow-circuitOrange/30'
                : 'text-onSurfaceVariant hover:text-white hover:bg-white/5'
            }`}
          >
            <Gauge className="w-4 h-4" />
            <span>Digital HUD</span>
          </button>

          <button
            onClick={() => setActiveMode('nav')}
            className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
              activeMode === 'nav'
                ? 'bg-circuitOrange text-white shadow-lg shadow-circuitOrange/30'
                : 'text-onSurfaceVariant hover:text-white hover:bg-white/5'
            }`}
          >
            <Navigation className="w-4 h-4" />
            <span>Turn Navigation</span>
          </button>

          <button
            onClick={() => setActiveMode('ai')}
            className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
              activeMode === 'ai'
                ? 'bg-circuitOrange text-white shadow-lg shadow-circuitOrange/30'
                : 'text-onSurfaceVariant hover:text-white hover:bg-white/5'
            }`}
          >
            <Bot className="w-4 h-4" />
            <span>AI Safety Coach</span>
          </button>

          <button
            onClick={() => setActiveMode('sos')}
            className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
              activeMode === 'sos'
                ? 'bg-red-500 text-white shadow-lg shadow-red-500/30'
                : 'text-onSurfaceVariant hover:text-white hover:bg-white/5'
            }`}
          >
            <ShieldAlert className="w-4 h-4" />
            <span>Crash Detection SOS</span>
          </button>
        </div>

        {/* Live Throttle Button */}
        {activeMode === 'hud' && (
          <button
            onMouseDown={() => setIsAccelerating(true)}
            onMouseUp={() => setIsAccelerating(false)}
            onTouchStart={() => setIsAccelerating(true)}
            onTouchEnd={() => setIsAccelerating(false)}
            className="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-mono font-bold bg-circuitOrange/20 border border-circuitOrange text-circuitOrange hover:bg-circuitOrange hover:text-white transition-all select-none cursor-pointer"
          >
            <Play className="w-3.5 h-3.5 fill-current" />
            <span>HOLD TO THROTTLE</span>
          </button>
        )}
      </div>

      {/* Main Cockpit Frame (Tablet-grade Dashboard) */}
      <div className="relative rounded-3xl bg-surface border-2 border-white/10 shadow-2xl overflow-hidden p-6 sm:p-8">
        {/* Subtle Cockpit Ambient Glow */}
        <div className="absolute top-0 right-0 w-96 h-96 bg-circuitOrange/10 rounded-full blur-3xl pointer-events-none" />

        {/* Status Bar */}
        <div className="flex items-center justify-between border-b border-white/10 pb-4 mb-6 text-xs font-mono text-onSurfaceVariant">
          <div className="flex items-center gap-4">
            <span className="flex items-center gap-1.5 text-white font-bold">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              PILOT: CONNECTED
            </span>
            <span>R15 V4 • ABS ON</span>
          </div>

          <div className="flex items-center gap-4">
            <span className="flex items-center gap-1">
              <CloudSun className="w-3.5 h-3.5 text-blue-400" />
              24°C CLEAR
            </span>
            <span className="flex items-center gap-1 text-emerald-400">
              <Battery className="w-4 h-4" />
              88%
            </span>
          </div>
        </div>

        {/* ── Mode 1: Digital HUD ───────────────────────────────────────── */}
        {activeMode === 'hud' && (
          <div className="space-y-6">
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
              {/* Left Column: Speedometer Arc & Gear */}
              <div className="lg:col-span-6 flex flex-col items-center justify-center p-6 rounded-2xl bg-black/50 border border-white/5 relative">
                <div className="text-center space-y-1">
                  <span className="text-xs font-mono tracking-widest text-onSurfaceVariant uppercase">
                    CURRENT SPEED
                  </span>
                  <div className="flex items-baseline justify-center gap-2">
                    <span className="font-mono text-7xl sm:text-8xl font-black text-white tracking-tighter">
                      {speed}
                    </span>
                    <span className="font-mono text-xl text-circuitOrange font-bold">
                      KM/H
                    </span>
                  </div>
                </div>

                {/* RPM Bar */}
                <div className="w-full mt-6 space-y-1.5">
                  <div className="flex justify-between text-[11px] font-mono text-onSurfaceVariant">
                    <span>RPM x1000</span>
                    <span className={rpm > 9000 ? 'text-red-400 font-bold' : 'text-circuitOrange'}>
                      {rpm} RPM
                    </span>
                  </div>
                  <div className="w-full h-3 bg-black/60 rounded-full overflow-hidden border border-white/10 p-0.5">
                    <div
                      className={`h-full rounded-full transition-all duration-75 ${
                        rpm > 9000
                          ? 'bg-gradient-to-r from-circuitOrange via-amber-400 to-red-500'
                          : 'bg-gradient-to-r from-circuitOrange to-circuitOrangeGlow'
                      }`}
                      style={{ width: `${(rpm / 12000) * 100}%` }}
                    />
                  </div>
                </div>
              </div>

              {/* Right Column: Telemetry Matrix */}
              <div className="lg:col-span-6 grid grid-cols-2 gap-4">
                <div className="p-4 rounded-2xl bg-black/40 border border-white/5 space-y-1">
                  <span className="text-xs font-mono text-onSurfaceVariant">ACTIVE GEAR</span>
                  <p className="text-3xl font-mono font-bold text-white">{gear}</p>
                  <span className="text-[11px] text-emerald-400 font-mono">OPTIMAL CRUISE</span>
                </div>

                <div className="p-4 rounded-2xl bg-black/40 border border-white/5 space-y-1">
                  <span className="text-xs font-mono text-onSurfaceVariant">LEAN ANGLE</span>
                  <p className="text-3xl font-mono font-bold text-circuitOrange">{lean}°</p>
                  <span className="text-[11px] text-onSurfaceVariant font-mono">LEFT CORNER</span>
                </div>

                <div className="p-4 rounded-2xl bg-black/40 border border-white/5 space-y-1">
                  <span className="text-xs font-mono text-onSurfaceVariant">TRIP DISTANCE</span>
                  <p className="text-3xl font-mono font-bold text-white">42.8</p>
                  <span className="text-[11px] text-onSurfaceVariant font-mono">KM LOGGED</span>
                </div>

                <div className="p-4 rounded-2xl bg-black/40 border border-white/5 space-y-1">
                  <span className="text-xs font-mono text-onSurfaceVariant">SAFETY SCORE</span>
                  <p className="text-3xl font-mono font-bold text-emerald-400">98%</p>
                  <span className="text-[11px] text-emerald-400 font-mono">DEFENSIVE PILOT</span>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* ── Mode 2: Turn Navigation ──────────────────────────────────── */}
        {activeMode === 'nav' && (
          <div className="space-y-4">
            <div className="p-5 rounded-2xl bg-gradient-to-r from-circuitOrange/20 to-surfaceContainer border border-circuitOrange/40 flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-circuitOrange flex items-center justify-center font-bold text-2xl text-white shadow-lg shadow-circuitOrange/30">
                  ↗
                </div>
                <div>
                  <span className="text-xs font-mono text-circuitOrange uppercase font-bold">In 300 Meters</span>
                  <h4 className="text-lg font-bold text-white">Turn right onto Nandi Hillside Loop</h4>
                </div>
              </div>
              <div className="text-right font-mono text-xs hidden sm:block">
                <span className="text-emerald-400 font-bold">ETA 19:15</span>
                <p className="text-onSurfaceVariant">21.4 km remaining</p>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs font-mono">
              <div className="p-4 rounded-xl bg-black/40 border border-white/5">
                <span className="text-onSurfaceVariant block mb-1">Route Style</span>
                <span className="text-white font-bold">Scenic Mountain Pass</span>
              </div>
              <div className="p-4 rounded-xl bg-black/40 border border-white/5">
                <span className="text-onSurfaceVariant block mb-1">Speed Advisory</span>
                <span className="text-circuitOrange font-bold">Max 60 km/h (Hairpins)</span>
              </div>
              <div className="p-4 rounded-xl bg-black/40 border border-white/5">
                <span className="text-onSurfaceVariant block mb-1">Map Layer</span>
                <span className="text-blue-400 font-bold">CartoDB Dark Matter</span>
              </div>
            </div>
          </div>
        )}

        {/* ── Mode 3: AI Safety Coach ─────────────────────────────────── */}
        {activeMode === 'ai' && (
          <div className="space-y-4">
            <div className="p-6 rounded-2xl bg-gradient-to-br from-blue-950/40 to-surfaceContainer border border-blue-500/30 space-y-4">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-blue-500/20 text-blue-400 flex items-center justify-center">
                  <Bot className="w-5 h-5" />
                </div>
                <div>
                  <span className="text-xs font-mono text-blue-400 font-bold uppercase">Azure Safety Coach Analysis</span>
                  <h4 className="text-base font-bold text-white">Pre-Ride Telemetry Readiness</h4>
                </div>
              </div>

              <div className="p-4 rounded-xl bg-black/50 border border-white/10 text-sm text-white leading-relaxed">
                "Pilot, your riding telemetry indicates a 98% defensive safety streak over the last 14 rides. Ahead at elevation 1,800m, evening fog is forming. Recommended headlight check and +10m follow distance."
              </div>

              <div className="grid grid-cols-3 gap-3 text-center text-xs font-mono">
                <div className="p-3 rounded-xl bg-black/30 border border-white/5">
                  <span className="text-onSurfaceVariant block">Tire Temp</span>
                  <span className="text-emerald-400 font-bold">34°C Warm</span>
                </div>
                <div className="p-3 rounded-xl bg-black/30 border border-white/5">
                  <span className="text-onSurfaceVariant block">Brake Life</span>
                  <span className="text-white font-bold">88% Good</span>
                </div>
                <div className="p-3 rounded-xl bg-black/30 border border-white/5">
                  <span className="text-onSurfaceVariant block">Challans</span>
                  <span className="text-emerald-400 font-bold">0 Pending</span>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* ── Mode 4: Crash SOS ───────────────────────────────────────── */}
        {activeMode === 'sos' && (
          <div className="space-y-4">
            <div className="p-6 rounded-2xl bg-gradient-to-br from-red-950/40 to-surfaceContainer border border-red-500/40 space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-red-500/20 text-red-400 flex items-center justify-center animate-pulse">
                    <AlertTriangle className="w-5 h-5" />
                  </div>
                  <div>
                    <span className="text-xs font-mono text-red-400 font-bold uppercase">4.5G Impact Trigger Simulation</span>
                    <h4 className="text-base font-bold text-white">Automated Emergency Protocol</h4>
                  </div>
                </div>

                {sosCountdown === null && !sosSent && (
                  <button
                    onClick={triggerSos}
                    className="px-4 py-2 rounded-xl bg-red-500 hover:bg-red-600 text-xs font-bold text-white shadow-lg shadow-red-500/30"
                  >
                    Simulate Impact
                  </button>
                )}
              </div>

              {sosCountdown !== null && sosCountdown > 0 && (
                <div className="p-6 rounded-xl bg-red-950/80 border border-red-500 text-center space-y-3 animate-pulse">
                  <span className="text-xs font-mono text-red-200">CANCELLABLE COUNTDOWN</span>
                  <span className="font-mono text-5xl font-black text-white block">{sosCountdown}s</span>
                  <button
                    onClick={cancelSos}
                    className="px-6 py-2.5 rounded-xl bg-white text-black font-bold text-xs"
                  >
                    I Am Safe — Cancel Alert
                  </button>
                </div>
              )}

              {sosSent && (
                <div className="p-4 rounded-xl bg-emerald-950/60 border border-emerald-500 text-xs space-y-2 text-emerald-300">
                  <p className="font-bold">✓ Emergency SMS Dispatched</p>
                  <p className="text-onSurfaceVariant">Live GPS broadcast sent to 2 contacts + Emergency services dialer armed.</p>
                  <button onClick={cancelSos} className="px-3 py-1 rounded bg-white/10 text-white text-[11px]">
                    Reset
                  </button>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
