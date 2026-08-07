
import React, { useState } from 'react';
import { Shield, Mail, Lock, User, ArrowRight, Zap, Loader2 } from 'lucide-react';
import { auth, firestore } from '../firebase';
import { signInAnonymously, updateProfile } from 'firebase/auth';
import { doc, setDoc } from 'firebase/firestore';

interface AuthScreenProps {
  onLogin: (user: any) => void;
}

const AuthScreen: React.FC<AuthScreenProps> = ({ onLogin }) => {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      // For production simplicity in this environment, we use Anonymous Auth.
      // This ensures Firestore/RTDB rules that require 'request.auth != null' work.
      const userCredential = await signInAnonymously(auth);
      const user = userCredential.user;
      
      const displayName = name || 'Rider ' + user.uid.slice(0, 4);
      
      // Initialize User Document in Firestore
      const userDoc = {
        uid: user.uid,
        name: displayName,
        email: email || `${user.uid}@ridermate.io`,
        points: 450,
        level: 12,
        friends: [],
        privacyMode: 'public'
      };

      await setDoc(doc(firestore, "users", user.uid), userDoc, { merge: true });

      onLogin(userDoc);
    } catch (error) {
      console.error("Auth Error:", error);
      alert("Authentication failed. Please check your internet or Firebase config.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col h-screen bg-neutral-950 p-8 items-center justify-center text-center">
      <div className="mb-12">
        <div className="bg-orange-600 p-4 rounded-3xl inline-block shadow-[0_0_40px_rgba(234,88,12,0.4)] mb-6 animate-pulse">
          <Shield className="w-12 h-12 text-white" />
        </div>
        <h1 className="text-4xl font-black tracking-tighter mb-2">RIDERMATE</h1>
        <p className="text-neutral-500 text-sm font-medium uppercase tracking-widest">AI Riding Companion</p>
      </div>

      <form onSubmit={handleSubmit} className="w-full space-y-4 max-w-xs">
        {!isLogin && (
          <div className="relative">
            <User className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-neutral-500" />
            <input 
              placeholder="Display Name" 
              className="w-full bg-neutral-900 border border-neutral-800 rounded-2xl py-4 pl-12 pr-4 text-sm focus:outline-none focus:border-orange-500 transition-all text-white"
              value={name}
              onChange={e => setName(e.target.value)}
              required
            />
          </div>
        )}
        <div className="relative">
          <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-neutral-500" />
          <input 
            type="email" 
            placeholder="Email Address" 
            className="w-full bg-neutral-900 border border-neutral-800 rounded-2xl py-4 pl-12 pr-4 text-sm focus:outline-none focus:border-orange-500 transition-all text-white"
            value={email}
            onChange={e => setEmail(e.target.value)}
          />
        </div>
        <div className="relative">
          <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-neutral-500" />
          <input 
            type="password" 
            placeholder="Password" 
            className="w-full bg-neutral-900 border border-neutral-800 rounded-2xl py-4 pl-12 pr-4 text-sm focus:outline-none focus:border-orange-500 transition-all text-white"
            value={password}
            onChange={e => setPassword(e.target.value)}
          />
        </div>

        <button 
          disabled={loading}
          className="w-full bg-orange-600 text-white font-black py-4 rounded-2xl shadow-xl flex items-center justify-center gap-2 hover:bg-orange-700 transition-all group disabled:opacity-50"
        >
          {loading ? (
            <Loader2 className="w-5 h-5 animate-spin" />
          ) : (
            <>
              {isLogin ? 'ENTER RIDERMATE' : 'CREATE ACCOUNT'}
              <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </>
          )}
        </button>
      </form>

      <div className="mt-8 flex flex-col gap-4">
        <button 
          onClick={() => setIsLogin(!isLogin)}
          className="text-neutral-400 text-xs font-bold uppercase tracking-widest hover:text-white"
        >
          {isLogin ? "Need an account? Sign Up" : "Already have an account? Login"}
        </button>
        
        <div className="flex items-center gap-4 text-neutral-800">
           <div className="flex-1 h-px bg-current" />
           <span className="text-[10px] font-black uppercase">Secure Protocol</span>
           <div className="flex-1 h-px bg-current" />
        </div>
      </div>

      <div className="mt-auto text-[10px] text-neutral-600 font-bold uppercase tracking-widest flex items-center gap-2">
        <Zap className="w-3 h-3 text-orange-600 fill-orange-600" />
        Encrypted Session Active
      </div>
    </div>
  );
};

export default AuthScreen;
