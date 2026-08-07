import React from 'react';
import { Users, Share2, Award, Star } from 'lucide-react';

export const Social: React.FC = () => {
  const leaderboard = [
    { rank: 1, name: 'Rahul K.', points: 1250, score: 98 },
    { rank: 2, name: 'You', points: 980, score: 92 },
    { rank: 3, name: 'Sneha P.', points: 850, score: 89 },
    { rank: 4, name: 'Amit B.', points: 720, score: 75 },
  ];

  return (
    <div className="p-4 pb-24 min-h-screen bg-gray-950">
      <h1 className="text-2xl font-bold text-white mb-6">Community</h1>

      {/* Travel with Friends Teaser */}
      <div className="bg-gradient-to-r from-blue-600 to-indigo-700 rounded-xl p-6 mb-8 text-white shadow-lg">
         <div className="flex justify-between items-center mb-2">
            <h2 className="font-bold text-lg">Travel with Friends</h2>
            <Users className="text-white/80" />
         </div>
         <p className="text-white/80 text-sm mb-4">Live location sharing for group rides coming soon!</p>
         <button className="bg-white/20 hover:bg-white/30 px-4 py-2 rounded-lg text-sm font-bold flex items-center">
            <Share2 size={16} className="mr-2" /> Invite Friends
         </button>
      </div>

      {/* Leaderboard */}
      <h2 className="text-xl font-bold text-white mb-4 flex items-center">
        <Award className="text-brand-orange mr-2" /> Weekly Leaderboard
      </h2>
      
      <div className="bg-brand-card rounded-xl border border-gray-800 overflow-hidden">
        {leaderboard.map((user, idx) => (
          <div key={idx} className={`flex items-center p-4 border-b border-gray-800 ${user.name === 'You' ? 'bg-brand-orange/10' : ''}`}>
             <div className="w-8 text-center font-bold text-gray-500">{user.rank}</div>
             <div className="w-10 h-10 rounded-full bg-gray-700 mx-4 flex items-center justify-center text-gray-300 font-bold">
               {user.name.charAt(0)}
             </div>
             <div className="flex-1">
               <div className={`font-bold ${user.name === 'You' ? 'text-brand-orange' : 'text-white'}`}>{user.name}</div>
               <div className="text-xs text-gray-500">{user.score} Safety Score</div>
             </div>
             <div className="flex items-center text-brand-teal font-bold">
               {user.points} <Star size={12} className="ml-1 fill-current" />
             </div>
          </div>
        ))}
      </div>

      <div className="mt-8 text-center">
        <div className="inline-block bg-gray-800 rounded-lg p-4 border border-gray-700 border-dashed">
          <p className="text-gray-400 text-xs uppercase tracking-widest mb-1">Your Referral Code</p>
          <p className="text-xl font-mono text-white tracking-widest">RIDER-2024</p>
        </div>
      </div>
    </div>
  );
};