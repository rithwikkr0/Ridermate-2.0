
import React, { useState, useEffect, useRef } from 'react';
import Layout from './components/Layout';
import MapView from './components/MapView';
import AuthScreen from './components/AuthScreen';
import { LocationPoint, RideSession, Memory, AIChatMessage, User, RideRoom, Participant, FriendRequest } from './types';
import { calculateDistance, formatDistance, formatDuration } from './utils/geoUtils';
import { analyzeRideSafety, getAICompanionResponse, getWeeklyReport } from './services/geminiService';
import { auth, db, firestore, storage } from './firebase';
import { ref, push, set, onValue, update, serverTimestamp, get, child, remove } from 'firebase/database';
import { collection, addDoc, getDocs, query, where, orderBy, limit, doc, updateDoc, deleteDoc, onSnapshot, getDoc } from 'firebase/firestore';
import { ref as storageRef, uploadBytes, getDownloadURL } from 'firebase/storage';
import { Play, Square, Trophy, Navigation, Users, Clock, History as HistoryIcon, ShieldAlert, Sparkles, Send, MapPin, Camera, Star, Award, TrendingUp, UserPlus, Globe, Lock, Share2, LogOut, Loader2, UserCheck, UserX, Search, MessageCircleQuestion, Hash } from 'lucide-react';

