import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Play, Trophy, AlertTriangle, MapPin, ChevronRight, Bot } from 'lucide-react';
import { getProfile, getWeeklyStats } from '../services/storageService';
import { UserProfile } from '../types';

export const Home: React.FC = () => {
  const navigate = useNavigate();
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [stats, setStats] = useState<any>(null);

  useEffect(() => {
    setProfile(getProfile());
    setStats(getWeeklyStats());
  }, []);

  if (!profile || !stats) return <div className="p-4 text-white">Loading...</div>;

  return (
    <div className="p-4 pb-24 space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-white">Hello, {profile.name} 👋</h1>
          <p className="text-gray-400 text-sm">Ready to ride safely today?</p>
        </div>
        <div 
          onClick={() => navigate('/profile')}
          className="w-10 h-10 rounded-full bg-brand-teal/20 flex items-center justify-center text-brand-teal font-bold border border-brand-teal cursor-pointer"
        >
          {profile.name.charAt(0)}
        </div>
      </div>

      {/* Start Ride Card */}
      <div 
        onClick={() => navigate('/ride')}
        className="bg-gradient-to-r from-brand-orange to-red-500 rounded-2xl p-6 shadow-lg shadow-brand-orange/20 cursor-pointer transform transition active:scale-95"
      >
        <div className="flex justify-between items-center">
          <div>
            <h2 className="text-white font-bold text-xl">Start New Ride</h2>
            <p className="text-white/80 text-sm mt-1">Track speed & safety</p>
          </div>
          <div className="bg-white/20 p-3 rounded-full">
            <Play fill="white" className="text-white" size={28} />
          </div>
        </div>
      </div>

      {/* Weekly Stats Summary */}
      <div className="grid grid-cols-2 gap-4">
        <div className="bg-brand-card rounded-xl p-4 border border-gray-800">
          <div className="flex items-center space-x-2 text-gray-400 mb-2">
            <Trophy size={16} className="text-yellow-500" />
            <span className="text-xs uppercase font-bold">Safety Score</span>
          </div>
          <div className={`text-2xl font-bold ${stats.avgScore > 80 ? 'text-green-500' : stats.avgScore > 50 ? 'text-yellow-500' : 'text-red-500'}`}>
            {stats.avgScore}<span className="text-sm text-gray-500">/100</span>
          </div>
        </div>
        <div className="bg-brand-card rounded-xl p-4 border border-gray-800">
          <div className="flex items-center space-x-2 text-gray-400 mb-2">
            <AlertTriangle size={16} className="text-red-500" />
            <span className="text-xs uppercase font-bold">Overspeeds</span>
          </div>
          <div className="text-2xl font-bold text-white">
            {stats.totalOverspeeds}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="space-y-3">
        <h3 className="text-white font-bold text-lg">Quick Actions</h3>
        
        <button onClick={() => navigate('/memories')} className="w-full bg-brand-card p-4 rounded-xl flex items-center justify-between border border-gray-800 hover:bg-gray-800 transition">
          <div className="flex items-center space-x-4">
            <div className="bg-blue-500/20 p-2 rounded-lg text-blue-400">
              <MapPin size={20} />
            </div>
            <div className="text-left">
              <div className="text-white font-medium">Ride Memories</div>
              <div className="text-gray-500 text-xs">View saved locations & notes</div>
            </div>
          </div>
          <ChevronRight className="text-gray-600" size={20} />
        </button>

        <button onClick={() => navigate('/social')} className="w-full bg-brand-card p-4 rounded-xl flex items-center justify-between border border-gray-800 hover:bg-gray-800 transition">
          <div className="flex items-center space-x-4">
            <div className="bg-purple-500/20 p-2 rounded-lg text-purple-400">
              <Trophy size={20} />
            </div>
            <div className="text-left">
              <div className="text-white font-medium">Leaderboard</div>
              <div className="text-gray-500 text-xs">Compare with friends</div>
            </div>
          </div>
          <ChevronRight className="text-gray-600" size={20} />
        </button>
      </div>

      {/* AI Coach Teaser */}
      <div 
        onClick={() => navigate('/coach')}
        className="bg-brand-card border border-brand-teal/30 rounded-xl p-4 flex items-center space-x-4 cursor-pointer"
      >
         <div className="bg-brand-teal/20 p-3 rounded-full text-brand-teal">
            <Bot size={24} />
         </div>
         <div className="flex-1">
            <h4 className="text-white font-bold">AI Safety Coach</h4>
            <p className="text-gray-400 text-xs">Get tips based on your recent rides.</p>
         </div>
         <div className="bg-brand-teal px-3 py-1 rounded-full text-xs text-black font-bold">
            Ask
         </div>
      </div>
    </div>
  );
};