import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Home, PlayCircle, History, Bot, Users } from 'lucide-react';

export const Navigation: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const isActive = (path: string) => location.pathname === path;

  const navItems = [
    { path: '/', icon: Home, label: 'Home' },
    { path: '/ride', icon: PlayCircle, label: 'Ride' },
    { path: '/history', icon: History, label: 'History' },
    { path: '/coach', icon: Bot, label: 'Coach' },
    { path: '/social', icon: Users, label: 'Social' },
  ];

  // Don't show nav on the active ride screen or login screen
  if ((location.pathname === '/ride' && location.state?.active) || location.pathname === '/login') {
    return null; 
  }

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-brand-card border-t border-gray-800 pb-safe z-50">
      <div className="flex justify-around items-center h-16">
        {navItems.map((item) => (
          <button
            key={item.path}
            onClick={() => navigate(item.path)}
            className={`flex flex-col items-center justify-center w-full h-full space-y-1 ${
              isActive(item.path) ? 'text-brand-orange' : 'text-gray-400 hover:text-gray-200'
            }`}
          >
            <item.icon size={24} strokeWidth={isActive(item.path) ? 2.5 : 2} />
            <span className="text-[10px] font-medium">{item.label}</span>
          </button>
        ))}
      </div>
    </div>
  );
};