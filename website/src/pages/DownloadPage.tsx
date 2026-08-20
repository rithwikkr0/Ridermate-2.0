import React, { useState } from 'react';
import { Download, CheckCircle2, ShieldCheck, Copy, Check, Smartphone, Terminal, ArrowDownCircle, AlertTriangle } from 'lucide-react';
import { downloadConfig, getActiveDownloadUrl, getDownloadButtonLabel } from '../config/downloadConfig';

export const DownloadPage: React.FC = () => {
  const [copied, setCopied] = useState(false);

  const handleCopyChecksum = () => {
    navigator.clipboard.writeText(downloadConfig.sha256Checksum);
    setCopied(true);
    setTimeout(() => setCopied(false), 3000);
  };

  return (
    <div className="pt-28 sm:pt-36 pb-24 max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
      {/* Header */}
      <div className="text-center space-y-4 max-w-2xl mx-auto">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full glass-panel border border-circuitOrange/30 text-xs font-mono text-circuitOrange">
          <Smartphone className="w-3.5 h-3.5" />
          <span>OFFICIAL ANDROID RELEASE</span>
        </div>
        <h1 className="text-3xl sm:text-5xl font-extrabold text-white tracking-tight">
          Download RiderMate 2.0
        </h1>
        <p className="text-sm sm:text-base text-onSurfaceVariant">
          Install the high-performance motorcycle cockpit directly onto your Android device.
        </p>
      </div>

      {/* Main Download Card */}
      <div className="glass-panel rounded-3xl p-6 sm:p-10 border border-white/10 relative overflow-hidden shadow-2xl">
        <div className="absolute top-0 right-0 w-80 h-80 bg-circuitOrange/10 rounded-full blur-3xl pointer-events-none" />

        <div className="grid grid-cols-1 md:grid-cols-12 gap-8 items-center">
          {/* Left info */}
          <div className="md:col-span-7 space-y-6">
            <div>
              <span className="text-xs font-mono text-circuitOrange uppercase tracking-wider block mb-1">
                LATEST BUILD
              </span>
              <h2 className="text-2xl sm:text-3xl font-bold text-white">
                RiderMate v{downloadConfig.version}
              </h2>
              <p className="text-xs sm:text-sm text-onSurfaceVariant mt-1">
                Build Number: <span className="font-mono text-white">{downloadConfig.buildNumber}</span> • Commit: <span className="font-mono text-white">{downloadConfig.commitHash}</span>
              </p>
            </div>

            <div className="grid grid-cols-2 gap-4 text-xs font-mono">
              <div className="p-3 rounded-xl bg-white/5 border border-white/5">
                <span className="text-onSurfaceVariant block mb-1">Package Name</span>
                <span className="text-white font-semibold">com.ridermate.ridermate</span>
              </div>
              <div className="p-3 rounded-xl bg-white/5 border border-white/5">
                <span className="text-onSurfaceVariant block mb-1">File Size</span>
                <span className="text-white font-semibold">~{downloadConfig.apkSizeMB} MB</span>
              </div>
              <div className="p-3 rounded-xl bg-white/5 border border-white/5">
                <span className="text-onSurfaceVariant block mb-1">Target Platform</span>
                <span className="text-white font-semibold">{downloadConfig.minAndroidVersion}</span>
              </div>
              <div className="p-3 rounded-xl bg-white/5 border border-white/5">
                <span className="text-onSurfaceVariant block mb-1">Release Date</span>
                <span className="text-white font-semibold">{downloadConfig.releaseDate}</span>
              </div>
            </div>

            <div className="pt-2">
              <a
                href={getActiveDownloadUrl()}
                className="inline-flex items-center justify-center gap-3 px-8 py-4 rounded-xl font-bold text-base text-white bg-gradient-to-r from-circuitOrange to-circuitOrangeGlow hover:scale-105 active:scale-95 transition-all shadow-xl shadow-circuitOrange/30 w-full sm:w-auto"
              >
                <Download className="w-5 h-5" />
                <span>{getDownloadButtonLabel()}</span>
              </a>
            </div>
          </div>

          {/* Right badge */}
          <div className="md:col-span-5 flex flex-col items-center justify-center p-6 rounded-2xl bg-surfaceContainerHigh/60 border border-white/5 text-center space-y-4">
            <div className="w-16 h-16 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400">
              <ShieldCheck className="w-8 h-8" />
            </div>
            <div>
              <h3 className="font-bold text-sm text-white">Virus & Malware Clean</h3>
              <p className="text-xs text-onSurfaceVariant mt-1">
                Signed directly with Android keystore and verified through automated test suites.
              </p>
            </div>
          </div>
        </div>

        {/* Checksum Bar */}
        <div className="mt-8 pt-6 border-t border-white/10">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 bg-black/40 p-4 rounded-xl border border-white/5">
            <div className="space-y-1 overflow-hidden">
              <span className="text-[11px] font-mono text-onSurfaceVariant uppercase tracking-wider block">
                SHA-256 Checksum (Integrity Verification)
              </span>
              <p className="font-mono text-xs text-circuitOrange truncate select-all">
                {downloadConfig.sha256Checksum}
              </p>
            </div>
            <button
              onClick={handleCopyChecksum}
              className="inline-flex items-center justify-center gap-1.5 px-3 py-1.5 rounded-lg bg-white/10 hover:bg-white/15 text-xs text-white transition-colors shrink-0"
              aria-label="Copy SHA-256 checksum to clipboard"
            >
              {copied ? (
                <>
                  <Check className="w-3.5 h-3.5 text-emerald-400" />
                  <span className="text-emerald-400">Copied!</span>
                </>
              ) : (
                <>
                  <Copy className="w-3.5 h-3.5" />
                  <span>Copy Hash</span>
                </>
              )}
            </button>
          </div>
        </div>
      </div>

      {/* Installation Steps */}
      <div className="space-y-6">
        <h2 className="text-xl font-bold text-white flex items-center gap-2">
          <Terminal className="w-5 h-5 text-circuitOrange" />
          <span>How to Install on Android</span>
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="glass-panel p-6 rounded-2xl space-y-3">
            <div className="w-8 h-8 rounded-lg bg-circuitOrange/20 text-circuitOrange font-mono font-bold flex items-center justify-center">
              1
            </div>
            <h3 className="font-bold text-white text-base">Download APK</h3>
            <p className="text-xs text-onSurfaceVariant leading-relaxed">
              Tap the download button above to save `app-debug.apk` directly to your phone's storage.
            </p>
          </div>

          <div className="glass-panel p-6 rounded-2xl space-y-3">
            <div className="w-8 h-8 rounded-lg bg-circuitOrange/20 text-circuitOrange font-mono font-bold flex items-center justify-center">
              2
            </div>
            <h3 className="font-bold text-white text-base">Allow Installation</h3>
            <p className="text-xs text-onSurfaceVariant leading-relaxed">
              When prompted by Android, tap <strong>Settings</strong> and enable <em>"Allow from this source"</em> for your browser or file manager.
            </p>
          </div>

          <div className="glass-panel p-6 rounded-2xl space-y-3">
            <div className="w-8 h-8 rounded-lg bg-circuitOrange/20 text-circuitOrange font-mono font-bold flex items-center justify-center">
              3
            </div>
            <h3 className="font-bold text-white text-base">Launch & Ride</h3>
            <p className="text-xs text-onSurfaceVariant leading-relaxed">
              Open RiderMate 2.0, log in or create your pilot account, add your bike, and enter the cockpit!
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
