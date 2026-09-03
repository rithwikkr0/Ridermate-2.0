import React, { useState } from 'react';

export const ScreenshotShowcase: React.FC = () => {
  const [selectedCategory, setSelectedCategory] = useState<'all' | 'cockpit' | 'community' | 'profile' | 'garage'>('all');

  const items = [
    {
      id: 'dashboard',
      category: 'cockpit',
      title: 'Kinetic Cockpit HUD',
      subtitle: 'Real-time 118 km/h telemetry, lean angle gauges, dynamic G-force, and SOS readiness.',
      image: '/screenshots/cockpit_dashboard.png',
      tag: 'HUD & TELEMETRY'
    },
    {
      id: 'nav',
      category: 'cockpit',
      title: 'Turn Navigation & Vector Radar',
      subtitle: 'Expressway guidance, real-time speed limit advisory, and live trajectory routing.',
      image: '/screenshots/navigation_ride.png',
      tag: 'MAPS & GPS'
    },
    {
      id: 'squads',
      category: 'community',
      title: 'Tactical Squad Convoy Radar',
      subtitle: 'Live proximity radar (500m), echelon convoy spacing, and encrypted mesh voice comms.',
      image: '/screenshots/squads_community.png',
      tag: 'SQUAD CONVOY'
    },
    {
      id: 'garage',
      category: 'garage',
      title: 'Digital Motorcycle Vault',
      subtitle: 'RC legal records (KA 04 EL 274), active insurance validity, PUC expiry & service countdown.',
      image: '/screenshots/garage_management.png',
      tag: 'MY GARAGE'
    },
    {
      id: 'profile',
      category: 'profile',
      title: 'Pilot Profile & XP Leveling',
      subtitle: 'Level 7 Touring Legend rank, 18,450 XP, 4,820 km logged, and unlocked trophy badges.',
      image: '/screenshots/pilot_profile.png',
      tag: 'ACHIEVEMENTS'
    },
    {
      id: 'memories',
      category: 'profile',
      title: 'Ride Memories & Telemetry Logs',
      subtitle: 'Western Ghats Monsoon pass highlight, elevation profile (1,420m), and voice memos.',
      image: '/screenshots/memories_journal.png',
      tag: 'JOURNAL'
    },
  ];

  const filtered = selectedCategory === 'all'
    ? items
    : items.filter((i) => i.category === selectedCategory);

  return (
    <div className="w-full max-w-6xl mx-auto space-y-8">
      {/* Category Tabs */}
      <div className="flex flex-wrap items-center justify-center gap-2">
        {[
          { id: 'all', label: 'All Screens' },
          { id: 'cockpit', label: 'Cockpit & Radar' },
          { id: 'community', label: 'Squads & Convoy' },
          { id: 'garage', label: 'Garage & Vault' },
          { id: 'profile', label: 'Profile & Memories' },
        ].map((tab) => (
          <button
            key={tab.id}
            onClick={() => setSelectedCategory(tab.id as any)}
            className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${
              selectedCategory === tab.id
                ? 'bg-circuitOrange text-white shadow-lg shadow-circuitOrange/30'
                : 'glass-panel text-onSurfaceVariant hover:text-white'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filtered.map((item) => (
          <div
            key={item.id}
            className="glass-panel glass-panel-hover rounded-3xl p-4 sm:p-5 border border-white/10 flex flex-col justify-between group overflow-hidden"
          >
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-[10px] font-mono font-bold uppercase tracking-wider text-circuitOrange px-2.5 py-0.5 rounded-full bg-circuitOrange/10 border border-circuitOrange/30">
                  {item.tag}
                </span>
              </div>

              {/* Smartphone Frame - True 19.5:9 Uncropped Portrait Orientation */}
              <div className="relative rounded-[32px] overflow-hidden bg-[#07080B] aspect-[1080/2340] max-h-[460px] mx-auto border-[4px] border-[#1E232E] group-hover:border-circuitOrange/60 transition-all duration-300 shadow-2xl flex items-center justify-center">
                {/* Speaker Notch */}
                <div className="absolute top-2 z-20 w-16 h-3 bg-black rounded-full border border-white/10" />

                {/* Full Uncropped High-Res Screen */}
                <img
                  src={item.image}
                  alt={item.title}
                  loading="lazy"
                  className="w-full h-full object-contain group-hover:scale-105 transition-transform duration-500"
                />
              </div>

              <div>
                <h4 className="text-base font-bold text-white group-hover:text-circuitOrange transition-colors">
                  {item.title}
                </h4>
                <p className="text-xs text-onSurfaceVariant leading-relaxed mt-1">
                  {item.subtitle}
                </p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
