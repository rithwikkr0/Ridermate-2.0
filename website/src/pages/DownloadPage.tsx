import React, { useState } from 'react';
import { downloadConfig, getActiveDownloadUrl } from '../config/downloadConfig';

const CheckIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.5} className="w-4 h-4 text-green-400 flex-shrink-0">
    <polyline points="20 6 9 17 4 12" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

const AndroidIcon = () => (
  <svg viewBox="0 0 24 24" fill="currentColor" className="w-6 h-6">
    <path d="M17.523 15.34a1 1 0 11-2 0 1 1 0 012 0zm-9 0a1 1 0 11-2 0 1 1 0 012 0zM6.116 6.832l-1.69-2.923a.5.5 0 01.866-.5l1.714 2.967A9.965 9.965 0 0112 5.5c1.74 0 3.376.445 4.794 1.226l1.714-2.968a.5.5 0 01.866.5l-1.69 2.924A9.995 9.995 0 0122 15.5H2a9.995 9.995 0 014.116-8.668z" />
  </svg>
);

const DownloadIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-5 h-5">
    <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

const ShieldIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} className="w-5 h-5">
    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

const ExternalIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-4 h-4">
    <path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6M15 3h6v6M10 14L21 3" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

const steps = [
  'Tap the download button below',
  'Open your browser downloads or Files app',
  'Tap the RiderMate .apk file',
  'If prompted, allow "Install from unknown sources" in Settings',
  'Tap Install and enjoy your cockpit',
];

const features = [
  'Real-time cockpit HUD',
  'Crash detection & SOS alerts',
  'Squad rides & live convoy tracking',
  'Route intelligence & offline maps',
  'Ride memories & replay',
  'Works offline — no server required',
];

