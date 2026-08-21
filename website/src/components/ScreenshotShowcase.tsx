import React, { useState } from 'react';
import { Smartphone, Sparkles, Eye, Shield, Compass, Users, Wrench, Award } from 'lucide-react';

export const ScreenshotShowcase: React.FC = () => {
  const [selectedCategory, setSelectedCategory] = useState<'all' | 'cockpit' | 'community' | 'profile'>('all');

  const items = [
    {
      id: 'dashboard',
      category: 'cockpit',
      title: 'Cockpit Dashboard',
      subtitle: 'Real-time telemetry, weather readiness index, battery health & quick actions.',
      image: '/screenshots/cockpit_dashboard.png',
      tag: 'HUD & TELEMETRY'
    },
    {
      id: 'nav',
      category: 'cockpit',
      title: 'Turn Navigation & Vector Map',
      subtitle: 'Dynamic CartoDB Dark Matter tiles, speed limit alerts, and GPX trail recording.',
      image: '/screenshots/navigation_ride.png',
      tag: 'MAPS & GPS'
    },
    {
      id: 'squads',
      category: 'community',
      title: 'Squads & Contact Matching',
      subtitle: 'Live pilot radar, group chats, and privacy-preserving SHA-256 phone matching.',
      image: '/screenshots/squads_community.png',
      tag: 'P2P SQUADS'
    },
    {
      id: 'profile',
      category: 'profile',
      title: 'Pilot Profile & XP Leveling',
      subtitle: 'XP milestones from Novice to Legend, achievement badges, and safety logs.',
      image: '/screenshots/pilot_profile.png',
      tag: 'GAMIFICATION'
    },
    {
      id: 'memories',
      category: 'profile',
      title: 'Ride Memories & Voice Notes',
      subtitle: 'Voice note captures, high-res ride photos, and interactive map memory pins.',
      image: '/screenshots/memories_journal.png',
      tag: 'MEMORIES'
    },
  ];

  const filtered = selectedCategory === 'all'
    ? items
    : items.filter((i) => i.category === selectedCategory);

  return (
    <div className="w-full max-w-6xl mx-auto space-y-8">
      {/* Category Tabs */}
      <div className="flex flex-wrap items-center justify-center gap-2">
        <button
          onClick={() => setSelectedCategory('all')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            selectedCategory === 'all'
              ? 'bg-circuitOrange text-white shadow-lg shadow-circuitOrange/30'
              : 'glass-panel text-onSurfaceVariant hover:text-white'
          }`}
        >
          All Screens
        </button>
        <button
          onClick={() => setSelectedCategory('cockpit')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            selectedCategory === 'cockpit'
              ? 'bg-circuitOrange text-white shadow-lg shadow-circuitOrange/30'
              : 'glass-panel text-onSurfaceVariant hover:text-white'
          }`}
        >
          Cockpit & Navigation
        </button>
        <button
          onClick={() => setSelectedCategory('community')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            selectedCategory === 'community'
              ? 'bg-circuitOrange text-white shadow-lg shadow-circuitOrange/30'
              : 'glass-panel text-onSurfaceVariant hover:text-white'
          }`}
        >
          Squads & Community
        </button>
        <button
          onClick={() => setSelectedCategory('profile')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            selectedCategory === 'profile'
              ? 'bg-circuitOrange text-white shadow-lg shadow-circuitOrange/30'
              : 'glass-panel text-onSurfaceVariant hover:text-white'
          }`}
        >
          Profile & Milestones
        </button>
      </div>

      {/* Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filtered.map((item) => (
          <div
            key={item.id}
            className="glass-panel glass-panel-hover rounded-3xl p-4 sm:p-5 border border-white/10 flex flex-col justify-between group overflow-hidden"
          >
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-[10px] font-mono font-bold uppercase tracking-wider text-circuitOrange px-2.5 py-0.5 rounded-full bg-circuitOrange/10 border border-circuitOrange/30">
                  {item.tag}
                </span>
              </div>

              {/* High-res Screenshot Frame */}
              <div className="relative rounded-2xl overflow-hidden bg-black/80 aspect-[9/16] max-h-[380px] flex items-center justify-center border border-white/5">
                <img
                  src={item.image}
                  alt={item.title}
                  loading="lazy"
                  className="w-full h-full object-cover object-top group-hover:scale-105 transition-transform duration-500"
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
