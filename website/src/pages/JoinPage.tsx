import React, { useState, useEffect } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import { Gift, Copy, Check, Download, Users, Award, Shield, ArrowRight } from 'lucide-react';
import { getActiveDownloadUrl, getDownloadButtonLabel } from '../config/downloadConfig';

export const JoinPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const [referralCode, setReferralCode] = useState('RM-PILOT1');
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    const ref = searchParams.get('ref');
    if (ref && ref.trim().length > 0) {
      setReferralCode(ref.trim().toUpperCase());
    }
  }, [searchParams]);

  const handleCopy = () => {
    navigator.clipboard.writeText(referralCode);
    setCopied(true);
    setTimeout(() => setCopied(false), 3000);
  };

  return (
    <div className="pt-28 sm:pt-36 pb-24 max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
      {/* Header */}
      <div className="text-center space-y-4">
        <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full glass-panel border border-circuitOrange/30 text-xs font-mono text-circuitOrange">
          <Gift className="w-4 h-4" />
          <span>SQUAD INVITATION</span>
        </div>
        
        <h1 className="text-3xl sm:text-5xl font-extrabold text-white tracking-tight">
          You've Been Invited to <br />
          <span className="bg-gradient-to-r from-circuitOrange to-circuitOrangeGlow bg-clip-text text-transparent">
            RiderMate 2.0
          </span>
        </h1>
        
        <p className="text-sm sm:text-base text-onSurfaceVariant max-w-lg mx-auto">
          A fellow motorcycle rider has invited you to join their riding squad. Enter their referral code during registration to unlock exclusive community badges and squad tracking.
        </p>
      </div>

      {/* Referral Code Showcase Box */}
      <div className="glass-panel rounded-3xl p-8 sm:p-12 border border-circuitOrange/30 text-center space-y-6 relative overflow-hidden shadow-2xl">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-circuitOrange/10 rounded-full blur-3xl pointer-events-none" />

        <div className="space-y-2 relative z-10">
          <span className="text-xs font-mono uppercase tracking-widest text-onSurfaceVariant">
            Your Squad Invite Code
          </span>
          <div className="inline-flex items-center gap-3 bg-black/60 px-6 py-3 rounded-2xl border border-circuitOrange/40">
            <span className="font-mono text-2xl sm:text-3xl font-extrabold text-white tracking-wider select-all">
              {referralCode}
            </span>
            <button
              onClick={handleCopy}
              className="p-2 rounded-lg bg-white/10 hover:bg-white/15 text-white transition-colors"
              title="Copy referral code"
              aria-label="Copy referral code"
            >
              {copied ? <Check className="w-5 h-5 text-emerald-400" /> : <Copy className="w-5 h-5" />}
            </button>
          </div>
          {copied && (
            <p className="text-xs text-emerald-400 font-mono">
              ✓ Referral code copied to clipboard!
            </p>
          )}
        </div>

        {/* CTA */}
        <div className="pt-4 flex flex-col sm:flex-row items-center justify-center gap-4 relative z-10">
          <a
            href={getActiveDownloadUrl()}
            className="w-full sm:w-auto inline-flex items-center justify-center gap-3 px-8 py-4 rounded-xl font-bold text-base text-white bg-gradient-to-r from-circuitOrange to-circuitOrangeGlow hover:scale-105 active:scale-95 transition-all shadow-xl shadow-circuitOrange/30"
          >
            <Download className="w-5 h-5" />
            <span>Download & Join Squad</span>
          </a>
        </div>
      </div>

      {/* 3 Step Guide */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="glass-panel p-6 rounded-2xl space-y-2 text-center">
          <div className="w-10 h-10 rounded-xl bg-circuitOrange/10 border border-circuitOrange/30 text-circuitOrange mx-auto flex items-center justify-center font-bold font-mono">
            1
          </div>
          <h3 className="font-bold text-white text-base">Download App</h3>
          <p className="text-xs text-onSurfaceVariant">
            Get the APK on your Android device and install it.
          </p>
        </div>

        <div className="glass-panel p-6 rounded-2xl space-y-2 text-center">
          <div className="w-10 h-10 rounded-xl bg-circuitOrange/10 border border-circuitOrange/30 text-circuitOrange mx-auto flex items-center justify-center font-bold font-mono">
            2
          </div>
          <h3 className="font-bold text-white text-base">Paste Invite Code</h3>
          <p className="text-xs text-onSurfaceVariant">
            Enter <strong className="text-circuitOrange font-mono">{referralCode}</strong> in the "Invite / Referral Code" box during signup.
          </p>
        </div>

        <div className="glass-panel p-6 rounded-2xl space-y-2 text-center">
          <div className="w-10 h-10 rounded-xl bg-circuitOrange/10 border border-circuitOrange/30 text-circuitOrange mx-auto flex items-center justify-center font-bold font-mono">
            3
          </div>
          <h3 className="font-bold text-white text-base">Ride Together</h3>
          <p className="text-xs text-onSurfaceVariant">
            Unlock the Squad Recruiter badge, view live rider radar, and track group rides!
          </p>
        </div>
      </div>
    </div>
  );
};