export const DownloadPage: React.FC = () => {
  const [downloading, setDownloading] = useState(false);
  const [error, setError] = useState(false);

  const handleDownload = () => {
    setDownloading(true);
    setError(false);

    // Primary: GitHub Release direct asset URL
    const primaryUrl = downloadConfig.links.githubRelease;
    // Fallback: GitHub release page (user can manually click)
    const fallbackUrl = downloadConfig.links.gitHubReleasePage;

    try {
      const link = document.createElement('a');
      link.href = primaryUrl;
      link.setAttribute('download', 'RiderMate-2.0.apk');
      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      setTimeout(() => setDownloading(false), 3000);
    } catch {
      setError(true);
      setDownloading(false);
      // Open release page as fallback
      window.open(fallbackUrl, '_blank', 'noopener,noreferrer');
    }
  };

  return (
    <div className="min-h-screen py-24 px-6">
      <div className="max-w-4xl mx-auto">

        {/* Page header */}
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-3 mb-6">
            <img src="/app_icon.png" alt="RiderMate" className="w-16 h-16 rounded-2xl shadow-lg shadow-circuitOrange/20" />
          </div>
          <h1 className="text-5xl font-extrabold gradient-text-white mb-3">
            Download RiderMate
          </h1>
          <p className="text-onSurfaceVariant text-lg">
            Version {downloadConfig.version} · {downloadConfig.apkSizeMB} MB · Free
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-8">
          {/* Download Card */}
          <div className="glass rounded-3xl p-8 border border-white/6 relative overflow-hidden">
            <div className="absolute -top-16 -right-16 w-48 h-48 rounded-full bg-circuitOrange/8 blur-3xl" />
            <div className="relative z-10">

              {/* Platform badge */}
              <div className="inline-flex items-center gap-2 px-3 py-1.5 glass-orange rounded-full border border-circuitOrange/30 mb-6">
                <AndroidIcon />
                <span className="text-sm font-medium text-circuitOrange">Android</span>
              </div>

              <h2 className="text-2xl font-bold text-onSurface mb-1">APK Direct Download</h2>
              <p className="text-sm text-onSurfaceVariant mb-6">
                {downloadConfig.minAndroidVersion} required
              </p>

              {/* Release info */}
              <div className="glass rounded-xl p-4 mb-6 space-y-2 font-mono text-xs text-onSurfaceVariant">
                <div className="flex justify-between">
                  <span>Release</span>
                  <span className="text-onSurface">{downloadConfig.releaseTag}</span>
                </div>
                <div className="flex justify-between">
                  <span>Date</span>
                  <span className="text-onSurface">{downloadConfig.releaseDate}</span>
                </div>
                <div className="flex justify-between">
                  <span>Size</span>
                  <span className="text-onSurface">{downloadConfig.apkSizeMB} MB</span>
                </div>
                <div className="flex justify-between">
                  <span>Build</span>
                  <span className="text-onSurface">#{downloadConfig.buildNumber}</span>
                </div>
              </div>

              {/* SHA checksum */}
              <div className="flex items-start gap-2 mb-6 p-3 rounded-xl bg-green-500/5 border border-green-500/15">
                <ShieldIcon />
                <div>
                  <p className="text-xs font-medium text-green-400 mb-0.5">SHA-256 Verified</p>
                  <p className="text-xs text-onSurfaceVariant font-mono break-all leading-relaxed">
                    {downloadConfig.sha256Checksum}
                  </p>
                </div>
              </div>

              {/* Primary download button */}
              <button
                onClick={handleDownload}
                disabled={downloading}
                className="shimmer-btn w-full flex items-center justify-center gap-3 py-4 px-6 bg-circuitOrange text-white font-bold rounded-2xl text-base glow-orange hover:bg-circuitOrangeGlow transition-all duration-300 disabled:opacity-70 disabled:cursor-wait"
              >
                {downloading ? (
                  <>
                    <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    Starting download…
                  </>
                ) : (
                  <>
                    <DownloadIcon />
                    Download APK Free
                  </>
                )}
              </button>

              {/* Fallback link */}
              <div className="mt-4 text-center">
                <a
                  href={downloadConfig.links.gitHubReleasePage}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 text-sm text-onSurfaceVariant hover:text-circuitOrange transition-colors duration-200"
                >
                  Can't download? Open GitHub Releases page
                  <ExternalIcon />
                </a>
              </div>

              {error && (
                <div className="mt-4 p-3 rounded-xl bg-red-500/10 border border-red-500/20 text-sm text-red-400 text-center">
                  Download redirect opened. If it didn't work, use the GitHub link above.
                </div>
              )}
            </div>
          </div>

          {/* Info Card */}
          <div className="space-y-6">
            {/* Included features */}
            <div className="glass rounded-3xl p-6 border border-white/6">
              <h3 className="font-semibold text-onSurface mb-4">What's included</h3>
              <ul className="space-y-3">
                {features.map(f => (
                  <li key={f} className="flex items-center gap-3 text-sm text-onSurfaceVariant">
                    <CheckIcon />
                    {f}
                  </li>
                ))}
              </ul>
            </div>

            {/* Installation steps */}
            <div className="glass rounded-3xl p-6 border border-white/6">
              <h3 className="font-semibold text-onSurface mb-4">Installation steps</h3>
              <ol className="space-y-3">
                {steps.map((step, i) => (
                  <li key={i} className="flex items-start gap-3 text-sm text-onSurfaceVariant">
                    <span className="flex-shrink-0 w-5 h-5 rounded-full bg-circuitOrange/20 border border-circuitOrange/30 text-circuitOrange text-xs flex items-center justify-center font-bold">
                      {i + 1}
                    </span>
                    {step}
                  </li>
                ))}
              </ol>
            </div>
          </div>
        </div>

        {/* Footer disclaimer */}
        <p className="text-center text-xs text-onSurfaceVariant mt-12">
          RiderMate is free and open-source. No subscription, no tracking, no ads. Ride free. 🏍️
        </p>
      </div>
    </div>
  );
};
