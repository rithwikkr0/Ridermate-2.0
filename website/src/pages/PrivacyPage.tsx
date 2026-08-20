import React from 'react';
import { Shield, Lock, MapPin, Activity, Camera, Mic, FileText, CheckCircle2 } from 'lucide-react';

export const PrivacyPage: React.FC = () => {
  return (
    <div className="pt-28 sm:pt-36 pb-24 max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 space-y-10">
      {/* Header */}
      <div className="space-y-4 border-b border-white/10 pb-8">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-circuitOrange/10 border border-circuitOrange/30 text-xs font-mono text-circuitOrange">
          <Shield className="w-3.5 h-3.5" />
          <span>LEGAL & COMPLIANCE</span>
        </div>
        <h1 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
          Privacy Policy
        </h1>
        <div className="flex flex-wrap gap-4 text-xs font-mono text-onSurfaceVariant">
          <span>Effective Date: August 19, 2026</span>
          <span>•</span>
          <span>Application ID: com.ridermate.ridermate</span>
          <span>•</span>
          <span>Contact: privacy@ridermate.app</span>
        </div>
      </div>

      {/* Main Content */}
      <div className="prose prose-invert max-w-none space-y-8 text-sm sm:text-base text-onSurface/90 leading-relaxed">
        <section className="glass-panel p-6 sm:p-8 rounded-2xl space-y-4">
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <Lock className="w-5 h-5 text-circuitOrange" />
            <span>1. Introduction</span>
          </h2>
          <p className="text-onSurfaceVariant text-sm leading-relaxed">
            RiderMate 2.0 ("RiderMate", "we", "us", or "our") is committed to protecting the privacy and security of motorcycle riders and users of our mobile application and cloud services. This Privacy Policy explains what personal and device data we collect, how it is used, how it is stored, and your rights regarding your information.
          </p>
        </section>

        <section className="glass-panel p-6 sm:p-8 rounded-2xl space-y-6">
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <FileText className="w-5 h-5 text-circuitOrange" />
            <span>2. Information We Collect</span>
          </h2>

          <div className="space-y-4">
            <div className="space-y-2">
              <h3 className="text-base font-semibold text-white flex items-center gap-2">
                <MapPin className="w-4 h-4 text-circuitOrange" />
                <span>A. Location Data (Foreground & Background)</span>
              </h3>
              <p className="text-sm text-onSurfaceVariant">
                <strong>Precise Location (GPS):</strong> Collected while recording rides, providing turn-by-turn navigation, and running SOS emergency crash detection.
              </p>
              <p className="text-sm text-onSurfaceVariant">
                <strong>Background Location:</strong> When a ride recording or emergency monitoring session is active, RiderMate collects location data even when the app is minimized or running in the background to ensure continuous route tracking, speed monitoring, and crash detection. Background location collection terminates immediately when you stop a ride or deactivate emergency tracking.
              </p>
            </div>

            <div className="space-y-2">
              <h3 className="text-base font-semibold text-white flex items-center gap-2">
                <Activity className="w-4 h-4 text-circuitOrange" />
                <span>B. Motion & Sensor Data (Accelerometer & Gyroscope)</span>
              </h3>
              <p className="text-sm text-onSurfaceVariant">
                <strong>Accelerometer Readings:</strong> Used locally by the on-device safety engine to calculate g-force impacts and detect potential motorcycle crashes.
              </p>
              <p className="text-sm text-onSurfaceVariant">
                <strong>Activity & Motion:</strong> Used to detect riding motion and trigger pre-ride briefings. Motion telemetry is processed on-device and is not shared with third-party advertising networks.
              </p>
            </div>

            <div className="space-y-2">
              <h3 className="text-base font-semibold text-white flex items-center gap-2">
                <Lock className="w-4 h-4 text-circuitOrange" />
                <span>C. Account & Personal Identification</span>
              </h3>
              <p className="text-sm text-onSurfaceVariant">
                User profile details (Name, email address, username, phone number, bio, avatar) and password hashes (stored securely using bcrypt server-side).
              </p>
            </div>

            <div className="space-y-2">
              <h3 className="text-base font-semibold text-white flex items-center gap-2">
                <Camera className="w-4 h-4 text-circuitOrange" />
                <span>D. Media, Photos & Microphone</span>
              </h3>
              <p className="text-sm text-onSurfaceVariant">
                Photos are accessed exclusively when you upload vehicle documents (RC, Insurance) or memory photos. Microphone audio is recorded only when you explicitly tap the voice note recorder in the Journal.
              </p>
            </div>
          </div>
        </section>

        <section className="glass-panel p-6 sm:p-8 rounded-2xl space-y-4">
          <h2 className="text-xl font-bold text-white">3. Data Storage & Local-First Security</h2>
          <p className="text-sm text-onSurfaceVariant leading-relaxed">
            All ride history, motorcycle maintenance logs, and sensor configurations are stored primarily on your device in an encrypted SQLite database. When cloud sync is enabled, data transmitted to RiderMate Cloud (Microsoft Azure App Service and Azure Database for PostgreSQL) is secured via TLS 1.3 in-transit and AES-256 encryption at rest.
          </p>
          <div className="p-4 rounded-xl bg-circuitOrange/10 border border-circuitOrange/30 text-xs font-mono text-circuitOrange">
            GUARANTEE: We do NOT sell, rent, or monetize your personal data, location telemetry, or riding habits to third-party advertisers or data brokers.
          </div>
        </section>

        <section className="glass-panel p-6 sm:p-8 rounded-2xl space-y-4">
          <h2 className="text-xl font-bold text-white">4. Account Deletion & Data Rights</h2>
          <p className="text-sm text-onSurfaceVariant leading-relaxed">
            You maintain complete control over your data:
          </p>
          <ul className="space-y-2 text-sm text-onSurface">
            <li className="flex items-start gap-2">
              <CheckCircle2 className="w-4 h-4 text-circuitOrange shrink-0 mt-0.5" />
              <span>You may export your complete ride history at any time in GPX / JSON format.</span>
            </li>
            <li className="flex items-start gap-2">
              <CheckCircle2 className="w-4 h-4 text-circuitOrange shrink-0 mt-0.5" />
              <span>You can request permanent deletion of your account and all associated cloud/telemetry data directly in the app under <strong>Settings &gt; Privacy &amp; Security &gt; Delete Account</strong> or by emailing <code>privacy@ridermate.app</code>.</span>
            </li>
          </ul>
        </section>
      </div>
    </div>
  );
};
