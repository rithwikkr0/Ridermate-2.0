import React, { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { Hero3DCanvas } from '../components/Hero3DCanvas';
import { TiltCard } from '../components/TiltCard';
import { CountUp } from '../components/CountUp';
import { ScreenshotShowcase } from '../components/ScreenshotShowcase';

/* ── Icon helpers (inline SVG to avoid extra deps) ── */
const Icon = {
  Download: () => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-5 h-5">
      <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ),
  ArrowRight: () => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} className="w-4 h-4">
      <path d="M5 12h14M12 5l7 7-7 7" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ),
  Shield: () => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} className="w-6 h-6">
      <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ),
  Navigation: () => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} className="w-6 h-6">
      <polygon points="3 11 22 2 13 21 11 13 3 11" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ),
  Users: () => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} className="w-6 h-6">
      <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2M9 11a4 4 0 100-8 4 4 0 000 8zM23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ),
  Camera: () => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} className="w-6 h-6">
      <path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z" strokeLinecap="round" strokeLinejoin="round" />
      <circle cx="12" cy="13" r="4" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ),
  Zap: () => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} className="w-6 h-6">
      <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ),
  Star: () => (
    <svg viewBox="0 0 24 24" fill="currentColor" className="w-4 h-4 text-yellow-400">
      <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
    </svg>
  ),
  Map: () => (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} className="w-6 h-6">
      <polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6" strokeLinecap="round" strokeLinejoin="round" />
      <line x1="8" y1="2" x2="8" y2="18" strokeLinecap="round" />
      <line x1="16" y1="6" x2="16" y2="22" strokeLinecap="round" />
    </svg>
  ),
};

/* ── Feature Card ── */
interface FeatureCardProps {
  icon: React.ReactNode;
  title: string;
  description: string;
  tag?: string;
  delay?: number;
}

const FeatureCard: React.FC<FeatureCardProps> = ({ icon, title, description, tag, delay = 0 }) => {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const obs = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) {
        setTimeout(() => {
          el.style.opacity = '1';
          el.style.transform = 'translateY(0px)';
        }, delay);
        obs.disconnect();
      }
    }, { threshold: 0.15 });
    obs.observe(el);
    return () => obs.disconnect();
  }, [delay]);

  return (
    <TiltCard intensity={8}>
      <div
        ref={ref}
        style={{ opacity: 0, transform: 'translateY(32px)', transition: 'opacity 0.6s ease, transform 0.6s ease' }}
        className="glass glass-panel-hover rounded-2xl p-6 h-full relative overflow-hidden group"
      >
        {/* Gradient accent top-left */}
        <div className="absolute top-0 left-0 w-32 h-32 rounded-full bg-circuitOrange/5 blur-2xl -translate-x-8 -translate-y-8 group-hover:bg-circuitOrange/10 transition-all duration-700" />

        <div className="relative z-10">
          {tag && (
            <span className="inline-block px-2 py-0.5 text-xs font-medium text-circuitOrange bg-circuitOrange/10 border border-circuitOrange/20 rounded-full mb-4">
              {tag}
            </span>
          )}
          <div className="w-12 h-12 rounded-xl bg-circuitOrange/10 border border-circuitOrange/20 flex items-center justify-center text-circuitOrange mb-4">
            {icon}
          </div>
          <h3 className="text-lg font-semibold text-onSurface mb-2">{title}</h3>
          <p className="text-sm text-onSurfaceVariant leading-relaxed">{description}</p>
        </div>
      </div>
    </TiltCard>
  );
};