const App: React.FC = () => {
  const [currentUser, setCurrentUser] = useState<User | null>(() => {
    const saved = localStorage.getItem('rm_user');
    return saved ? JSON.parse(saved) : null;
  });
  const [activeTab, setActiveTab] = useState('dashboard');
  const [isTracking, setIsTracking] = useState(false);
  const [currentLocation, setCurrentLocation] = useState<LocationPoint | null>(null);
  const [activeSession, setActiveSession] = useState<RideSession | null>(null);
  const [history, setHistory] = useState<RideSession[]>(() => JSON.parse(localStorage.getItem('rm_history') || '[]'));
  const [memories, setMemories] = useState<Memory[]>([]);
  const [chatMessages, setChatMessages] = useState<AIChatMessage[]>([{ role: 'model', text: "Welcome back, Captain! Ready to burn some rubber? 🏍️", timestamp: Date.now() }]);
  const [activeRoom, setActiveRoom] = useState<RideRoom | null>(null);
  const [roomParticipants, setRoomParticipants] = useState<Participant[]>([]);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [userInput, setUserInput] = useState('');
  const [weeklyReport, setWeeklyReport] = useState<any>(null);
  const [searchEmail, setSearchEmail] = useState('');
  const [friendRequests, setFriendRequests] = useState<FriendRequest[]>([]);
  const [joinRoomId, setJoinRoomId] = useState('');

  const watchId = useRef<number | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Persistence & Listeners
  useEffect(() => {
    if (currentUser) {
      localStorage.setItem('rm_user', JSON.stringify(currentUser));
      fetchMemories();
      
      // Friend Requests Listener
      const q = query(collection(firestore, "friendRequests"), where("toUid", "==", currentUser.uid), where("status", "==", "pending"));
      const unsubscribeReqs = onSnapshot(q, (snapshot) => {
        const requests = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as FriendRequest));
        setFriendRequests(requests);
      }, (err) => console.error("Firestore Error:", err));

      return () => unsubscribeReqs();
    }
  }, [currentUser]);

  useEffect(() => {
    localStorage.setItem('rm_history', JSON.stringify(history));
  }, [history]);

  // Realtime Room Data Listener
  useEffect(() => {
    if (activeRoom) {
      const roomRef = ref(db, `rideRooms/${activeRoom.id}/participants`);
      const unsubscribeRoom = onValue(roomRef, (snapshot) => {
        const data = snapshot.val();
        if (data) {
          const participantsList = Object.entries(data).map(([uid, val]: [string, any]) => ({
            uid,
            ...val
          }));
          setRoomParticipants(participantsList);
        }
      });
      return () => unsubscribeRoom();
    }
  }, [activeRoom]);

  const fetchMemories = async () => {
    if (!currentUser) return;
    try {
      const q = query(collection(firestore, "memories"), where("visibility", "==", "public"), limit(20));
      const querySnapshot = await getDocs(q);
      const fetched: Memory[] = [];
      querySnapshot.forEach((doc) => fetched.push({ id: doc.id, ...doc.data() } as Memory));
      
      const qPersonal = query(collection(firestore, "memories"), where("ownerId", "==", currentUser.uid));
      const personalSnap = await getDocs(qPersonal);
      personalSnap.forEach((doc) => {
        if (!fetched.some(f => f.id === doc.id)) fetched.push({ id: doc.id, ...doc.data() } as Memory);
      });
      
      setMemories(fetched.sort((a,b) => b.date - a.date));
    } catch (err) { console.error("Fetch Memories Error:", err); }
  };

  const startTracking = (mode: 'public' | 'friends' | 'private' = 'public') => {
    if (!navigator.geolocation) return;
    setIsTracking(true);
    const initialSession: RideSession = {
      id: Date.now().toString(),
      userId: currentUser!.uid,
      startTime: Date.now(),
      path: [],
      distance: 0,
      avgSpeed: 0,
      maxSpeed: 0,
      status: 'active',
      visibility: mode
    };
    setActiveSession(initialSession);

    watchId.current = navigator.geolocation.watchPosition(
      (pos) => {
        const newPoint = { lat: pos.coords.latitude, lng: pos.coords.longitude, timestamp: pos.timestamp, speed: pos.coords.speed ? pos.coords.speed * 3.6 : 0 };
        setCurrentLocation(newPoint);
        
        if (activeRoom) {
          const pRef = ref(db, `rideRooms/${activeRoom.id}/participants/${currentUser!.uid}`);
          update(pRef, { lat: newPoint.lat, lng: newPoint.lng, speed: newPoint.speed, updatedAt: serverTimestamp(), name: currentUser!.name });
        }

        setActiveSession(prev => {
          if (!prev) return null;
          const newPath = [...prev.path, newPoint];
          let dist = prev.distance;
          if (prev.path.length > 0) {
            const last = prev.path[prev.path.length - 1];
            dist += calculateDistance(last.lat, last.lng, newPoint.lat, newPoint.lng);
          }
          return { ...prev, path: newPath, distance: dist, avgSpeed: newPath.reduce((acc, p) => acc + p.speed, 0) / newPath.length, maxSpeed: Math.max(prev.maxSpeed, newPoint.speed) };
        });
      },
      (err) => console.error("Geolocation Error:", err),
      { enableHighAccuracy: true }
    );
  };

  const stopTracking = async () => {
    if (watchId.current !== null) navigator.geolocation.clearWatch(watchId.current);
    setIsTracking(false);
    if (!activeSession) return;
    setIsAnalyzing(true);
    
    try {
      const analysis = await analyzeRideSafety({ distance: activeSession.distance, avgSpeed: activeSession.avgSpeed, maxSpeed: activeSession.maxSpeed, duration: Date.now() - activeSession.startTime });
      const completed: RideSession = { ...activeSession, endTime: Date.now(), status: 'completed', aiFeedback: analysis.feedback, safetyScore: analysis.safetyScore, pointsEarned: analysis.points };
      
      setHistory(prev => [completed, ...prev]);
      const newPoints = currentUser!.points + analysis.points;
      setCurrentUser(prev => prev ? { ...prev, points: newPoints } : null);
      
      // Persist to Firestore
      await updateDoc(doc(firestore, "users", currentUser!.uid), { points: newPoints });

      // Leave squad room if active
      if (activeRoom) {
        const pRef = ref(db, `rideRooms/${activeRoom.id}/participants/${currentUser!.uid}`);
        remove(pRef);
      }
    } catch (err) { console.error("Session Completion Error:", err); }

    setActiveSession(null);
    setCurrentLocation(null);
    setIsAnalyzing(false);
    setActiveTab('history');
  };

  const handleCreateRoom = async () => {
    try {
      const roomRef = push(ref(db, 'rideRooms'));
      const roomId = roomRef.key;
      const roomData = { 
        id: roomId, 
        hostId: currentUser!.uid, 
        name: `${currentUser!.name}'s Squad`, 
        participants: { 
          [currentUser!.uid]: { lat: currentLocation?.lat || 0, lng: currentLocation?.lng || 0, speed: 0, updatedAt: serverTimestamp(), name: currentUser!.name } 
        } 
      };
      await set(roomRef, roomData);
      setActiveRoom({ id: roomId!, hostId: currentUser!.uid, name: roomData.name, participants: roomData.participants });
      startTracking('friends');
    } catch (err) { alert("Squad creation failed. Check RTDB rules."); }
  };

  const handleJoinRoom = async () => {
    const rId = joinRoomId.trim();
    if (!rId) return;
    try {
      const roomSnap = await get(child(ref(db), `rideRooms/${rId}`));
      if (roomSnap.exists()) {
        const roomData = roomSnap.val();
        setActiveRoom({ id: rId, hostId: roomData.hostId, name: roomData.name, participants: roomData.participants });
        const pRef = ref(db, `rideRooms/${rId}/participants/${currentUser!.uid}`);
        await update(pRef, { lat: currentLocation?.lat || 0, lng: currentLocation?.lng || 0, speed: 0, updatedAt: serverTimestamp(), name: currentUser!.name });
        startTracking('friends');
      } else { alert("Squad Room not found. Double check the ID."); }
    } catch (err) { alert("Could not join squad."); }
  };

  const sendFriendRequest = async () => {
    const email = searchEmail.trim();
    if (!email) return;
    try {
      const q = query(collection(firestore, "users"), where("email", "==", email));
      const snap = await getDocs(q);
      if (snap.empty) { alert("No rider found with that email."); return; }
      const targetUid = snap.docs[0].id;
      if (targetUid === currentUser!.uid) { alert("You can't friend yourself, Captain!"); return; }
      
      await addDoc(collection(firestore, "friendRequests"), {
        fromUid: currentUser!.uid, fromName: currentUser!.name, fromEmail: currentUser!.email, toUid: targetUid, status: 'pending', timestamp: Date.now()
      });
      alert("Request sent successfully!");
      setSearchEmail('');
    } catch (err) { alert("Error sending request. Check Firestore rules."); }
  };

  const handleFriendRequest = async (req: FriendRequest, action: 'accept' | 'reject') => {
    try {
      if (action === 'accept') {
        await updateDoc(doc(firestore, "friendRequests", req.id), { status: 'accepted' });
        // Update both users friends list
        await updateDoc(doc(firestore, "users", currentUser!.uid), { friends: [...currentUser!.friends, req.fromUid] });
        await updateDoc(doc(firestore, "users", req.fromUid), { friends: [...(await getDoc(doc(firestore, "users", req.fromUid))).data()?.friends || [], currentUser!.uid] });
        setCurrentUser(prev => prev ? { ...prev, friends: [...prev.friends, req.fromUid] } : null);
      } else {
        await deleteDoc(doc(firestore, "friendRequests", req.id));
      }
    } catch (err) { alert("Update failed."); }
  };

  const handleAIQuery = async (queryText?: string) => {
    const text = queryText || userInput;
    if (!text.trim()) return;
    setUserInput('');
    setChatMessages(prev => [...prev, { role: 'user', text, timestamp: Date.now() }]);
    const resp = await getAICompanionResponse(history, chatMessages, text);
    setChatMessages(prev => [...prev, { role: 'model', text: resp, timestamp: Date.now() }]);
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !currentUser) return;
    setIsUploading(true);
    try {
      const storageRefPath = storageRef(storage, `memories/${currentUser.uid}/${Date.now()}_${file.name}`);
      const snap = await uploadBytes(storageRefPath, file);
      const url = await getDownloadURL(snap.ref);
      await addDoc(collection(firestore, "memories"), { 
        ownerId: currentUser.uid, 
        userId: currentUser.uid, 
        lat: currentLocation?.lat || 12.9716, 
        lng: currentLocation?.lng || 77.5946, 
        caption: "On the move!", 
        imageUrl: url, 
        locationName: "Route Point", 
        visibility: 'public', 
        date: Date.now() 
      });
      fetchMemories();
      setActiveTab('journal');
    } catch (err) { alert("Storage error. Check your Bucket rules."); } finally { setIsUploading(false); }
  };

  const generateReport = async () => {
    setIsAnalyzing(true);
    const report = await getWeeklyReport(history);
    setWeeklyReport(report);
    setIsAnalyzing(false);
  };

  if (!currentUser) return <AuthScreen onLogin={setCurrentUser} />;

  const renderDashboard = () => (
    <div className="flex flex-col h-full bg-neutral-950">
      <div className="relative h-[45vh] w-full border-b border-neutral-900">
        <MapView currentLocation={currentLocation} path={activeSession?.path || []} participants={roomParticipants} memories={memories} isTracking={isTracking} />
        {!isTracking && !isAnalyzing && (
          <div className="absolute inset-0 bg-neutral-950/40 backdrop-blur-[2px] z-[1001] flex flex-col items-center justify-center p-8 text-center">
            <div className="bg-orange-600 p-6 rounded-full shadow-2xl mb-8 animate-pulse"><Navigation className="w-10 h-10 text-white fill-white" /></div>
            <h2 className="text-3xl font-black mb-6 tracking-tighter uppercase italic">Ready to Ride?</h2>
            <div className="flex gap-4">
              <button onClick={() => startTracking('private')} className="bg-neutral-900 border border-neutral-800 text-white font-black py-4 px-6 rounded-2xl flex items-center gap-2 shadow-xl hover:bg-neutral-800 transition-all"><Lock className="w-4 h-4" /> SOLO</button>
              <button onClick={() => handleCreateRoom()} className="bg-white text-black font-black py-4 px-8 rounded-2xl flex items-center gap-3 shadow-2xl hover:bg-orange-600 hover:text-white transition-all"><Users className="w-5 h-5" /> SQUAD</button>
            </div>
          </div>
        )}
      </div>
      <div className="p-6 space-y-4">
        {isTracking && activeSession && (
          <div className="bg-neutral-900/50 p-6 rounded-[2.5rem] border border-neutral-800 space-y-4 animate-in slide-in-from-bottom-4 duration-300">
             <div className="flex justify-between items-center px-2">
               <span className="text-[10px] font-black text-orange-500 uppercase tracking-widest">{activeSession.visibility} SESSION {activeRoom ? `• ${activeRoom.id}` : ''}</span>
               <span className="flex items-center gap-1.5 text-[10px] font-black text-green-500 animate-pulse uppercase"><Globe className="w-3 h-3" /> Live Syncing</span>
             </div>
             <div className="grid grid-cols-2 gap-4">
               <div className="bg-black/20 p-4 rounded-3xl border border-white/5"><p className="text-[9px] font-black text-neutral-500 uppercase mb-1">DISTANCE</p><p className="text-2xl font-black">{formatDistance(activeSession.distance)}</p></div>
               <div className="bg-black/20 p-4 rounded-3xl border border-white/5"><p className="text-[9px] font-black text-neutral-500 uppercase mb-1">AVG SPEED</p><p className="text-2xl font-black">{Math.round(activeSession.avgSpeed)} <span className="text-xs">km/h</span></p></div>
             </div>
             <div className="flex gap-2">
                <button onClick={() => fileInputRef.current?.click()} disabled={isUploading} className="flex-1 bg-neutral-800 text-white font-black py-4 rounded-2xl flex items-center justify-center gap-2 hover:bg-neutral-700 transition-all border border-neutral-700">{isUploading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Camera className="w-4 h-4" />} SNAP</button>
                <input type="file" ref={fileInputRef} className="hidden" accept="image/*" onChange={handleFileUpload} />
                <button onClick={stopTracking} className="flex-[2] bg-red-600/10 text-red-500 border border-red-500/20 font-black py-4 rounded-2xl flex items-center justify-center gap-2 hover:bg-red-600 hover:text-white transition-all"><Square className="w-4 h-4 fill-current" /> STOP RIDE</button>
             </div>
          </div>
        )}
        {!isTracking && (
          <div className="bg-gradient-to-br from-neutral-900 to-neutral-800 p-6 rounded-[2.5rem] border border-neutral-700 shadow-xl flex items-center justify-between">
            <div><p className="text-xs font-bold text-neutral-400 mb-1">Rider Level</p><h3 className="text-2xl font-black text-white">{currentUser.points} <span className="text-xs text-orange-500">XP</span></h3></div>
            <button onClick={generateReport} className="bg-orange-600 p-3 rounded-2xl shadow-lg hover:rotate-12 transition-transform"><TrendingUp className="w-5 h-5" /></button>
          </div>
        )}
      </div>
    </div>
  );

  const renderSquad = () => (
    <div className="p-6 space-y-6 pb-24 h-full overflow-y-auto">
      <div className="flex items-center justify-between"><h2 className="text-2xl font-black tracking-tight italic uppercase">Squad Hub</h2><Users className="w-6 h-6 text-orange-500" /></div>
      
      {/* Social: Find Friends */}
      <div className="space-y-4">
        <div className="bg-neutral-900 p-6 rounded-[2rem] border border-neutral-800 shadow-xl">
          <h3 className="text-[10px] font-black text-neutral-500 uppercase tracking-widest mb-4">Add Fellow Riders</h3>
          <div className="flex gap-2">
            <div className="relative flex-1">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-600" />
              <input value={searchEmail} onChange={e=>setSearchEmail(e.target.value)} placeholder="Search rider email..." className="w-full bg-neutral-800 border border-neutral-700 rounded-2xl py-3.5 pl-10 pr-4 text-xs text-white focus:border-orange-500 focus:outline-none" />
            </div>
            <button onClick={sendFriendRequest} className="bg-orange-600 p-3.5 rounded-2xl shadow-lg"><UserPlus className="w-5 h-5" /></button>
          </div>
        </div>

        {friendRequests.length > 0 && (
          <div className="bg-orange-600/5 p-5 rounded-[2rem] border border-orange-500/20 space-y-4 animate-in slide-in-from-top-2 duration-300">
             <h3 className="text-[10px] font-black text-orange-500 uppercase tracking-widest">Incoming Requests</h3>
             {friendRequests.map(req => (
               <div key={req.id} className="flex items-center justify-between bg-neutral-900/80 p-4 rounded-2xl border border-neutral-800">
                 <div><p className="text-xs font-black">{req.fromName}</p><p className="text-[10px] text-neutral-500">{req.fromEmail}</p></div>
                 <div className="flex gap-2">
                    <button onClick={()=>handleFriendRequest(req, 'accept')} className="p-3 bg-green-600/10 text-green-500 rounded-xl hover:bg-green-600 hover:text-white transition-all"><UserCheck className="w-4 h-4" /></button>
                    <button onClick={()=>handleFriendRequest(req, 'reject')} className="p-3 bg-red-600/10 text-red-500 rounded-xl hover:bg-red-600 hover:text-white transition-all"><UserX className="w-4 h-4" /></button>
                 </div>
               </div>
             ))}
          </div>
        )}
      </div>

      {/* Squad Rooms */}
      <div className="grid grid-cols-1 gap-4">
        {activeRoom ? (
          <div className="bg-orange-600/10 p-6 rounded-[2.5rem] border border-orange-500/20 shadow-2xl">
            <div className="flex justify-between items-start mb-6">
               <div>
                 <h3 className="text-orange-500 font-black text-xl italic uppercase">In Squad</h3>
                 <p className="text-neutral-500 text-[10px] font-black uppercase tracking-widest mt-1">ID: {activeRoom.id}</p>
               </div>
               <div className="bg-neutral-900 p-2 rounded-xl border border-white/5"><Hash className="w-4 h-4 text-orange-500" /></div>
            </div>
            <div className="space-y-3">
              {roomParticipants.map(p => (
                <div key={p.uid} className="flex justify-between items-center bg-neutral-950 p-4 rounded-2xl border border-neutral-800">
                  <div className="flex items-center gap-3">
                    <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
                    <span className="text-xs font-black text-neutral-200">{p.name} {p.uid === currentUser.uid && "(You)"}</span>
                  </div>
                  <span className="text-xs font-black text-orange-500">{Math.round(p.speed)} km/h</span>
                </div>
              ))}
            </div>
            <p className="text-[9px] text-center text-neutral-500 font-black uppercase tracking-[0.3em] mt-6">GPS SYNC ACTIVE</p>
          </div>
        ) : (
          <div className="space-y-4">
            <div className="bg-neutral-900 p-7 rounded-[2.5rem] border border-neutral-800 relative overflow-hidden group shadow-xl">
              <div className="relative z-10">
                <h3 className="text-white font-black text-2xl italic uppercase mb-1">Launch Squad</h3>
                <p className="text-neutral-500 text-xs font-medium mb-8 leading-relaxed">Start a real-time tour and invite your inner circle to sync paths.</p>
                <button onClick={handleCreateRoom} className="bg-white text-black font-black py-4 px-10 rounded-2xl shadow-xl hover:bg-orange-600 hover:text-white transition-all uppercase text-xs tracking-widest">Create Room</button>
              </div>
              <Users className="absolute -bottom-10 -right-10 w-48 h-48 text-white/5 rotate-12 group-hover:rotate-0 transition-transform duration-700" />
            </div>
            <div className="bg-neutral-900 p-7 rounded-[2.5rem] border border-neutral-800 shadow-xl">
              <h3 className="text-white font-black text-xl italic uppercase mb-2">Join Squad</h3>
              <p className="text-neutral-500 text-xs font-medium mb-6">Paste the Squad ID shared by your tour host.</p>
              <div className="flex gap-2">
                <input value={joinRoomId} onChange={e=>setJoinRoomId(e.target.value)} placeholder="e.g. -NH_..." className="flex-1 bg-neutral-800 border border-neutral-700 rounded-2xl px-5 py-4 text-sm text-white focus:border-orange-500 focus:outline-none font-bold" />
                <button onClick={handleJoinRoom} className="bg-orange-600 px-8 py-4 rounded-2xl font-black text-xs shadow-lg hover:bg-orange-700 transition-all uppercase">Join</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );

  const renderLeaderboard = () => (
    <div className="p-6 space-y-6 pb-24 h-full overflow-y-auto">
      <div className="flex items-center justify-between"><h2 className="text-2xl font-black tracking-tight italic uppercase">Top Riders</h2><Trophy className="w-6 h-6 text-yellow-500" /></div>
      <div className="bg-gradient-to-br from-orange-600 to-red-600 p-8 rounded-[2.5rem] shadow-2xl text-center relative overflow-hidden">
        <div className="relative z-10">
          <p className="text-white/60 text-[10px] font-black uppercase tracking-widest mb-1">Your Global Position</p>
          <h3 className="text-4xl font-black text-white mb-4">#12 <span className="text-lg font-medium opacity-60">/ 1,420</span></h3>
          <div className="bg-white/20 px-4 py-2 rounded-xl inline-block text-[10px] font-black uppercase text-white backdrop-blur-md border border-white/10">Tier: Elite Veteran</div>
        </div>
        <Award className="absolute -bottom-10 -right-10 w-48 h-48 text-white/10 rotate-12" />
      </div>
      <div className="space-y-3">
        {[
          { name: "Apex Hunter", level: 24, points: 14850, rank: 1 },
          { name: "Moto Zen", level: 21, points: 12400, rank: 2 },
          { name: "Asphalt King", level: 19, points: 9900, rank: 3 },
          { name: currentUser!.name, level: currentUser!.level, points: currentUser!.points, rank: 12 }
        ].map((u, i) => (
          <div key={i} className={`flex items-center justify-between p-5 rounded-[2rem] border transition-all ${u.name === currentUser!.name ? 'border-orange-500 bg-orange-500/5 shadow-[0_0_20px_rgba(234,88,12,0.1)]' : 'border-neutral-800 bg-neutral-900/50'}`}>
            <div className="flex items-center gap-5">
              <span className={`text-xl font-black italic ${u.rank === 1 ? 'text-yellow-500' : u.rank === 2 ? 'text-neutral-300' : u.rank === 3 ? 'text-orange-400' : 'text-neutral-500'}`}>#{u.rank}</span>
              <div>
                <p className="text-sm font-black text-white">{u.name}</p>
                <p className="text-[9px] font-bold text-neutral-500 uppercase tracking-tighter">Lvl {u.level} Rider</p>
              </div>
            </div>
            <div className="text-right">
              <p className="text-sm font-black text-white">{u.points.toLocaleString()}</p>
              <p className="text-[9px] font-black text-orange-500 uppercase tracking-widest">XP</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  const renderCompanion = () => (
    <div className="flex flex-col h-full bg-neutral-950 pb-20">
      <div className="p-6 border-b border-neutral-900 bg-neutral-900/50 backdrop-blur-md sticky top-0 z-10 flex justify-between items-center">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 bg-orange-600 rounded-2xl flex items-center justify-center shadow-lg"><img src="https://api.dicebear.com/7.x/bottts/svg?seed=RiderMate" className="w-8 h-8" /></div>
          <div><h2 className="text-lg font-black tracking-tight italic uppercase">AI Coach</h2><span className="text-[10px] font-bold text-green-500 uppercase flex items-center gap-1"><div className="w-1 h-1 rounded-full bg-green-500 animate-pulse" /> Analyzing History</span></div>
        </div>
        <button className="bg-neutral-800 p-2.5 rounded-xl border border-neutral-700 shadow-lg" onClick={generateReport}><TrendingUp className="w-5 h-5 text-orange-500" /></button>
      </div>
      <div className="flex-1 overflow-y-auto p-6 space-y-4">
        {weeklyReport && (
          <div className="bg-orange-600/10 border border-orange-500/20 p-6 rounded-[2.5rem] mb-6 space-y-3 animate-in fade-in slide-in-from-top-4 duration-500">
            <div className="flex items-center gap-2"><Sparkles className="w-4 h-4 text-orange-500" /><h4 className="text-[10px] font-black uppercase text-orange-500 tracking-widest">Mastery Report</h4></div>
            <p className="text-sm font-bold text-white leading-relaxed italic">"{weeklyReport.summary}"</p>
            <div className="p-4 bg-black/40 rounded-2xl border border-white/5 flex gap-4 items-center">
              <div className="bg-orange-600 p-2 rounded-xl"><Trophy className="w-5 h-5 text-white" /></div>
              <div><p className="text-[9px] text-neutral-400 font-black mb-0.5 uppercase tracking-tighter">Legendary Challenge</p><p className="text-xs font-black text-orange-200">{weeklyReport.challenge}</p></div>
            </div>
          </div>
        )}
        
        {chatMessages.length === 1 && (
          <div className="py-12 text-center space-y-6">
             <div className="bg-neutral-900 p-6 rounded-full w-24 h-24 flex items-center justify-center mx-auto border border-white/5 shadow-2xl"><MessageCircleQuestion className="w-10 h-10 text-neutral-700" /></div>
             <div>
               <h3 className="text-sm font-black text-neutral-400 uppercase tracking-widest mb-1">Rider Support Active</h3>
               <p className="text-[11px] text-neutral-600 font-medium">Ask about safety, routes, or habits.</p>
             </div>
             <div className="flex flex-wrap gap-2 justify-center px-4">
                {["Safety assessment?", "Top speed tip?", "How's my distance?", "Analyze habits"].map(q => (
                  <button key={q} onClick={() => handleAIQuery(q)} className="bg-neutral-900 border border-neutral-800 px-5 py-3 rounded-2xl text-[10px] font-black text-neutral-400 hover:text-orange-500 hover:border-orange-500 transition-all uppercase tracking-widest">{q}</button>
                ))}
             </div>
          </div>
        )}

        {chatMessages.map((m, i) => (
          <div key={i} className={`flex ${m.role === 'user' ? 'justify-end' : 'justify-start'} animate-in slide-in-from-bottom-2 duration-300`}>
            <div className={`max-w-[85%] p-5 rounded-[2rem] text-sm font-medium shadow-xl ${m.role === 'user' ? 'bg-orange-600 text-white rounded-tr-none' : 'bg-neutral-900 text-neutral-200 border border-neutral-800 rounded-tl-none'}`}>{m.text}</div>
          </div>
        ))}
      </div>
      <div className="p-4 bg-neutral-900/50 border-t border-neutral-900 flex gap-3 sticky bottom-0 backdrop-blur-xl">
        <input value={userInput} onChange={e=>setUserInput(e.target.value)} onKeyDown={e=>e.key==='Enter' && handleAIQuery()} placeholder="Message Coach..." className="flex-1 bg-neutral-800 border border-neutral-700 rounded-2xl px-6 py-4 text-sm focus:outline-none focus:border-orange-500 text-white font-medium" />
        <button onClick={()=>handleAIQuery()} className="bg-orange-600 p-4 rounded-2xl shadow-xl hover:bg-orange-700 transition-colors flex items-center justify-center"><Send className="w-5 h-5 text-white" /></button>
      </div>
    </div>
  );

  function renderMemories() {
    return (
      <div className="p-6 space-y-6 pb-24 h-full overflow-y-auto">
        <div className="flex items-center justify-between"><h2 className="text-2xl font-black tracking-tight italic uppercase">Ride Journal</h2><Camera className="w-6 h-6 text-neutral-500" /></div>
        <div className="grid grid-cols-1 gap-8">
          {memories.length === 0 && <div className="text-center py-24 opacity-20 italic font-black uppercase tracking-widest text-xs">No memories logged. Hit the camera!</div>}
          {memories.map(m => (
            <div key={m.id} className="bg-neutral-900 rounded-[2.5rem] overflow-hidden border border-neutral-800 shadow-2xl relative animate-in fade-in duration-500">
              <div className="absolute top-5 right-5 bg-black/60 backdrop-blur-xl px-3 py-1.5 rounded-full flex items-center gap-1.5 z-10 border border-white/10"><Lock className="w-3 h-3 text-white" /><span className="text-[9px] font-black uppercase text-white tracking-widest">{m.visibility}</span></div>
              <img src={m.imageUrl} className="w-full h-64 object-cover" loading="lazy" />
              <div className="p-6 bg-gradient-to-t from-black/80 to-transparent">
                <div className="flex justify-between items-center mb-4">
                  <div className="flex items-center gap-2 text-orange-500 bg-orange-500/10 px-3 py-1 rounded-full"><MapPin className="w-3 h-3" /><span className="text-[10px] font-black uppercase tracking-tighter">{m.locationName}</span></div>
                  <Share2 className="w-4 h-4 text-neutral-500 hover:text-white transition-colors" />
                </div>
                <p className="text-sm text-neutral-100 font-bold italic leading-relaxed mb-3">"{m.caption}"</p>
                <div className="flex items-center gap-2 opacity-40"><Clock className="w-3 h-3 text-neutral-400" /><p className="text-[10px] text-neutral-500 font-bold uppercase tracking-widest">{new Date(m.date).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })}</p></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  function renderHistory() {
    return (
      <div className="p-6 space-y-6 pb-24 h-full overflow-y-auto">
        <div className="flex items-center justify-between"><h2 className="text-2xl font-black tracking-tight italic uppercase">Session Logs</h2><HistoryIcon className="w-6 h-6 text-neutral-500" /></div>
        <div className="space-y-4">
          {history.length === 0 && <div className="text-center py-24 opacity-20 italic font-black uppercase tracking-widest text-xs">No rides logged yet. Start ignition!</div>}
          {history.map(session => (
            <div key={session.id} className="bg-neutral-900 rounded-[2.5rem] border border-neutral-800 p-7 space-y-6 shadow-xl animate-in slide-in-from-right-4 duration-300">
              <div className="flex justify-between items-start">
                <div>
                  <div className="flex items-center gap-2 mb-1.5">
                    <Clock className="w-3 h-3 text-neutral-500" />
                    <p className="text-[10px] font-black text-neutral-500 uppercase tracking-widest">{new Date(session.startTime).toLocaleDateString()}</p>
                  </div>
                  <h3 className="text-xl font-black italic uppercase tracking-tight">{formatDistance(session.distance)} Touring</h3>
                </div>
                <div className="bg-green-600/10 text-green-500 px-4 py-2 rounded-2xl text-[10px] font-black border border-green-500/20 shadow-sm shadow-green-500/5">Safety: {session.safetyScore}</div>
              </div>
              <div className="grid grid-cols-3 gap-3">
                <div className="bg-black/30 p-4 rounded-2xl border border-white/5 text-center"><p className="text-[9px] text-neutral-500 font-black uppercase mb-1">AVG</p><p className="text-sm font-black text-white">{Math.round(session.avgSpeed)}</p></div>
                <div className="bg-black/30 p-4 rounded-2xl border border-white/5 text-center"><p className="text-[9px] text-neutral-500 font-black uppercase mb-1">MAX</p><p className="text-sm font-black text-white">{Math.round(session.maxSpeed)}</p></div>
                <div className="bg-black/30 p-4 rounded-2xl border border-white/5 text-center"><p className="text-[9px] text-neutral-500 font-black uppercase mb-1">TIME</p><p className="text-sm font-black text-white">{session.endTime ? formatDuration(session.endTime - session.startTime) : 'Active'}</p></div>
              </div>
              {session.aiFeedback && (
                <div className="bg-orange-600/5 p-4 rounded-[1.5rem] border border-orange-500/10 flex gap-3 items-start">
                  <Sparkles className="w-4 h-4 text-orange-500 shrink-0 mt-0.5" />
                  <p className="text-[11px] text-neutral-300 italic leading-relaxed font-medium">"{session.aiFeedback}"</p>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    );
  }

  function renderProfile() {
    return (
      <div className="p-10 text-center space-y-10 flex flex-col h-full overflow-y-auto">
        <div className="relative inline-block mx-auto">
          <div className="w-36 h-36 rounded-[4rem] bg-orange-600 border-8 border-neutral-900 shadow-2xl flex items-center justify-center text-6xl font-black text-white italic">
            {currentUser!.name[0].toUpperCase()}
          </div>
          <div className="absolute -bottom-2 -right-2 bg-neutral-900 p-4 rounded-2xl border border-neutral-800 shadow-xl">
            <Star className="w-6 h-6 text-yellow-500 fill-yellow-500" />
          </div>
        </div>
        <div>
          <h2 className="text-4xl font-black tracking-tighter italic uppercase">{currentUser!.name}</h2>
          <p className="text-neutral-500 font-black text-xs tracking-[0.3em] uppercase mt-2">Elite Master Rider • Lvl {currentUser!.level}</p>
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div className="bg-neutral-900 p-7 rounded-[2rem] border border-neutral-800 text-left shadow-xl">
             <span className="text-[10px] font-black text-neutral-600 uppercase block mb-2 tracking-widest">Visibility</span>
             <div className="flex items-center gap-2"><Globe className="w-3 h-3 text-orange-500" /><p className="font-black text-white capitalize text-sm">{currentUser!.privacyMode}</p></div>
          </div>
          <div className="bg-neutral-900 p-7 rounded-[2rem] border border-neutral-800 text-left shadow-xl">
             <span className="text-[10px] font-black text-neutral-600 uppercase block mb-2 tracking-widest">Squad Connections</span>
             <div className="flex items-center gap-2"><Users className="w-3 h-3 text-orange-500" /><p className="font-black text-white text-sm">{currentUser!.friends.length} Friends</p></div>
          </div>
        </div>
        <div className="space-y-4 mt-auto">
          <button onClick={() => { localStorage.removeItem('rm_user'); auth.signOut(); setCurrentUser(null); }} className="w-full py-5 bg-red-600/5 text-red-500 font-black rounded-[2rem] flex items-center justify-center gap-3 border border-red-500/10 hover:bg-red-600 hover:text-white transition-all shadow-lg italic uppercase tracking-widest text-xs">
            <LogOut className="w-4 h-4" /> Sign Out Session
          </button>
          <p className="text-[9px] text-neutral-800 font-black uppercase tracking-[0.5em]">RiderMate Production Build 1.0.8</p>
        </div>
      </div>
    );
  }

  return (
    <Layout activeTab={activeTab} setActiveTab={setActiveTab}>
      {(() => {
        switch (activeTab) {
          case 'dashboard': return renderDashboard();
          case 'group': return renderSquad();
          case 'journal': return renderMemories();
          case 'leaderboard': return renderLeaderboard();
          case 'companion': return renderCompanion();
          case 'history': return renderHistory();
          case 'profile': return renderProfile();
          default: return renderDashboard();
        }
      })()}
    </Layout>
  );
};

export default App;
