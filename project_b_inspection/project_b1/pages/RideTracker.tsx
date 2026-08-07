import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { StopCircle, Navigation, AlertTriangle, Zap, Users, MapPin, Crosshair } from 'lucide-react';
import { Ride, RidePoint, Memory } from '../types';
import { saveRide, getMemories } from '../services/storageService';

// Constants
const OVERSPEED_LIMIT = 60; // km/h

export const RideTracker: React.FC = () => {
  const navigate = useNavigate();
  const [isActive, setIsActive] = useState(false);
  const [elapsedTime, setElapsedTime] = useState(0); // seconds
  const [currentSpeed, setCurrentSpeed] = useState(0); // km/h
  const [distance, setDistance] = useState(0); // km
  const [points, setPoints] = useState(0);
  const [overspeedCount, setOverspeedCount] = useState(0);
  const [isOverspeeding, setIsOverspeeding] = useState(false);
  
  // Refs
  const ridePath = useRef<RidePoint[]>([]);
  const startTimeRef = useRef<number>(0);
  const watchIdRef = useRef<number | null>(null);
  const intervalIdRef = useRef<number | null>(null);
  const simulationIdRef = useRef<number | null>(null);
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<any>(null);
  const polylineRef = useRef<any>(null);
  const markerRef = useRef<any>(null);
  const friendMarkersRef = useRef<any[]>([]);

  // Simulated Friends
  const [friends, setFriends] = useState([
    { id: 1, name: "Rahul", lat: 12.973, lng: 77.596 },
    { id: 2, name: "Sneha", lat: 12.970, lng: 77.593 }
  ]);

  useEffect(() => {
    // Initialize Map
    if (!mapRef.current && mapContainerRef.current) {
      const L = (window as any).L;
      if (!L) return;

      const map = L.map(mapContainerRef.current, {
        zoomControl: false,
        attributionControl: false
      }).setView([12.9716, 77.5946], 15); // Default to Bangalore

      // Try to get actual location immediately to center map
      navigator.geolocation.getCurrentPosition(
        (pos) => {
            map.setView([pos.coords.latitude, pos.coords.longitude], 16);
        },
        (err) => console.log("Initial GPS failed", err)
      );

      // Dark theme map tiles
      L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
        maxZoom: 20,
        subdomains: 'abcd'
      }).addTo(map);

      mapRef.current = map;

      // Add Memories Markers
      const memories = getMemories();
      memories.forEach((mem: Memory) => {
        const icon = L.divIcon({
          className: 'bg-transparent',
          html: `<div class="w-8 h-8 bg-brand-orange rounded-full border-2 border-white shadow flex items-center justify-center text-white cursor-pointer hover:scale-110 transition-transform"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg></div>`
        });
        
        const popupContent = `
          <div class="p-0 min-w-[200px]">
            ${mem.imageUrl ? `<div class="w-full h-32 bg-gray-200 rounded-t mb-2 overflow-hidden"><img src="${mem.imageUrl}" class="w-full h-full object-cover" /></div>` : ''}
            <div class="px-2 pb-2">
                <b class="text-gray-900 text-sm block mb-1">${mem.note}</b>
                <span class="text-gray-500 text-xs flex items-center">
                    <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    ${new Date(mem.timestamp).toLocaleDateString()}
                </span>
            </div>
          </div>
        `;

        L.marker([mem.latitude, mem.longitude], { icon })
          .addTo(map)
          .bindPopup(popupContent, {
            closeButton: false,
            className: 'rounded-xl overflow-hidden shadow-xl border-0'
          });
      });
    }

    return () => {
      // Cleanup on unmount
      if (watchIdRef.current !== null) navigator.geolocation.clearWatch(watchIdRef.current);
      if (intervalIdRef.current) clearInterval(intervalIdRef.current);
      if (simulationIdRef.current) clearInterval(simulationIdRef.current);
      if (mapRef.current) {
        mapRef.current.remove();
        mapRef.current = null;
      }
    };
  }, []);

  // Update Friends locations periodically
  useEffect(() => {
    const L = (window as any).L;
    if (!L || !mapRef.current) return;

    // Clear existing friend markers
    friendMarkersRef.current.forEach(m => m.remove());
    friendMarkersRef.current = [];

    friends.forEach(f => {
       const icon = L.divIcon({
          className: 'bg-transparent',
          html: `
            <div class="flex flex-col items-center animate-bounce duration-[2000ms]">
                <div class="w-10 h-10 bg-blue-600 rounded-full border-2 border-white shadow-lg flex items-center justify-center text-white font-bold text-sm">
                    ${f.name[0]}
                </div>
                <div class="bg-white/90 backdrop-blur px-2 py-0.5 rounded-full shadow text-[10px] font-bold text-blue-900 mt-1">
                    ${f.name}
                </div>
            </div>`
       });
       const marker = L.marker([f.lat, f.lng], { icon }).addTo(mapRef.current);
       friendMarkersRef.current.push(marker);
    });

  }, [friends]);

  // Simulate friends moving
  useEffect(() => {
    if (!isActive) return;
    const interval = window.setInterval(() => {
        setFriends(prev => prev.map(f => ({
            ...f,
            lat: f.lat + (Math.random() - 0.5) * 0.0002,
            lng: f.lng + (Math.random() - 0.5) * 0.0002
        })));
    }, 2000);
    return () => clearInterval(interval);
  }, [isActive]);

  const startRide = () => {
    setIsActive(true);
    setElapsedTime(0);
    setDistance(0);
    setCurrentSpeed(0);
    setPoints(0);
    setOverspeedCount(0);
    ridePath.current = [];
    startTimeRef.current = Date.now();

    // Init polyline on map
    const L = (window as any).L;
    if (mapRef.current && L) {
       // Remove old polyline if exists
       if (polylineRef.current) polylineRef.current.remove();
       // Neon Blue Path
       polylineRef.current = L.polyline([], { 
           color: '#06b6d4', // cyan-500
           weight: 6,
           opacity: 0.8,
           lineCap: 'round',
           lineJoin: 'round',
           dashArray: '1, 10', // Dotted effect initially maybe? No, solid is better for path
           dashOffset: '0'
       }).addTo(mapRef.current);
       // Reset style to solid
       polylineRef.current.setStyle({ dashArray: null });
    }

    intervalIdRef.current = window.setInterval(() => {
      setElapsedTime(prev => prev + 1);
    }, 1000);

    if (navigator.geolocation) {
      watchIdRef.current = navigator.geolocation.watchPosition(
        (position) => {
          const { latitude, longitude, speed } = position.coords;
          // Use simulated speed if GPS speed is null (often happens on desktop)
          const gpsSpeed = (speed || 0) * 3.6; 
          const displaySpeed = gpsSpeed > 0 ? gpsSpeed : (isActive && simulationIdRef.current ? currentSpeed : 0);
          
          updateRideData(latitude, longitude, displaySpeed);
        },
        (error) => console.error("GPS Error", error),
        { enableHighAccuracy: true, maximumAge: 0 }
      );
    }
  };

  const updateRideData = (lat: number, lon: number, speedKmh: number) => {
    setCurrentSpeed(speedKmh);
    
    // Overspeed check
    if (speedKmh > OVERSPEED_LIMIT) {
      setIsOverspeeding(true);
      if (!isOverspeeding) {
          setOverspeedCount(prev => prev + 1);
      }
    } else {
      setIsOverspeeding(false);
    }

    // Update Distance
    if (ridePath.current.length > 0) {
      const lastPoint = ridePath.current[ridePath.current.length - 1];
      const dist = calcCrow(lastPoint.latitude, lastPoint.longitude, lat, lon);
      // Filter GPS jitter
      if (dist > 0.002) { 
          setDistance(prev => prev + dist);
          setPoints(prev => Math.floor((distance + dist) * 10) - (overspeedCount * 5));
      }
    }

    ridePath.current.push({
      latitude: lat,
      longitude: lon,
      timestamp: Date.now(),
      speed: speedKmh
    });

    // Update Map
    const L = (window as any).L;
    if (mapRef.current && L) {
       const latLngs = ridePath.current.map(p => [p.latitude, p.longitude]);
       if (polylineRef.current) {
           polylineRef.current.setLatLngs(latLngs);
       }
       
       // Update user marker
       if (!markerRef.current) {
           const userIcon = L.divIcon({
              className: 'bg-transparent',
              html: `<div class="relative">
                        <div class="absolute -top-3 -left-3 w-6 h-6 bg-brand-teal rounded-full border-2 border-white shadow-lg shadow-brand-teal/50 z-10"></div>
                        <div class="absolute -top-6 -left-6 w-12 h-12 bg-brand-teal/30 rounded-full animate-ping"></div>
                     </div>`
           });
           markerRef.current = L.marker([lat, lon], { icon: userIcon, zIndexOffset: 1000 }).addTo(mapRef.current);
       } else {
           markerRef.current.setLatLng([lat, lon]);
       }
       
       // Auto-pan to follow user
       mapRef.current.panTo([lat, lon], { animate: true, duration: 1.0 });
    }
  };

  const handleRecenter = () => {
    if (mapRef.current && markerRef.current) {
        const latLng = markerRef.current.getLatLng();
        mapRef.current.setView(latLng, 17, { animate: true });
    }
  };

  function calcCrow(lat1: number, lon1: number, lat2: number, lon2: number) {
      const R = 6371; // km
      const dLat = toRad(lat2 - lat1);
      const dLon = toRad(lon2 - lon1);
      const lat1Rad = toRad(lat1);
      const lat2Rad = toRad(lat2);
      const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1Rad) * Math.cos(lat2Rad);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      return R * c;
  }
  function toRad(Value: number) {
      return Value * Math.PI / 180;
  }

  const stopRide = () => {
    if (watchIdRef.current !== null) navigator.geolocation.clearWatch(watchIdRef.current);
    if (intervalIdRef.current) clearInterval(intervalIdRef.current);
    if (simulationIdRef.current) clearInterval(simulationIdRef.current);

    const endTime = Date.now();
    const durationMinutes = Math.floor(elapsedTime / 60);
    const score = Math.max(0, 100 - (overspeedCount * 10));

    const newRide: Ride = {
      id: `ride-${Date.now()}`,
      startTime: startTimeRef.current,
      endTime,
      distanceKm: parseFloat(distance.toFixed(2)),
      durationMinutes,
      maxSpeed: Math.max(...ridePath.current.map(p => p.speed), 0),
      avgSpeed: ridePath.current.length ? ridePath.current.reduce((a,b) => a + b.speed, 0) / ridePath.current.length : 0,
      overspeedEvents: overspeedCount,
      points: Math.max(0, points),
      safetyScore: score,
      path: ridePath.current
    };

    saveRide(newRide);
    setIsActive(false);
    navigate('/history');
  };

  const toggleSimulation = () => {
    if (simulationIdRef.current) {
        clearInterval(simulationIdRef.current);
        simulationIdRef.current = null;
    } else {
        let simSpeed = 30;
        let lat = 12.9716;
        let lon = 77.5946;
        
        // Start simulation from Bangalore center if not already somewhere
        if (ridePath.current.length > 0) {
            const last = ridePath.current[ridePath.current.length - 1];
            lat = last.latitude;
            lon = last.longitude;
        } else if (markerRef.current) {
            const { lat: mLat, lng: mLng } = markerRef.current.getLatLng();
            lat = mLat;
            lon = mLng;
        }

        simulationIdRef.current = window.setInterval(() => {
            simSpeed += (Math.random() - 0.4) * 10; 
            if (simSpeed < 0) simSpeed = 0;
            if (simSpeed > 80) simSpeed = 80;
            
            // Move roughly NE
            lat += 0.0001;
            lon += 0.0001;

            updateRideData(lat, lon, simSpeed);
        }, 1000);
    }
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  // Pre-ride screen
  if (!isActive) {
    return (
      <div className="h-screen flex flex-col items-center justify-center p-6 bg-gray-950 relative overflow-hidden">
        {/* Map Background for Pre-ride too */}
        <div ref={mapContainerRef} className="absolute inset-0 opacity-30 grayscale z-0" />
        
        <div className="relative z-10 w-full flex flex-col items-center">
            <div className="w-48 h-48 rounded-full bg-brand-orange/20 flex items-center justify-center animate-pulse mb-8 backdrop-blur-sm">
                <div className="w-36 h-36 rounded-full bg-brand-orange flex items-center justify-center shadow-[0_0_30px_rgba(249,115,22,0.6)]">
                    <Navigation size={64} className="text-white ml-2" />
                </div>
            </div>
            <h2 className="text-3xl font-black text-white mb-2 shadow-black drop-shadow-lg tracking-tight">RIDERMATE</h2>
            <p className="text-gray-300 mb-8 text-center drop-shadow-md font-medium">AI-Powered Safety Companion</p>
            
            <button 
                onClick={startRide}
                className="w-full max-w-xs bg-brand-teal text-black font-black py-4 rounded-2xl text-xl hover:bg-teal-400 transition transform active:scale-95 shadow-lg shadow-brand-teal/20 flex items-center justify-center space-x-2"
            >
                <Zap size={24} fill="currentColor" />
                <span>START RIDE</span>
            </button>
            
            <p className="text-gray-500 text-xs mt-6 text-center max-w-xs">
                Ensure phone is mounted securely. GPS tracking requires clear sky view.
            </p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen flex flex-col bg-gray-950 relative overflow-hidden">
      {/* Map Background */}
      <div ref={mapContainerRef} className="absolute inset-0 z-0" />

      {/* Overspeed Warning */}
      {isOverspeeding && (
        <div className="absolute top-0 left-0 right-0 bg-red-600 z-50 p-4 animate-pulse flex items-center justify-center space-x-3 shadow-xl">
          <AlertTriangle className="text-white fill-current" size={32} />
          <span className="text-white font-black text-xl uppercase tracking-wider">SLOW DOWN!</span>
        </div>
      )}

      {/* Top Stats Overlay */}
      <div className="absolute top-0 left-0 right-0 p-4 z-10">
        <div className="bg-gray-900/90 backdrop-blur-md rounded-2xl p-4 border border-gray-800 shadow-2xl grid grid-cols-3 gap-4">
             <div className="text-center">
                <div className="text-gray-400 text-[10px] uppercase font-bold tracking-wider">Time</div>
                <div className="text-xl font-bold text-white font-mono">{formatTime(elapsedTime)}</div>
             </div>
             <div className="text-center border-l border-gray-700">
                <div className="text-gray-400 text-[10px] uppercase font-bold tracking-wider">Dist (km)</div>
                <div className="text-xl font-bold text-white font-mono">{distance.toFixed(2)}</div>
             </div>
             <div className="text-center border-l border-gray-700">
                <div className="text-gray-400 text-[10px] uppercase font-bold tracking-wider">Points</div>
                <div className="text-xl font-bold text-brand-orange font-mono">{points}</div>
             </div>
        </div>
      </div>

      {/* Recenter Button */}
      <button 
        onClick={handleRecenter}
        className="absolute top-28 right-4 z-20 bg-gray-900/90 p-3 rounded-full text-white shadow-lg border border-gray-700 hover:bg-gray-800 active:scale-95 transition"
        title="Recenter Map"
      >
        <Crosshair size={20} />
      </button>

      {/* Speedometer Overlay (Center-ish) */}
      <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-10 pointer-events-none">
          <div className="w-48 h-48 rounded-full border-4 border-gray-800/50 flex items-center justify-center bg-gray-900/80 backdrop-blur-sm shadow-2xl relative">
             {/* Decorative ring */}
             <div className="absolute inset-0 rounded-full border-2 border-brand-teal/20 border-t-brand-teal transform rotate-45"></div>
             
             <div className="flex flex-col items-center">
               <span className={`text-6xl font-black font-mono ${isOverspeeding ? 'text-red-500' : 'text-white'}`}>
                 {Math.round(currentSpeed)}
               </span>
               <span className="text-gray-400 text-sm font-medium uppercase mt-1">km/h</span>
             </div>
          </div>
      </div>

      {/* Features & Controls Overlay (Bottom) */}
      <div className="absolute bottom-0 left-0 right-0 p-6 z-20 bg-gradient-to-t from-gray-950 via-gray-900/95 to-transparent pt-16">
        <div className="flex justify-between items-center mb-6 px-2">
             <div className="flex space-x-2 pointer-events-auto">
                 {/* Friends Pill */}
                 <div className="bg-blue-600/90 backdrop-blur text-white px-4 py-2 rounded-full text-xs font-bold flex items-center shadow-lg cursor-pointer hover:bg-blue-500 transition ring-1 ring-white/20">
                    <Users size={14} className="mr-2" /> {friends.length} Friends
                 </div>
                 {/* Memory Pill */}
                 <div className="bg-brand-orange/90 backdrop-blur text-white px-4 py-2 rounded-full text-xs font-bold flex items-center shadow-lg cursor-pointer hover:bg-brand-orange transition ring-1 ring-white/20" onClick={() => navigate('/memories')}>
                    <MapPin size={14} className="mr-2" /> Memories
                 </div>
             </div>
        </div>

        <div className="flex space-x-4 pointer-events-auto">
           <button 
             onClick={toggleSimulation}
             className="flex-1 bg-gray-800/90 text-gray-300 py-4 rounded-xl font-bold flex flex-col items-center justify-center space-y-1 hover:bg-gray-700 backdrop-blur transition active:scale-95 border border-gray-700"
           >
             <Zap size={24} className={simulationIdRef.current ? "text-yellow-400 fill-current" : ""} />
             <span className="text-xs">Simulate</span>
           </button>

           <button 
             onClick={stopRide}
             className="flex-[2] bg-red-600 text-white py-4 rounded-xl font-bold text-lg flex items-center justify-center space-x-2 hover:bg-red-700 shadow-lg shadow-red-600/30 transition active:scale-95"
           >
             <StopCircle size={28} fill="currentColor" />
             <span>END RIDE</span>
           </button>
        </div>
      </div>
    </div>
  );
};