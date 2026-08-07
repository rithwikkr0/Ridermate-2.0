import React, { useState, useEffect, useRef } from 'react';
import { Bot, Send, Calendar, Clock, Gauge, AlertTriangle, ChevronDown } from 'lucide-react';
import { getProfile, getWeeklyStats } from '../services/storageService';
import { getCoachSummary, chatWithCoach } from '../services/geminiService';
import { ChatMessage, CoachStats, UserProfile } from '../types';

export const AICoach: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'report' | 'chat'>('report');
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [stats, setStats] = useState<CoachStats | null>(null);
  const [summary, setSummary] = useState<string>("");
  const [loadingSummary, setLoadingSummary] = useState(false);
  
  // Chat State
  const [messages, setMessages] = useState<ChatMessage[]>([
    { id: '1', sender: 'ai', text: 'Hello! I am RiderMate. Ask me anything about safe riding, maintenance, or your recent stats.', timestamp: Date.now() }
  ]);
  const [inputText, setInputText] = useState("");
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const p = getProfile();
    const s = getWeeklyStats();
    setProfile(p);
    setStats(s);
  }, []);

  // Fetch Summary when Stats are ready
  useEffect(() => {
    if (stats && profile && !summary && !loadingSummary) {
      setLoadingSummary(true);
      getCoachSummary(stats, profile).then(text => {
        setSummary(text);
        setLoadingSummary(false);
      });
    }
  }, [stats, profile, summary, loadingSummary]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isTyping, activeTab]);

  const handleSendMessage = async () => {
    if (!inputText.trim() || !profile || !stats) return;

    const userMsg: ChatMessage = {
      id: Date.now().toString(),
      sender: 'user',
      text: inputText,
      timestamp: Date.now()
    };
    
    setMessages(prev => [...prev, userMsg]);
    setInputText("");
    setIsTyping(true);

    const historyText = messages.map(m => `${m.sender === 'user' ? 'Rider' : 'Coach'}: ${m.text}`);
    
    const response = await chatWithCoach(userMsg.text, stats, profile, historyText);

    const aiMsg: ChatMessage = {
      id: (Date.now() + 1).toString(),
      sender: 'ai',
      text: response,
      timestamp: Date.now()
    };

    setMessages(prev => [...prev, aiMsg]);
    setIsTyping(false);
  };

  if (!stats) return <div className="p-8 text-white text-center">Loading Coach...</div>;

  return (
    <div className="flex flex-col h-screen pb-16 bg-gray-950">
      {/* Header */}
      <div className="bg-brand-card p-4 border-b border-gray-800 shadow-lg z-10 flex justify-between items-center">
        <h1 className="text-xl font-bold text-white flex items-center">
          <Bot className="mr-2 text-brand-teal" /> AI Coach
        </h1>
        <div className="flex bg-gray-900 rounded-lg p-1">
            <button 
              onClick={() => setActiveTab('report')}
              className={`px-3 py-1 text-xs font-bold rounded-md transition-colors ${activeTab === 'report' ? 'bg-brand-teal text-black' : 'text-gray-400 hover:text-white'}`}
            >
              Report
            </button>
            <button 
              onClick={() => setActiveTab('chat')}
              className={`px-3 py-1 text-xs font-bold rounded-md transition-colors ${activeTab === 'chat' ? 'bg-brand-teal text-black' : 'text-gray-400 hover:text-white'}`}
            >
              Chat
            </button>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto no-scrollbar bg-gray-950">
        
        {activeTab === 'report' && (
          <div className="p-4 space-y-6">
            {/* Weekly Summary Card */}
            <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-2xl p-6 text-center border border-gray-700 shadow-lg">
              <div className="text-gray-400 text-xs font-bold uppercase tracking-widest mb-2">This Week Summary</div>
              <div className={`text-6xl font-black mb-2 ${stats.avgSafetyScore >= 80 ? 'text-green-500' : stats.avgSafetyScore >= 50 ? 'text-yellow-500' : 'text-red-500'}`}>
                {stats.avgSafetyScore}
              </div>
              <div className="text-sm text-gray-400 font-medium">Safety Score</div>
              
              <div className="grid grid-cols-3 gap-4 mt-6 border-t border-gray-700 pt-4">
                 <div>
                   <div className="text-2xl font-bold text-white">{stats.totalKmWeek.toFixed(0)}</div>
                   <div className="text-[10px] uppercase text-gray-500 font-bold">km</div>
                 </div>
                 <div className="border-l border-gray-700">
                   <div className="text-2xl font-bold text-white">{stats.totalRidesWeek}</div>
                   <div className="text-[10px] uppercase text-gray-500 font-bold">Rides</div>
                 </div>
                 <div className="border-l border-gray-700">
                   <div className="text-2xl font-bold text-brand-orange">{stats.totalPointsWeek}</div>
                   <div className="text-[10px] uppercase text-gray-500 font-bold">Points</div>
                 </div>
              </div>
            </div>

            {/* AI Summary Section */}
            <div className="bg-brand-card rounded-xl p-5 border border-brand-teal/20 relative overflow-hidden">
              <div className="absolute top-0 left-0 w-1 h-full bg-brand-teal"></div>
              <h3 className="text-brand-teal font-bold mb-3 flex items-center">
                 <Bot size={18} className="mr-2" /> AI Summary & Recommendations
              </h3>
              {loadingSummary ? (
                <div className="space-y-3 animate-pulse">
                  <div className="h-2 bg-gray-700 rounded w-full"></div>
                  <div className="h-2 bg-gray-700 rounded w-5/6"></div>
                  <div className="h-2 bg-gray-700 rounded w-4/6"></div>
                </div>
              ) : (
                <div className="text-gray-300 text-sm leading-relaxed whitespace-pre-line">
                  {summary}
                </div>
              )}
            </div>

            {/* Last Ride Snapshot Section */}
            {stats.lastRide ? (
              <div className="bg-brand-card rounded-xl overflow-hidden border border-gray-800">
                <div className="bg-gray-800/50 p-3 border-b border-gray-700 flex justify-between items-center">
                  <span className="text-sm font-bold text-white flex items-center">
                    <Clock size={16} className="mr-2 text-brand-teal" /> Last Ride Snapshot
                  </span>
                  <span className="text-xs text-gray-500">{new Date(stats.lastRide.date).toLocaleDateString()}</span>
                </div>
                <div className="p-4 grid grid-cols-2 gap-y-4 gap-x-2">
                   <div className="flex items-center space-x-3">
                      <div className="bg-gray-800 p-2 rounded text-gray-400"><Gauge size={18} /></div>
                      <div>
                        <div className="text-white font-bold">{Math.round(stats.lastRide.avgSpeed)} km/h</div>
                        <div className="text-xs text-gray-500">Avg Speed</div>
                      </div>
                   </div>
                   <div className="flex items-center space-x-3">
                      <div className="bg-gray-800 p-2 rounded text-gray-400"><AlertTriangle size={18} /></div>
                      <div>
                        <div className={`font-bold ${stats.lastRide.overspeeds > 0 ? 'text-red-400' : 'text-green-400'}`}>
                           {stats.lastRide.overspeeds}
                        </div>
                        <div className="text-xs text-gray-500">Overspeeds</div>
                      </div>
                   </div>
                   <div className="flex items-center space-x-3 col-span-2 bg-gray-900/50 p-2 rounded-lg border border-gray-800/50 mt-2">
                      <div className="flex-1 text-center">
                         <div className="text-xs text-gray-500">Distance</div>
                         <div className="text-white font-mono">{stats.lastRide.distanceKm} km</div>
                      </div>
                      <div className="w-px h-8 bg-gray-700"></div>
                      <div className="flex-1 text-center">
                         <div className="text-xs text-gray-500">Duration</div>
                         <div className="text-white font-mono">{stats.lastRide.durationMinutes} min</div>
                      </div>
                      <div className="w-px h-8 bg-gray-700"></div>
                      <div className="flex-1 text-center">
                         <div className="text-xs text-gray-500">Score</div>
                         <div className={`font-mono font-bold ${stats.lastRide.score > 80 ? 'text-green-500' : 'text-yellow-500'}`}>{stats.lastRide.score}</div>
                      </div>
                   </div>
                </div>
              </div>
            ) : (
                <div className="text-gray-500 text-center text-sm p-4 bg-brand-card rounded-xl border border-gray-800">
                    No rides recorded yet for snapshot.
                </div>
            )}
            
            <button 
                onClick={() => setActiveTab('chat')}
                className="w-full py-4 bg-gray-800 rounded-xl text-gray-300 font-medium flex items-center justify-center space-x-2 border border-gray-700 hover:bg-gray-700 transition"
            >
                <Bot size={20} className="text-brand-teal" />
                <span>Ask Coach Something Else</span>
            </button>
          </div>
        )}

        {activeTab === 'chat' && (
          <div className="p-4 space-y-4 min-h-full">
            {messages.map((msg) => (
              <div key={msg.id} className={`flex ${msg.sender === 'user' ? 'justify-end' : 'justify-start'}`}>
                {msg.sender === 'ai' && (
                  <div className="w-8 h-8 rounded-full bg-brand-teal/20 flex items-center justify-center mr-2 border border-brand-teal/30 shrink-0">
                     <Bot size={16} className="text-brand-teal" />
                  </div>
                )}
                <div className={`max-w-[80%] rounded-2xl p-3 text-sm shadow-sm ${
                  msg.sender === 'user' 
                    ? 'bg-brand-teal text-black rounded-tr-none' 
                    : 'bg-gray-800 text-white rounded-tl-none border border-gray-700'
                }`}>
                  {msg.text}
                </div>
              </div>
            ))}
            {isTyping && (
              <div className="flex justify-start items-center">
                 <div className="w-8 h-8 rounded-full bg-brand-teal/20 flex items-center justify-center mr-2 border border-brand-teal/30 shrink-0">
                     <Bot size={16} className="text-brand-teal" />
                 </div>
                 <div className="bg-gray-800 text-gray-400 rounded-2xl rounded-tl-none p-3 text-xs flex space-x-1 border border-gray-700">
                    <span className="w-1.5 h-1.5 bg-gray-500 rounded-full animate-bounce"></span>
                    <span className="w-1.5 h-1.5 bg-gray-500 rounded-full animate-bounce delay-100"></span>
                    <span className="w-1.5 h-1.5 bg-gray-500 rounded-full animate-bounce delay-200"></span>
                 </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>
        )}
      </div>

      {/* Chat Input - Only visible on Chat tab */}
      {activeTab === 'chat' && (
        <div className="p-3 bg-gray-900 border-t border-gray-800 absolute bottom-16 left-0 right-0 z-20">
          <div className="flex items-center space-x-2 bg-gray-800 rounded-full px-4 py-2 border border-gray-700 shadow-lg">
             <input 
               type="text" 
               className="flex-1 bg-transparent text-white text-sm focus:outline-none placeholder-gray-500"
               placeholder="How to improve my score?"
               value={inputText}
               onChange={(e) => setInputText(e.target.value)}
               onKeyDown={(e) => e.key === 'Enter' && handleSendMessage()}
             />
             <button 
               onClick={handleSendMessage}
               disabled={!inputText.trim()}
               className={`p-2 rounded-full transition-colors ${inputText.trim() ? 'bg-brand-teal text-black hover:bg-teal-400' : 'bg-gray-700 text-gray-500'}`}
             >
               <Send size={18} />
             </button>
          </div>
        </div>
      )}
    </div>
  );
};