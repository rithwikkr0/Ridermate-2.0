import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Navigation, Mail, Lock, ArrowRight, ShieldCheck, UserPlus } from 'lucide-react';
import { loginUser, registerUser } from '../services/storageService';

export const Login: React.FC = () => {
  const navigate = useNavigate();
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) return;
    
    setError('');
    setIsLoading(true);

    // Simulate network delay for realistic feel
    setTimeout(() => {
      let result;
      if (isSignUp) {
        result = registerUser(email, password);
      } else {
        result = loginUser(email, password);
      }

      if (result.success) {
        navigate('/');
      } else {
        setError(result.message || 'An error occurred');
        setIsLoading(false);
      }
    }, 800);
  };

  const toggleMode = () => {
    setIsSignUp(!isSignUp);
    setError('');
    setPassword('');
  };

  return (
    <div className="min-h-screen bg-gray-950 flex flex-col items-center justify-center p-6 relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none">
        <div className="absolute top-[-10%] left-[-10%] w-64 h-64 bg-brand-orange/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-[-10%] right-[-10%] w-80 h-80 bg-brand-teal/10 rounded-full blur-3xl"></div>
      </div>

      <div className="relative z-10 w-full max-w-sm">
        <div className="flex flex-col items-center mb-10">
          <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-brand-orange to-red-600 flex items-center justify-center shadow-lg shadow-brand-orange/30 mb-4 transform rotate-3">
            <Navigation size={40} className="text-white" />
          </div>
          <h1 className="text-3xl font-black text-white tracking-tight">RIDERMATE</h1>
          <p className="text-gray-400 font-medium">Your AI Safety Companion</p>
        </div>

        <form onSubmit={handleSubmit} className="bg-brand-card border border-gray-800 rounded-2xl p-6 shadow-2xl space-y-4">
          
          <div className="text-center mb-2">
            <h2 className="text-xl font-bold text-white">{isSignUp ? 'Create Account' : 'Welcome Back'}</h2>
          </div>

          {error && (
            <div className="bg-red-500/10 border border-red-500/50 text-red-400 text-xs p-3 rounded-lg text-center font-bold">
              {error}
            </div>
          )}

          <div>
            <label className="text-xs font-bold text-gray-500 uppercase ml-1 mb-1 block">Email Address</label>
            <div className="relative">
              <div className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">
                <Mail size={18} />
              </div>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full bg-gray-900 text-white pl-10 pr-4 py-3 rounded-xl border border-gray-700 focus:border-brand-teal focus:ring-1 focus:ring-brand-teal outline-none transition"
                placeholder="rider@example.com"
              />
            </div>
          </div>

          <div>
            <label className="text-xs font-bold text-gray-500 uppercase ml-1 mb-1 block">Password</label>
            <div className="relative">
              <div className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">
                <Lock size={18} />
              </div>
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full bg-gray-900 text-white pl-10 pr-4 py-3 rounded-xl border border-gray-700 focus:border-brand-teal focus:ring-1 focus:ring-brand-teal outline-none transition"
                placeholder="••••••••"
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className={`w-full font-black py-4 rounded-xl text-lg transition transform active:scale-95 shadow-lg flex items-center justify-center mt-6 ${
              isSignUp 
                ? 'bg-brand-orange text-white hover:bg-orange-600 shadow-brand-orange/20' 
                : 'bg-brand-teal text-black hover:bg-teal-400 shadow-brand-teal/20'
            }`}
          >
            {isLoading ? (
              <span className="animate-pulse">Processing...</span>
            ) : (
              <>
                <span>{isSignUp ? 'SIGN UP' : 'LOGIN'}</span>
                {isSignUp ? <UserPlus size={20} className="ml-2" /> : <ArrowRight size={20} className="ml-2" />}
              </>
            )}
          </button>
        </form>

        <div className="mt-6 text-center">
            <p className="text-gray-500 text-sm">
                {isSignUp ? "Already have an account?" : "Don't have an account?"}
                <button 
                    onClick={toggleMode}
                    className="ml-2 font-bold text-brand-teal hover:underline focus:outline-none"
                >
                    {isSignUp ? "Login" : "Sign Up"}
                </button>
            </p>
        </div>

        <div className="mt-8 flex items-center justify-center space-x-2 text-gray-500 text-xs">
           <ShieldCheck size={14} className="text-gray-600" />
           <span>Secure Local Authentication</span>
        </div>
      </div>
    </div>
  );
};