/* ── Smartphone Screenshot Frame ── */
const ScreenshotCard: React.FC<{ src: string; label: string; tag?: string; active?: boolean }> = ({ src, label, tag, active }) => (
  <TiltCard intensity={10} className="flex-shrink-0">
    <div className="flex flex-col items-center">
      {/* Realistic Smartphone Shell (True 19.5:9 Aspect Ratio) */}
      <div className={`relative w-[260px] h-[563px] bg-[#07080B] rounded-[42px] border-[5px] transition-all duration-500 overflow-hidden flex flex-col items-center shadow-2xl ${
        active 
          ? 'border-circuitOrange shadow-[0_0_45px_rgba(255,107,0,0.35)] scale-[1.02]' 
          : 'border-[#1E232E] hover:border-white/20'
      }`}>
        {/* Dynamic Island / Speaker Pill */}
        <div className="absolute top-2.5 z-30 w-24 h-4 bg-black rounded-full border border-white/10 flex items-center justify-center">
          <div className="w-2.5 h-2.5 rounded-full bg-[#111] border border-white/20 mr-2" />
        </div>

        {/* Screen Content - Full Uncropped 1080x2340 Portrait */}
        <div className="w-full h-full relative overflow-hidden bg-black">
          <img 
            src={src} 
            alt={label} 
            className="w-full h-full object-contain" 
            loading="lazy" 
          />
        </div>

        {/* Glossy Edge Reflection */}
        <div className="absolute inset-0 pointer-events-none rounded-[36px] bg-gradient-to-tr from-white/0 via-white/5 to-white/0 opacity-60" />
      </div>

      {/* Label & Tag Underneath */}
      <div className="mt-4 text-center">
        {tag && (
          <span className="inline-block px-2.5 py-0.5 text-[10px] font-mono font-bold text-circuitOrange bg-circuitOrange/10 border border-circuitOrange/20 rounded-full mb-1">
            {tag}
          </span>
        )}
        <p className="text-sm font-semibold text-white/90">{label}</p>
      </div>
    </div>
  </TiltCard>
);

/* ── Stat Badge ── */
const StatBadge: React.FC<{ value: React.ReactNode; label: string }> = ({ value, label }) => (
  <div className="glass rounded-2xl p-6 text-center border border-white/6 hover:border-circuitOrange/30 transition-all duration-300">
    <div className="text-4xl font-bold gradient-text mb-1">{value}</div>
    <div className="text-xs text-onSurfaceVariant uppercase tracking-widest">{label}</div>
  </div>
);

