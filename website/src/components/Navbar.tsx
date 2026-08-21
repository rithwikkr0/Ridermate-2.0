import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Menu, X, Download, ShieldCheck, Zap, Sparkles } from 'lucide-react';
import { getActiveDownloadUrl, getDownloadButtonLabel } from '../config/downloadConfig';

export const Navbar: React.FC = () => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const location = useLocation();

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const isActive = (path: string) => location.pathname === path;

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        isScrolled
          ? 'bg-background/80 backdrop-blur-xl border-b border-white/10 shadow-2xl py-3'
          : 'bg-transparent py-5'
      }`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between">
          {/* Brand Logo */}
          <Link
            to="/"
            className="flex items-center gap-3 group focus:outline-none focus-visible:ring-2 focus-visible:ring-circuitOrange rounded-lg p-1"
            aria-label="RiderMate 2.0 Home"
          >
            <div className="w-10 h-10 rounded-xl overflow-hidden bg-surface p-0.5 border border-circuitOrange/40 shadow-lg shadow-circuitOrange/25 group-hover:scale-105 transition-transform duration-300">
              <img
                src="/app_icon.png"
                alt="RiderMate 2.0 App Icon"
                className="w-full h-full object-cover rounded-[8px]"
              />
            </div>
            <div className="flex flex-col">
              <span className="font-extrabold text-lg tracking-tight text-white flex items-center gap-1.5">
                RiderMate <span className="text-xs px-1.5 py-0.5 rounded bg-circuitOrange/20 text-circuitOrange border border-circuitOrange/30 font-mono">2.0</span>
              </span>
              <span className="text-[10px] tracking-widest text-onSurfaceVariant uppercase font-mono">High-Performance Cockpit</span>
            </div>
          </Link>

          {/* Desktop Navigation Links */}
          <nav className="hidden md:flex items-center gap-1 glass-panel px-4 py-1.5 rounded-full" aria-label="Main Navigation">
            <Link
              to="/"
              className={`px-4 py-1.5 rounded-full text-sm font-medium transition-colors ${
                isActive('/') ? 'text-white bg-white/10' : 'text-onSurfaceVariant hover:text-white'
              }`}
            >
              Features
            </Link>
            <Link
              to="/download"
              className={`px-4 py-1.5 rounded-full text-sm font-medium transition-colors ${
                isActive('/download') ? 'text-white bg-white/10' : 'text-onSurfaceVariant hover:text-white'
              }`}
            >
              Download
            </Link>
            <Link
              to="/privacy"
              className={`px-4 py-1.5 rounded-full text-sm font-medium transition-colors ${
                isActive('/privacy') ? 'text-white bg-white/10' : 'text-onSurfaceVariant hover:text-white'
              }`}
            >
              Privacy
            </Link>
            <Link
              to="/data-safety"
              className={`px-4 py-1.5 rounded-full text-sm font-medium transition-colors ${
                isActive('/data-safety') ? 'text-white bg-white/10' : 'text-onSurfaceVariant hover:text-white'
              }`}
            >
              Data Safety
            </Link>
          </nav>

          {/* Download CTA Button */}
          <div className="hidden md:flex items-center gap-3">
            <a
              href={getActiveDownloadUrl()}
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl font-semibold text-sm text-white bg-gradient-to-r from-circuitOrange to-circuitOrangeGlow hover:from-circuitOrangeGlow hover:to-circuitOrange shadow-lg shadow-circuitOrange/30 hover:shadow-circuitOrange/50 hover:scale-[1.02] active:scale-[0.98] transition-all duration-200"
            >
              <Download className="w-4 h-4" />
              <span>{getDownloadButtonLabel()}</span>
            </a>
          </div>

          {/* Mobile Hamburger Toggle */}
          <button
            type="button"
            className="md:hidden p-2 rounded-lg text-onSurfaceVariant hover:text-white hover:bg-white/5 focus:outline-none focus-visible:ring-2 focus-visible:ring-circuitOrange"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            aria-expanded={mobileMenuOpen}
            aria-label="Toggle mobile menu"
          >
            {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>

        {/* Mobile Dropdown Menu */}
        {mobileMenuOpen && (
          <div className="md:hidden mt-3 p-4 glass-panel rounded-2xl border border-white/10 space-y-2 animate-fadeIn">
            <Link
              to="/"
              onClick={() => setMobileMenuOpen(false)}
              className={`block px-4 py-2.5 rounded-xl text-sm font-medium ${
                isActive('/') ? 'bg-circuitOrange/20 text-circuitOrange font-semibold' : 'text-onSurface hover:bg-white/5'
              }`}
            >
              Features
            </Link>
            <Link
              to="/download"
              onClick={() => setMobileMenuOpen(false)}
              className={`block px-4 py-2.5 rounded-xl text-sm font-medium ${
                isActive('/download') ? 'bg-circuitOrange/20 text-circuitOrange font-semibold' : 'text-onSurface hover:bg-white/5'
              }`}
            >
              Download APK
            </Link>
            <Link
              to="/privacy"
              onClick={() => setMobileMenuOpen(false)}
              className={`block px-4 py-2.5 rounded-xl text-sm font-medium ${
                isActive('/privacy') ? 'bg-circuitOrange/20 text-circuitOrange font-semibold' : 'text-onSurface hover:bg-white/5'
              }`}
            >
              Privacy Policy
            </Link>
            <Link
              to="/data-safety"
              onClick={() => setMobileMenuOpen(false)}
              className={`block px-4 py-2.5 rounded-xl text-sm font-medium ${
                isActive('/data-safety') ? 'bg-circuitOrange/20 text-circuitOrange font-semibold' : 'text-onSurface hover:bg-white/5'
              }`}
            >
              Data Safety Declaration
            </Link>
            <div className="pt-2 border-t border-white/10">
              <a
                href={getActiveDownloadUrl()}
                className="w-full flex items-center justify-center gap-2 px-4 py-3 rounded-xl font-bold text-sm text-white bg-circuitOrange shadow-lg shadow-circuitOrange/30"
              >
                <Download className="w-4 h-4" />
                <span>{getDownloadButtonLabel()}</span>
              </a>
            </div>
          </div>
        )}
      </div>
    </header>
  );
};
