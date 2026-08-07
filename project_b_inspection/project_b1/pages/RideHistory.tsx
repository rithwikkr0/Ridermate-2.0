import React, { useEffect, useState } from 'react';
import { Calendar, Clock, MapPin, Award } from 'lucide-react';
import { getRides } from '../services/storageService';
import { Ride } from '../types';

export const RideHistory: React.FC = () => {
  const [rides, setRides] = useState<Ride[]>([]);

  useEffect(() => {
    setRides(getRides());
  }, []);

  const formatDate = (ts: number) => {
    return new Date(ts).toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
  };

  return (
    <div className="p-4 pb-24 min-h-screen bg-gray-950">
      <h1 className="text-2xl font-bold text-white mb-6">Ride History</h1>
      
      {rides.length === 0 ? (
        <div className="text-center text-gray-500 mt-20">
          <p>No rides recorded yet.</p>
        </div>
      ) : (
        <div className="space-y-4">
          {rides.map(ride => (
            <div key={ride.id} className="bg-brand-card rounded-xl border border-gray-800 p-4 shadow-lg">
              <div className="flex justify-between items-start mb-3">
                <div className="flex items-center space-x-2">
                   <div className="bg-gray-800 p-2 rounded-lg text-brand-orange">
                      <Calendar size={20} />
                   </div>
                   <div>
                      <div className="text-white font-bold">{formatDate(ride.startTime)}</div>
                      <div className="text-xs text-gray-500">{ride.distanceKm} km ride</div>
                   </div>
                </div>
                <div className={`px-2 py-1 rounded text-xs font-bold ${ride.safetyScore > 80 ? 'bg-green-500/20 text-green-500' : 'bg-yellow-500/20 text-yellow-500'}`}>
                   Score: {ride.safetyScore}
                </div>
              </div>

              <div className="grid grid-cols-3 gap-2 mt-4 border-t border-gray-800 pt-4">
                 <div className="text-center">
                    <div className="text-gray-500 text-xs uppercase">Time</div>
                    <div className="text-white font-mono">{ride.durationMinutes}m</div>
                 </div>
                 <div className="text-center border-l border-gray-800">
                    <div className="text-gray-500 text-xs uppercase">Avg Speed</div>
                    <div className="text-white font-mono">{Math.round(ride.avgSpeed)} <span className="text-[10px]">km/h</span></div>
                 </div>
                 <div className="text-center border-l border-gray-800">
                    <div className="text-gray-500 text-xs uppercase">Points</div>
                    <div className="text-brand-orange font-bold font-mono">+{ride.points}</div>
                 </div>
              </div>
              
              {ride.overspeedEvents > 0 && (
                <div className="mt-3 bg-red-500/10 text-red-400 text-xs px-3 py-1 rounded-md inline-block">
                   {ride.overspeedEvents} Overspeed Alerts
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
};