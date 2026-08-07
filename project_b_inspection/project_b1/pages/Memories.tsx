import React, { useState, useEffect } from 'react';
import { MapPin, Plus, Lock, Globe, Users, Camera, X } from 'lucide-react';
import { getMemories, saveMemory } from '../services/storageService';
import { Memory } from '../types';

export const Memories: React.FC = () => {
  const [memories, setMemories] = useState<Memory[]>([]);
  const [isAdding, setIsAdding] = useState(false);
  const [newNote, setNewNote] = useState('');
  const [privacy, setPrivacy] = useState<'Public'|'Friends'|'Private'>('Private');
  const [hasPhoto, setHasPhoto] = useState(true); // Default to true for demo "picture format" feel

  useEffect(() => {
    setMemories(getMemories());
  }, []);

  const handleAddMemory = () => {
    if (!newNote) return;
    
    // Simulate getting location
    navigator.geolocation.getCurrentPosition((pos) => {
        saveMemoryWithLocation(pos.coords.latitude, pos.coords.longitude);
    }, () => {
        // Fallback if no GPS
        saveMemoryWithLocation(12.9716, 77.5946);
    });
  };

  const saveMemoryWithLocation = (lat: number, lng: number) => {
    // Mock image URLs for demo variance
    const mockImages = [
        "https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80",
        "https://images.unsplash.com/photo-1449426468159-d96dbf08f19f?auto=format&fit=crop&w=800&q=80",
        "https://images.unsplash.com/photo-1520699049698-acd2fcc51606?auto=format&fit=crop&w=800&q=80",
        "https://images.unsplash.com/photo-1625043484555-47841a75023e?auto=format&fit=crop&w=800&q=80"
    ];

    const memory: Memory = {
        id: Date.now().toString(),
        note: newNote,
        latitude: lat,
        longitude: lng,
        timestamp: Date.now(),
        privacy: privacy,
        imageUrl: hasPhoto ? mockImages[Math.floor(Math.random() * mockImages.length)] : undefined
    };
    saveMemory(memory);
    setMemories([memory, ...memories]);
    setIsAdding(false);
    setNewNote('');
    setHasPhoto(true);
  };

  return (
    <div className="p-4 pb-24 min-h-screen bg-gray-950">
      <div className="flex justify-between items-center mb-6">
        <div>
           <h1 className="text-2xl font-bold text-white">Moments</h1>
           <p className="text-gray-400 text-xs">Your ride gallery</p>
        </div>
        <button 
          onClick={() => setIsAdding(!isAdding)}
          className={`bg-brand-orange text-white p-3 rounded-full shadow-lg shadow-brand-orange/30 transition-transform duration-300 ${isAdding ? 'rotate-45 bg-gray-700 text-gray-300 shadow-none' : ''}`}
        >
          <Plus size={24} />
        </button>
      </div>

      {isAdding && (
        <div className="fixed inset-0 z-[100] bg-black/80 backdrop-blur-sm flex items-end sm:items-center justify-center p-4">
           <div className="bg-brand-card w-full max-w-md rounded-2xl border border-gray-700 overflow-hidden shadow-2xl animate-fade-in-up mb-6 sm:mb-0">
              <div className="p-4 border-b border-gray-800 flex justify-between items-center bg-gray-900">
                 <h3 className="text-white font-bold">New Memory</h3>
                 <button onClick={() => setIsAdding(false)} className="text-gray-400 hover:text-white"><X size={20}/></button>
              </div>
              
              <div className="p-4 space-y-4">
                 <textarea
                   className="w-full bg-gray-900 text-white rounded-lg p-3 border border-gray-700 focus:border-brand-orange focus:outline-none placeholder-gray-500 resize-none"
                   placeholder="Describe this moment..."
                   rows={3}
                   value={newNote}
                   onChange={e => setNewNote(e.target.value)}
                 />

                 <div className="flex gap-2">
                    <button 
                       onClick={() => setHasPhoto(!hasPhoto)}
                       className={`flex-1 py-3 rounded-lg flex items-center justify-center space-x-2 border transition ${hasPhoto ? 'bg-brand-teal/10 border-brand-teal text-brand-teal' : 'bg-gray-800 border-gray-700 text-gray-400'}`}
                    >
                       <Camera size={18} />
                       <span className="text-sm font-bold">{hasPhoto ? 'Photo Attached' : 'Attach Photo'}</span>
                    </button>
                 </div>

                 <div className="flex items-center justify-between pt-2">
                    <div className="flex items-center space-x-2 bg-gray-800 rounded-lg p-1 pr-3">
                       <select 
                         value={privacy}
                         onChange={(e) => setPrivacy(e.target.value as any)}
                         className="bg-transparent text-white text-xs font-bold p-1 outline-none cursor-pointer"
                       >
                         <option value="Private">Private</option>
                         <option value="Friends">Friends</option>
                         <option value="Public">Public</option>
                       </select>
                       {privacy === 'Private' && <Lock size={12} className="text-gray-400" />}
                       {privacy === 'Friends' && <Users size={12} className="text-blue-400" />}
                       {privacy === 'Public' && <Globe size={12} className="text-green-400" />}
                    </div>

                    <button 
                      onClick={handleAddMemory}
                      className="bg-brand-orange text-white px-6 py-2 rounded-lg text-sm font-bold shadow-lg shadow-brand-orange/20 hover:bg-orange-600 transition"
                    >
                      Post Memory
                    </button>
                 </div>
              </div>
           </div>
        </div>
      )}

      {/* Picture Format Grid */}
      <div className="grid grid-cols-1 gap-6">
        {memories.length === 0 && !isAdding && (
            <div className="text-gray-500 text-center py-20 flex flex-col items-center">
                <div className="w-20 h-20 bg-gray-800 rounded-full flex items-center justify-center mb-4">
                   <Camera size={32} className="opacity-50" />
                </div>
                <p className="font-medium">No memories yet</p>
                <p className="text-xs mt-2 max-w-[200px]">Start your ride and capture beautiful moments on the road.</p>
            </div>
        )}
        
        {memories.map(mem => (
          <div key={mem.id} className="group relative bg-brand-card rounded-2xl overflow-hidden shadow-xl border border-gray-800 break-inside-avoid">
            {mem.imageUrl ? (
                <div className="relative aspect-[4/3] w-full overflow-hidden">
                    <img 
                      src={mem.imageUrl} 
                      alt="Memory" 
                      className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" 
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent opacity-90"></div>
                    
                    {/* Content Overlay */}
                    <div className="absolute bottom-0 left-0 right-0 p-4">
                       <div className="flex justify-between items-end">
                          <div>
                             <p className="text-white font-bold text-lg drop-shadow-md leading-tight mb-1">{mem.note}</p>
                             <div className="flex items-center text-gray-300 text-xs">
                                <MapPin size={10} className="mr-1" />
                                <span>{mem.latitude.toFixed(3)}, {mem.longitude.toFixed(3)}</span>
                             </div>
                          </div>
                          <div className="bg-black/40 backdrop-blur px-2 py-1 rounded text-[10px] text-gray-300 flex items-center border border-white/10">
                             {new Date(mem.timestamp).toLocaleDateString()}
                          </div>
                       </div>
                    </div>

                    <div className="absolute top-3 right-3 bg-black/40 backdrop-blur p-1.5 rounded-full border border-white/10">
                        {mem.privacy === 'Private' && <Lock size={14} className="text-gray-300" />}
                        {mem.privacy === 'Public' && <Globe size={14} className="text-brand-teal" />}
                        {mem.privacy === 'Friends' && <Users size={14} className="text-blue-400" />}
                    </div>
                </div>
            ) : (
                <div className="p-6">
                    <div className="flex justify-between mb-4">
                        <div className="bg-gray-800 p-2 rounded-full">
                           <MapPin size={20} className="text-brand-orange" />
                        </div>
                        {mem.privacy === 'Private' && <Lock size={16} className="text-gray-500" />}
                    </div>
                    <p className="text-xl font-bold text-white mb-4">"{mem.note}"</p>
                    <div className="text-xs text-gray-500 border-t border-gray-800 pt-3 flex justify-between">
                       <span>{new Date(mem.timestamp).toLocaleDateString()}</span>
                       <span>Lat: {mem.latitude.toFixed(2)}</span>
                    </div>
                </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};