/* ── Main Page ── */
export const HomePage: React.FC = () => {
  const [activeShot, setActiveShot] = useState(0);
  const galleryRef = useRef<HTMLDivElement>(null);

  const screenshots = [
    { src: '/screenshots/cockpit_dashboard.png', label: 'Kinetic Cockpit HUD', tag: 'TELEMETRY' },
    { src: '/screenshots/navigation_ride.png', label: 'Turn Navigation & Vector Radar', tag: 'GPS & ROUTING' },
    { src: '/screenshots/squads_community.png', label: 'Squad Radar & Convoy Sync', tag: 'COMMUNITY' },
    { src: '/screenshots/garage_management.png', label: 'Digital Motorcycle Vault', tag: 'MY GARAGE' },
    { src: '/screenshots/pilot_profile.png', label: 'Pilot Profile & XP Leveling', tag: 'GAMIFICATION' },
    { src: '/screenshots/memories_journal.png', label: 'Ride Memories & Telemetry Logs', tag: 'JOURNAL' },
  ];

  // Auto-cycle screenshots
  useEffect(() => {
    const id = setInterval(() => setActiveShot((p) => (p + 1) % screenshots.length), 3500);
    return () => clearInterval(id);
  }, [screenshots.length]);

  const features = [
    {
      icon: <Icon.Zap />,
      title: 'Real-time Cockpit HUD',
      description: 'Live speed, lean angle, g-force, and engine telemetry rendered in a glass-morphic heads-up display designed for riders.',
      tag: 'CORE',
    },
    {
      icon: <Icon.Navigation />,
      title: 'Riding Navigation',
      description: 'Turn-by-turn navigation built for motorcycles — wide roads, ghat routes, and scenic pass routing with offline maps.',
      tag: 'MAPS',
    },
    {
      icon: <Icon.Shield />,
      title: 'SOS & Crash Detection',
      description: 'Automatic crash detection using accelerometer and gyroscope. Alerts your emergency contacts with GPS coordinates instantly.',
      tag: 'SAFETY',
    },
    {
      icon: <Icon.Users />,
      title: 'Squads & Group Rides',
      description: 'Create squads, plan group rides, share live locations, and ride together with real-time convoy tracking.',
    },
    {
      icon: <Icon.Camera />,
      title: 'Ride Memories',
      description: 'Every ride auto-generates a highlight reel with route replay, top speed, elevation gain, and milestone photos.',
    },
    {
      icon: <Icon.Map />,
      title: 'Route Intelligence',
      description: 'AI-curated routes based on your riding style — adventure, sport, touring — with community ratings and road condition alerts.',
    },
  ];

  return (
    <div className="overflow-hidden">
      {/* ═══ HERO ═══ */}
      <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
        {/* 3D WebGL Background */}
        <Hero3DCanvas />

        {/* Radial dark vignette */}
        <div className="absolute inset-0 z-[1]" style={{
          background: 'radial-gradient(ellipse 80% 70% at 50% 50%, transparent 0%, rgba(6,7,9,0.6) 70%, rgba(6,7,9,0.95) 100%)',
        }} />

        {/* Bottom fade to content */}
        <div className="absolute bottom-0 left-0 right-0 h-48 z-[1]"
          style={{ background: 'linear-gradient(to bottom, transparent, #060709)' }} />

        {/* Hero content */}
        <div className="relative z-10 max-w-5xl mx-auto px-6 text-center pt-24 pb-16">
          {/* Badge */}
          <div className="inline-flex items-center gap-2 px-4 py-2 glass rounded-full border border-circuitOrange/30 mb-8 animate-pulse-slow">
            <span className="w-2 h-2 rounded-full bg-circuitOrange animate-ping" />
            <span className="text-xs font-medium text-circuitOrange uppercase tracking-widest">
              Now Available — Android
            </span>
          </div>

          {/* Main heading */}
          <h1 className="text-6xl sm:text-7xl md:text-8xl font-extrabold tracking-tight mb-6 leading-none">
            <span className="gradient-text-white">Ride Like A</span>
            <br />
            <span className="gradient-text">Fighter Pilot.</span>
          </h1>

          <p className="text-lg md:text-xl text-onSurfaceVariant max-w-2xl mx-auto leading-relaxed mb-10">
            RiderMate turns your motorcycle into a kinetic cockpit. Real-time HUD, crash detection,
            squad rides, and AI-curated routes — built for riders who demand more.
          </p>

          {/* CTA row */}
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link
              to="/download"
              className="shimmer-btn group flex items-center gap-3 px-8 py-4 bg-circuitOrange text-white font-bold rounded-2xl text-base glow-orange hover:bg-circuitOrangeGlow transition-all duration-300"
            >
              <Icon.Download />
              Download Free APK
              <span className="text-xs opacity-70 font-normal">v2.0</span>
            </Link>
            <a
              href="#features"
              className="flex items-center gap-2 px-8 py-4 glass border border-white/10 text-onSurface font-medium rounded-2xl text-base hover:border-circuitOrange/40 transition-all duration-300"
            >
              Explore Features
              <Icon.ArrowRight />
            </a>
          </div>

          {/* Social proof */}
          <div className="flex items-center justify-center gap-2 mt-8">
            {[...Array(5)].map((_, i) => <Icon.Star key={i} />)}
            <span className="text-sm text-onSurfaceVariant ml-1">
              Trusted by riders across India
            </span>
          </div>
        </div>
      </section>

      {/* ═══ STATS ═══ */}
      <section className="relative py-16 px-6">
        <div className="max-w-4xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-4">
          <StatBadge
            value={<CountUp end={15000} suffix="+" duration={2200} />}
            label="Active Riders"
          />
          <StatBadge
            value={<CountUp end={480} suffix="K" duration={2000} />}
            label="KM Ridden"
          />
          <StatBadge
            value={<CountUp end={2800} suffix="+" duration={1800} />}
            label="Routes Shared"
          />
          <StatBadge
            value={<CountUp end={99} suffix="%" duration={2500} />}
            label="Crash Alert Accuracy"
          />
        </div>
      </section>

      {/* ═══ FEATURES ═══ */}
      <section id="features" className="py-24 px-6 mesh-bg">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <span className="inline-block px-3 py-1 text-xs font-medium text-circuitOrange bg-circuitOrange/10 border border-circuitOrange/20 rounded-full mb-4 uppercase tracking-widest">
              Features
            </span>
            <h2 className="text-4xl md:text-5xl font-bold gradient-text-white mb-4">
              Everything a rider needs.
            </h2>
            <p className="text-onSurfaceVariant max-w-xl mx-auto">
              Precision engineering meets rider culture. Six core modules built for performance, safety, and community.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {features.map((f, i) => (
              <FeatureCard key={f.title} {...f} delay={i * 100} />
            ))}
          </div>
        </div>
      </section>

      {/* ═══ APP SCREENSHOTS ═══ */}
      <section className="py-24 overflow-hidden">
        <div className="max-w-6xl mx-auto px-6 mb-12 text-center">
          <h2 className="text-4xl md:text-5xl font-bold gradient-text-white mb-4">
            See it in action.
          </h2>
          <p className="text-onSurfaceVariant">
            Every screen crafted with precision. Dark, focused, built for the road.
          </p>
        </div>

        {/* Screenshot gallery — horizontal scroll */}
        <div
          ref={galleryRef}
          className="flex gap-5 overflow-x-auto px-8 pb-6 snap-x snap-mandatory scrollbar-hide"
          style={{ scrollbarWidth: 'none' }}
        >
          {screenshots.map((s, i) => (
            <div key={s.src} className="snap-center" onClick={() => setActiveShot(i)}>
              <ScreenshotCard src={s.src} label={s.label} tag={s.tag} active={activeShot === i} />
            </div>
          ))}
          {/* Duplicate for seamless feel */}
          {screenshots.map((s, i) => (
            <div key={`dup-${s.src}`} className="snap-center">
              <ScreenshotCard src={s.src} label={s.label} tag={s.tag} />
            </div>
          ))}
        </div>

        {/* Dot indicators */}
        <div className="flex justify-center gap-2 mt-6">
          {screenshots.map((_, i) => (
            <button
              key={i}
              onClick={() => setActiveShot(i)}
              className={`w-2 h-2 rounded-full transition-all duration-300 ${activeShot === i ? 'bg-circuitOrange w-6' : 'bg-white/20'}`}
              aria-label={`Screenshot ${i + 1}`}
            />
          ))}
        </div>

        {/* Categorized Deep-Dive Showcase */}
        <div className="mt-20 px-6">
          <div className="text-center mb-10">
            <span className="inline-block px-3 py-1 text-xs font-medium text-circuitOrange bg-circuitOrange/10 border border-circuitOrange/20 rounded-full mb-3 uppercase tracking-widest">
              Screen Explorer
            </span>
            <h3 className="text-3xl font-bold gradient-text-white">
              Every Module. Full Precision.
            </h3>
          </div>
          <ScreenshotShowcase />
        </div>
      </section>

      {/* ═══ COCKPIT DEMO ═══ */}
      <section className="py-24 px-6">
        <div className="max-w-5xl mx-auto">
          <div className="glass rounded-3xl p-8 md:p-12 border border-white/6 relative overflow-hidden">
            {/* Glow accent */}
            <div className="absolute -top-20 -right-20 w-64 h-64 rounded-full bg-circuitOrange/10 blur-3xl" />
            <div className="absolute -bottom-20 -left-20 w-64 h-64 rounded-full bg-circuitOrange/5 blur-3xl" />

            <div className="relative z-10 grid md:grid-cols-2 gap-12 items-center">
              <div>
                <span className="inline-block px-3 py-1 text-xs font-medium text-circuitOrange bg-circuitOrange/10 border border-circuitOrange/20 rounded-full mb-6 uppercase tracking-widest">
                  Cockpit HUD
                </span>
                <h2 className="text-3xl md:text-4xl font-bold text-onSurface mb-4">
                  Your bike,<br />
                  <span className="gradient-text">instrumented.</span>
                </h2>
                <p className="text-onSurfaceVariant leading-relaxed mb-6">
                  Real-time speed, RPM simulation, lean angle estimation, g-force reading, and weather conditions — 
                  all rendered in a glassmorphic overlay designed to be readable at 100 km/h.
                </p>
                <Link
                  to="/download"
                  className="inline-flex items-center gap-2 text-circuitOrange font-semibold hover:gap-3 transition-all duration-200"
                >
                  Get it now <Icon.ArrowRight />
                </Link>
              </div>

              {/* Live speedometer */}
              <div className="flex flex-col items-center gap-6">
                <LiveSpeedometer />

                {/* HUD metrics */}
                <div className="grid grid-cols-3 gap-3 w-full">
                  {[
                    { label: 'Lean', value: '34°', color: 'text-blue-400' },
                    { label: 'G-Force', value: '0.8g', color: 'text-purple-400' },
                    { label: 'Mode', value: 'SPORT', color: 'text-circuitOrange' },
                  ].map(m => (
                    <div key={m.label} className="glass-orange rounded-xl p-3 text-center">
                      <div className={`text-lg font-bold ${m.color} font-mono`}>{m.value}</div>
                      <div className="text-xs text-onSurfaceVariant mt-0.5">{m.label}</div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ═══ FINAL CTA ═══ */}
      <section className="py-32 px-6 text-center relative overflow-hidden">
        <div className="absolute inset-0 mesh-bg" />
        <div className="absolute inset-0" style={{
          background: 'radial-gradient(ellipse 60% 60% at 50% 50%, rgba(255,107,0,0.08) 0%, transparent 70%)',
        }} />

        <div className="relative z-10 max-w-3xl mx-auto">
          <img src="/app_icon.png" alt="RiderMate" className="w-20 h-20 rounded-2xl mx-auto mb-6 shadow-xl" />
          <h2 className="text-5xl md:text-6xl font-extrabold gradient-text-white mb-4">
            Your cockpit awaits.
          </h2>
          <p className="text-onSurfaceVariant text-lg mb-10 max-w-xl mx-auto">
            Join thousands of riders who ride smarter, safer, and together.
          </p>
          <Link
            to="/download"
            className="shimmer-btn inline-flex items-center gap-3 px-10 py-5 bg-circuitOrange text-white font-bold rounded-2xl text-lg glow-orange hover:bg-circuitOrangeGlow transition-all duration-300"
          >
            <Icon.Download />
            Download RiderMate Free
          </Link>
          <p className="text-xs text-onSurfaceVariant mt-4">
            Android 8.0+ · 100% Free · No subscription
          </p>
        </div>
      </section>
    </div>
  );
};

/* ── Animated Speedometer ── */
const LiveSpeedometer: React.FC = () => {
  const [speed, setSpeed] = useState(0);
  const targetRef = useRef(0);
  const rafRef = useRef<number>(0);

  useEffect(() => {
    // Simulate a realistic acceleration/deceleration cycle
    const sequence = [0, 40, 80, 120, 140, 120, 80, 60, 90, 110, 130, 100, 60, 0];
    let idx = 0;
    const step = () => {
      targetRef.current = sequence[idx % sequence.length];
      idx++;
    };
    step();
    const interval = setInterval(step, 1200);

    const animate = () => {
      setSpeed(prev => {
        const diff = targetRef.current - prev;
        return prev + diff * 0.06;
      });
      rafRef.current = requestAnimationFrame(animate);
    };
    rafRef.current = requestAnimationFrame(animate);

    return () => {
      clearInterval(interval);
      cancelAnimationFrame(rafRef.current);
    };
  }, []);

  const maxSpeed = 180;
  const angle = (speed / maxSpeed) * 240 - 120; // -120° to +120°
  const cx = 80, cy = 80, r = 60;
  const rad = (a: number) => (a * Math.PI) / 180;
  const arcX = (a: number) => cx + r * Math.cos(rad(a - 90));
  const arcY = (a: number) => cy + r * Math.sin(rad(a - 90));

  // Arc path from -120° to current angle
  const startAngle = -120;
  const endAngle = angle;
  const largeArc = endAngle - startAngle > 180 ? 1 : 0;

  const arcPath = `M ${arcX(startAngle)} ${arcY(startAngle)} A ${r} ${r} 0 ${largeArc} 1 ${arcX(endAngle)} ${arcY(endAngle)}`;

  return (
    <div className="relative w-44 h-44">
      <svg viewBox="0 0 160 160" className="w-full h-full">
        {/* Background circle */}
        <circle cx={cx} cy={cy} r={r} fill="none" stroke="rgba(255,255,255,0.05)" strokeWidth="8" />
        {/* Track arc (full) */}
        <path
          d={`M ${arcX(-120)} ${arcY(-120)} A ${r} ${r} 0 1 1 ${arcX(120)} ${arcY(120)}`}
          fill="none" stroke="rgba(255,107,0,0.1)" strokeWidth="8" strokeLinecap="round"
        />
        {/* Active arc */}
        <path
          d={arcPath}
          fill="none" stroke="#FF6B00" strokeWidth="8" strokeLinecap="round"
          style={{ filter: 'drop-shadow(0 0 6px rgba(255,107,0,0.8))' }}
        />
        {/* Needle */}
        <line
          x1={cx} y1={cy}
          x2={cx + 42 * Math.cos(rad(angle - 90))}
          y2={cy + 42 * Math.sin(rad(angle - 90))}
          stroke="#FF6B00" strokeWidth="2" strokeLinecap="round"
          style={{ filter: 'drop-shadow(0 0 4px rgba(255,107,0,1))', transition: 'x2 0.05s, y2 0.05s' }}
        />
        {/* Center dot */}
        <circle cx={cx} cy={cy} r={5} fill="#FF6B00" />
        <circle cx={cx} cy={cy} r={3} fill="#060709" />

        {/* Speed label */}
        <text x={cx} y={cy + 22} textAnchor="middle" fill="#F2F4F8" fontSize="20" fontWeight="bold" fontFamily="JetBrains Mono, monospace">
          {Math.round(speed)}
        </text>
        <text x={cx} y={cy + 34} textAnchor="middle" fill="#8A9099" fontSize="8" fontFamily="Plus Jakarta Sans, sans-serif">
          km/h
        </text>
      </svg>
    </div>
  );
};
