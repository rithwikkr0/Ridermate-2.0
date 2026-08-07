
import React from 'react';
import { Shield, Map as MapIcon, History, User, Zap, Camera, Trophy, MessageSquare, Users } from 'lucide-react';

interface LayoutProps {
  children: React.ReactNode;
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const Layout: React.FC<LayoutProps> = ({ children, activeTab, setActiveTab }) => {
  const tabs = [
    { id: 'dashboard', label: 'Ride', icon: Zap },
    { id: 'group', label: 'Squad', icon: Users },
    { id: 'journal', label: 'Journal', icon: Camera },
    { id: 'leaderboard', label: 'Rank', icon: Trophy },
    { id: 'companion', label: 'AI', icon: MessageSquare },
    { id: 'history', label: 'Logs', icon: History },
    { id: 'profile', label: 'Me', icon: User },
  ];

  return (
    <div className="flex flex-col h-screen max-w-md mx-auto bg-neutral-950 text-white relative shadow-2xl overflow-hidden border-x border-neutral-900">
      <header className="px-6 py-4 flex items-center justify-between border-b border-neutral-800 bg-neutral-950/80 backdrop-blur-md z-[2000]">
        <div className="flex items-center gap-2">
          <div className="bg-orange-600 p-1.5 rounded-lg shadow-[0_0_15px_rgba(234,88,12,0.5)]">
            <Shield className="w-4 h-4 text-white" />
          </div>
          <h1 className="text-lg font-black tracking-tighter text-white">RIDERMATE</h1>
        </div>
        <div className="flex items-center gap-1.5 bg-neutral-900/50 px-3 py-1.5 rounded-full border border-neutral-800">
          <div className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" />
          <span className="text-[8px] font-black text-neutral-400 tracking-widest uppercase">System Live</span>
        </div>
      </header>

      <main className="flex-1 overflow-hidden relative bg-neutral-950">
        <div className="h-full overflow-y-auto">
          {children}
        </div>
      </main>

      <nav className="fixed bottom-0 left-0 right-0 max-w-md mx-auto bg-neutral-900/95 backdrop-blur-xl border-t border-neutral-800 pb-safe z-[2000]">
        <div className="flex justify-around items-center h-20 px-1">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex flex-col items-center justify-center gap-1.5 transition-all duration-300 w-full h-full relative ${
                  isActive ? 'text-orange-500' : 'text-neutral-500 hover:text-neutral-300'
                }`}
              >
                {isActive && (
                  <div className="absolute top-0 left-1/2 -translate-x-1/2 w-6 h-1 bg-orange-500 rounded-b-full shadow-[0_0_15px_#ea580c]" />
                )}
                <div className={`p-1.5 rounded-xl transition-all ${isActive ? 'bg-orange-500/10 scale-110' : ''}`}>
                  <Icon className="w-5 h-5" strokeWidth={isActive ? 2.5 : 2} />
                </div>
                <span className="text-[7px] font-black uppercase tracking-tighter">{tab.label}</span>
              </button>
            );
          })}
        </div>
      </nav>
    </div>
  );
};

export default Layout;
