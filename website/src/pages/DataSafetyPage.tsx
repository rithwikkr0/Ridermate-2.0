import React from 'react';
import { ShieldCheck, Lock, CheckCircle2, AlertCircle } from 'lucide-react';

export const DataSafetyPage: React.FC = () => {
  return (
    <div className="pt-28 sm:pt-36 pb-24 max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 space-y-10">
      {/* Header */}
      <div className="space-y-4 border-b border-white/10 pb-8">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-xs font-mono text-emerald-400">
          <ShieldCheck className="w-3.5 h-3.5" />
          <span>GOOGLE PLAY DATA SAFETY TRANSPARENCY</span>
        </div>
        <h1 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
          Data Safety Declaration
        </h1>
        <p className="text-sm text-onSurfaceVariant">
          Official Google Play Data Safety declaration and disclosure matrix for RiderMate 2.0 (<code>com.ridermate.ridermate</code>).
        </p>
      </div>

      {/* Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="glass-panel p-6 rounded-2xl space-y-2">
          <div className="w-8 h-8 rounded-lg bg-emerald-500/10 text-emerald-400 flex items-center justify-center">
            <Lock className="w-4 h-4" />
          </div>
          <h3 className="font-bold text-white text-base">Encrypted in Transit</h3>
          <p className="text-xs text-onSurfaceVariant">
            All data transmitted to cloud services uses modern TLS 1.3 encryption protocols.
          </p>
        </div>

        <div className="glass-panel p-6 rounded-2xl space-y-2">
          <div className="w-8 h-8 rounded-lg bg-emerald-500/10 text-emerald-400 flex items-center justify-center">
            <CheckCircle2 className="w-4 h-4" />
          </div>
          <h3 className="font-bold text-white text-base">Account Deletion</h3>
          <p className="text-xs text-onSurfaceVariant">
            Users can permanently delete their account and associated data directly within the app.
          </p>
        </div>

        <div className="glass-panel p-6 rounded-2xl space-y-2">
          <div className="w-8 h-8 rounded-lg bg-emerald-500/10 text-emerald-400 flex items-center justify-center">
            <ShieldCheck className="w-4 h-4" />
          </div>
          <h3 className="font-bold text-white text-base">No Data Brokering</h3>
          <p className="text-xs text-onSurfaceVariant">
            We never share or monetize your private riding habits with third-party advertisers.
          </p>
        </div>
      </div>

      {/* Disclosures Table */}
      <div className="glass-panel rounded-2xl p-6 overflow-x-auto border border-white/10 space-y-6">
        <h2 className="text-lg font-bold text-white">Collected Data Disclosures Matrix</h2>
        
        <table className="w-full text-left text-xs sm:text-sm">
          <thead>
            <tr className="border-b border-white/10 text-onSurfaceVariant font-mono text-[11px] uppercase">
              <th className="pb-3 pr-4">Data Type</th>
              <th className="pb-3 px-4">Collected?</th>
              <th className="pb-3 px-4">Shared?</th>
              <th className="pb-3 px-4">Purpose</th>
              <th className="pb-3 pl-4">Requirement</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-white/5 text-onSurface">
            <tr>
              <td className="py-3 pr-4 font-semibold text-white">Precise Location (GPS)</td>
              <td className="py-3 px-4 text-emerald-400 font-mono">Yes</td>
              <td className="py-3 px-4 text-onSurfaceVariant">Only SOS contacts</td>
              <td className="py-3 px-4 text-onSurfaceVariant">Live ride navigation &amp; SOS crash alerts</td>
              <td className="py-3 pl-4 text-circuitOrange font-mono">Required</td>
            </tr>
            <tr>
              <td className="py-3 pr-4 font-semibold text-white">Personal Information</td>
              <td className="py-3 px-4 text-emerald-400 font-mono">Yes</td>
              <td className="py-3 px-4 text-onSurfaceVariant">Approved friends</td>
              <td className="py-3 px-4 text-onSurfaceVariant">Account auth &amp; squad community profiles</td>
              <td className="py-3 pl-4 text-circuitOrange font-mono">Required</td>
            </tr>
            <tr>
              <td className="py-3 pr-4 font-semibold text-white">Photos &amp; Documents</td>
              <td className="py-3 px-4 text-emerald-400 font-mono">Yes</td>
              <td className="py-3 px-4 text-onSurfaceVariant">Public feed only</td>
              <td className="py-3 px-4 text-onSurfaceVariant">Vehicle document vault &amp; memory photos</td>
              <td className="py-3 pl-4 text-onSurfaceVariant font-mono">Optional</td>
            </tr>
            <tr>
              <td className="py-3 pr-4 font-semibold text-white">Voice &amp; Audio Notes</td>
              <td className="py-3 px-4 text-emerald-400 font-mono">Yes</td>
              <td className="py-3 px-4 text-onSurfaceVariant">No (Local only)</td>
              <td className="py-3 px-4 text-onSurfaceVariant">Explicit journal voice note recordings</td>
              <td className="py-3 pl-4 text-onSurfaceVariant font-mono">Optional</td>
            </tr>
            <tr>
              <td className="py-3 pr-4 font-semibold text-white">Sensor &amp; Motion Telemetry</td>
              <td className="py-3 px-4 text-emerald-400 font-mono">Yes</td>
              <td className="py-3 px-4 text-onSurfaceVariant">No</td>
              <td className="py-3 px-4 text-onSurfaceVariant">On-device high-G crash detection algorithms</td>
              <td className="py-3 pl-4 text-onSurfaceVariant font-mono">Optional</td>
            </tr>
            <tr>
              <td className="py-3 pr-4 font-semibold text-white">Ride Speed &amp; Mileage</td>
              <td className="py-3 px-4 text-emerald-400 font-mono">Yes</td>
              <td className="py-3 px-4 text-onSurfaceVariant">No</td>
              <td className="py-3 px-4 text-onSurfaceVariant">Rider analytics, safety scores &amp; garage maintenance</td>
              <td className="py-3 pl-4 text-circuitOrange font-mono">Required</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
};
