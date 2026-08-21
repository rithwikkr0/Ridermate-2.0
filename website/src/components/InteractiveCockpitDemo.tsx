import React, { useState, useEffect } from 'react';
import { Navigation, Bot, ShieldAlert, Users, Radio, AlertTriangle, Play, Pause, RotateCcw, BatteryCharging, Sparkles } from 'lucide-react';

export const InteractiveCockpitDemo: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'nav' | 'ai' | 'sos' | 'squad'>('nav');
  const [sosCountdown, setSosCountdown] = useState<number | null>(null);
  const [sosTriggered, setSosTriggered] = useState(false);

  // Handle SOS countdown simulation
  useEffect(() => {
    let timer: number;
    if (sosCountdown !== null && sosCountdown > 0) {
      timer = window.setTimeout(() => setSosCountdown(sosCountdown - 1), 1000);
    } else if (sosCountdown === 0) {
      setSosTriggered(true);
    }
    return () => clearTimeout(timer);
  }, [sosCountdown]);

  const startSosSimulation = () => {
    setSosTriggered(false);
    setSosCountdown(15);
  };

  const cancelSos = () => {
    setSosCountdown(null);
    setSosTriggered(false);
  };

  return (
    <div className="glass-panel rounded-3xl p-6 sm:p-10 border border-circuitOrange/30 shadow-2xl relative overflow-hidden">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
        <div>
          <span className="text-xs font-mono text-circuitOrange uppercase tracking-widest block mb-1">
            LIVE INTERACTIVE SIMULATION
          </span>
          <h3 className="text-2xl sm:text-3xl font-extrabold text-white">
            Test the RiderMate Cockpit
          </h3>
        </div>

        {/* Mode Selector Tabs */}
        <div className="flex flex-wrap gap-2 p-1.5 rounded-2xl bg-black/40 border border-white/10">
          <button
            onClick={() => setActiveTab('nav')}
            className={`flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold transition-all ${
              activeTab === 'nav' ? 'bg-circuitOrange text-white shadow-lg shadow-circuitOrange/30' : 'text-onSurfaceVariant hover:text-white'
            }`}
          >
            <Navigation className="w-4 h-4" />
            <span>Turn Navigation</span>
          </button>

          <button
            onClick={() => setActiveTab('ai')}
            className={`flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold transition-all ${
              activeTab === 'ai' ? 'bg-circuitOrange text-white shadow-lg shadow-circuitOrange/30' : 'text-onSurfaceVariant hover:text-white'
            }`}
          >
            <Bot className="w-4 h-4" />
            <span>AI Copilot</span>
          </button>

          <button
            onClick={() => setActiveTab('sos')}
            className={`flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold transition-all ${
              activeTab === 'sos' ? 'bg-red-500 text-white shadow-lg shadow-red-500/30' : 'text-onSurfaceVariant hover:text-white'
            }`}
          >
            <ShieldAlert className="w-4 h-4" />
            <span>Crash SOS</span>
          </button>

          <button
            onClick={() => setActiveTab('squad')}
            className={`flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold transition-all ${
              activeTab === 'squad' ? 'bg-circuitOrange text-white shadow-lg shadow-circuitOrange/30' : 'text-onSurfaceVariant hover:text-white'
            }`}
          >
            <Users className="w-4 h-4" />
            <span>Squad Radar</span>
          </button>
        </div>
      </div>

      {/* Tab 1: Navigation HUD */}
      {activeTab === 'nav' && (
        <div className="space-y-6">
          <div className="p-6 rounded-2xl bg-surfaceContainerHigh border border-white/5 space-y-4">
            <div className="flex items-center justify-between border-b border-white/10 pb-4">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-circuitOrange/20 text-circuitOrange flex items-center justify-center font-bold">
                  ↗
                </div>
                <div>
                  <span className="text-xs font-mono text-onSurfaceVariant uppercase">In 350 Meters</span>
                  <p className="text-lg font-bold text-white">Bear right onto Mountain Pass Highway (SH-17)</p>
                </div>
              </div>
              <div className="text-right">
                <span className="text-xs font-mono text-emerald-400 font-semibold">ON ROUTE</span>
                <p className="text-sm font-mono text-white">ETA 18:42 • 14.8 km</p>
              </div>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 text-center">
              <div className="p-3 rounded-xl bg-black/40 border border-white/5">
                <span className="text-[11px] text-onSurfaceVariant block">Speed Limit</span>
                <span className="text-xl font-bold font-mono text-circuitOrange">80 KM/H</span>
              </div>
              <div className="p-3 rounded-xl bg-black/40 border border-white/5">
                <span className="text-[11px] text-onSurfaceVariant block">Current Speed</span>
                <span className="text-xl font-bold font-mono text-white">74 KM/H</span>
              </div>
              <div className="p-3 rounded-xl bg-black/40 border border-white/5">
                <span className="text-[11px] text-onSurfaceVariant block">Safety Score</span>
                <span className="text-xl font-bold font-mono text-emerald-400">96 / 100</span>
              </div>
              <div className="p-3 rounded-xl bg-black/40 border border-white/5">
                <span className="text-[11px] text-onSurfaceVariant block">Weather Condition</span>
                <span className="text-xl font-bold font-mono text-blue-400">22°C Clear</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Tab 2: AI Safety Coach */}
      {activeTab === 'ai' && (
        <div className="space-y-6">
          <div className="p-6 rounded-2xl bg-gradient-to-br from-blue-950/40 to-surfaceContainerHigh border border-blue-500/30 space-y-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-blue-500/20 text-blue-400 flex items-center justify-center shadow-lg shadow-blue-500/20">
                <Bot className="w-6 h-6" />
              </div>
              <div>
                <span className="text-xs font-mono text-blue-400 font-semibold">AZURE DEFENSIVE RIDING COACH</span>
                <h4 className="text-lg font-bold text-white">Pre-Ride Telemetry Assessment</h4>
              </div>
            </div>

            <div className="p-4 rounded-xl bg-black/50 border border-white/10 space-y-2 text-sm">
              <p className="text-white leading-relaxed">
                "Good afternoon Pilot. Cockpit readiness is at <strong className="text-emerald-400 font-mono">98%</strong>. Front tire pressure is nominal. Ahead at KM 42, sharp switchbacks report gusty crosswinds (24 km/h). Keep lean angles under 30° on descending hairpins."
              </p>
            </div>

            <div className="flex flex-wrap gap-3 pt-2">
              <span className="px-3 py-1 rounded-lg bg-blue-500/10 border border-blue-500/30 text-xs text-blue-400 font-mono">
                ✓ Chain tension: Calibrated
              </span>
              <span className="px-3 py-1 rounded-lg bg-blue-500/10 border border-blue-500/30 text-xs text-blue-400 font-mono">
                ✓ Brake pads: 84% life
              </span>
              <span className="px-3 py-1 rounded-lg bg-blue-500/10 border border-blue-500/30 text-xs text-blue-400 font-mono">
                ✓ Rain probability: 0%
              </span>
            </div>
          </div>
        </div>
      )}

      {/* Tab 3: Crash SOS */}
      {activeTab === 'sos' && (
        <div className="space-y-6">
          <div className="p-6 rounded-2xl bg-gradient-to-br from-red-950/40 to-surfaceContainerHigh border border-red-500/40 space-y-5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-red-500/20 text-red-400 flex items-center justify-center animate-pulse">
                  <AlertTriangle className="w-6 h-6" />
                </div>
                <div>
                  <span className="text-xs font-mono text-red-400 font-semibold">SIMULATED 4.8G IMPACT EVENT</span>
                  <h4 className="text-lg font-bold text-white">Automatic Crash Detection Routine</h4>
                </div>
              </div>
            </div>

            {sosCountdown !== null && sosCountdown > 0 && (
              <div className="p-6 rounded-2xl bg-red-950/80 border border-red-500 text-center space-y-4 animate-pulse">
                <span className="text-xs font-mono text-red-300 uppercase tracking-widest block">
                  Cancellable Countdown Active
                </span>
                <span className="font-mono text-5xl sm:text-6xl font-extrabold text-white block">
                  {sosCountdown}s
                </span>
                <p className="text-xs text-red-200">
                  Audio alarm is sounding. If you are unhurt, tap below immediately to cancel emergency broadcast.
                </p>
                <button
                  onClick={cancelSos}
                  className="px-6 py-3 rounded-xl bg-white text-black font-bold text-sm hover:scale-105 transition-transform"
                >
                  I Am Safe — Cancel SOS
                </button>
              </div>
            )}

            {sosTriggered && (
              <div className="p-6 rounded-2xl bg-emerald-950/60 border border-emerald-500/40 space-y-2">
                <div className="flex items-center gap-2 text-emerald-400 font-bold text-sm">
                  <span>✓ Emergency Dispatch Broadcasted</span>
                </div>
                <p className="text-xs text-onSurfaceVariant">
                  Azure SMS broadcast with exact GPS coordinates (12.9716° N, 77.5946° E) sent to 2 designated contacts + 108 Emergency Medical Services.
                </p>
                <button
                  onClick={cancelSos}
                  className="mt-3 px-4 py-1.5 rounded-lg bg-white/10 text-xs text-white hover:bg-white/20"
                >
                  Reset Simulation
                </button>
              </div>
            )}

            {sosCountdown === null && !sosTriggered && (
              <div className="flex flex-col sm:flex-row items-center justify-between gap-4 p-4 rounded-xl bg-black/40 border border-white/10">
                <p className="text-xs text-onSurfaceVariant">
                  Test the multi-axis accelerometer impact detection safety loop in real-time.
                </p>
                <button
                  onClick={startSosSimulation}
                  className="px-5 py-2.5 rounded-xl bg-red-500 hover:bg-red-600 font-bold text-xs text-white shadow-lg shadow-red-500/30 shrink-0"
                >
                  Trigger Simulated Impact (4.8G)
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Tab 4: Squad Radar */}
      {activeTab === 'squad' && (
        <div className="space-y-6">
          <div className="p-6 rounded-2xl bg-surfaceContainerHigh border border-white/5 space-y-4">
            <div className="flex items-center justify-between border-b border-white/10 pb-4">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-circuitOrange/20 text-circuitOrange flex items-center justify-center">
                  <Radio className="w-5 h-5 animate-pulse" />
                </div>
                <div>
                  <span className="text-xs font-mono text-circuitOrange font-semibold">LIVE SQUAD MESH</span>
                  <h4 className="text-lg font-bold text-white">Ghost Apex Riders (4 Pilots Active)</h4>
                </div>
              </div>
              <span className="text-xs font-mono text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-2.5 py-1 rounded-full">
                SYNCED
              </span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="p-4 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-full bg-circuitOrange/30 flex items-center justify-center font-mono font-bold text-white text-xs">
                    P1
                  </div>
                  <div>
                    <span className="text-xs font-bold text-white block">Rithwik (Lead Pilot)</span>
                    <span className="text-[11px] text-onSurfaceVariant font-mono">Yamaha R15 V4 • 82 km/h</span>
                  </div>
                </div>
                <span className="text-xs font-mono text-circuitOrange font-semibold">0m (Leader)</span>
              </div>

              <div className="p-4 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-full bg-blue-500/30 flex items-center justify-center font-mono font-bold text-white text-xs">
                    P2
                  </div>
                  <div>
                    <span className="text-xs font-bold text-white block">Vikram S.</span>
                    <span className="text-[11px] text-onSurfaceVariant font-mono">KTM Duke 390 • 80 km/h</span>
                  </div>
                </div>
                <span className="text-xs font-mono text-onSurfaceVariant font-semibold">45m Behind</span>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
