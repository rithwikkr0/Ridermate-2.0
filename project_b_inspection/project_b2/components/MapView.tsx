
import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Polyline, Marker, useMap, Circle, Popup } from 'react-leaflet';
import L from 'leaflet';
import { LocationPoint, Participant, Memory } from '../types';
import { Camera } from 'lucide-react';

// Custom Marker for User
const createRiderIcon = (color: string) => L.divIcon({
  className: 'custom-div-icon',
  html: `<div style="background-color: ${color}; width: 16px; height: 16px; border: 3px solid white; border-radius: 50%; box-shadow: 0 0 10px rgba(0,0,0,0.5);"></div>`,
  iconSize: [16, 16],
  iconAnchor: [8, 8]
});

const createMemoryIcon = () => L.divIcon({
  className: 'custom-div-icon',
  html: `<div style="background-color: #f97316; width: 24px; height: 24px; border: 2px solid white; border-radius: 8px; display: flex; align-items: center; justify-content: center; box-shadow: 0 0 10px rgba(0,0,0,0.5); transform: rotate(45deg);"><div style="transform: rotate(-45deg);"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"/><circle cx="12" cy="13" r="3"/></svg></div></div>`,
  iconSize: [24, 24],
  iconAnchor: [12, 12]
});

const RecenterMap = ({ center }: { center: [number, number] }) => {
  const map = useMap();
  useEffect(() => {
    map.setView(center, map.getZoom());
  }, [center, map]);
  return null;
};

interface MapViewProps {
  currentLocation: LocationPoint | null;
  path: LocationPoint[];
  participants?: Participant[];
  memories?: Memory[];
  isTracking: boolean;
}

const MapView: React.FC<MapViewProps> = ({ currentLocation, path, participants = [], memories = [], isTracking }) => {
  const [mapCenter, setMapCenter] = useState<[number, number]>([12.9716, 77.5946]); // Bangalore default

  useEffect(() => {
    if (currentLocation) {
      setMapCenter([currentLocation.lat, currentLocation.lng]);
    }
  }, [currentLocation]);

  const pathCoordinates = path.map(p => [p.lat, p.lng] as [number, number]);

  return (
    <div className="h-full w-full relative">
      <MapContainer 
        center={mapCenter} 
        zoom={16} 
        zoomControl={false}
        className="h-full w-full"
      >
        <TileLayer
          url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        />
        
        {pathCoordinates.length > 1 && (
          <Polyline 
            positions={pathCoordinates} 
            pathOptions={{ color: '#ea580c', weight: 4, opacity: 0.8, lineJoin: 'round' }} 
          />
        )}

        {currentLocation && (
          <>
            <Marker position={[currentLocation.lat, currentLocation.lng]} icon={createRiderIcon('#ea580c')} />
            <Circle 
              center={[currentLocation.lat, currentLocation.lng]} 
              radius={20} 
              pathOptions={{ fillColor: '#ea580c', fillOpacity: 0.2, color: 'transparent' }} 
            />
            <RecenterMap center={[currentLocation.lat, currentLocation.lng]} />
          </>
        )}

        {participants.map(p => (
          <Marker 
            key={p.uid} 
            position={[p.lat, p.lng]} 
            icon={createRiderIcon('#3b82f6')} 
          >
            <Popup className="custom-popup">
              <div className="bg-neutral-900 text-white p-2 rounded-lg text-xs font-bold">
                {p.name} • {Math.round(p.speed)} km/h
              </div>
            </Popup>
          </Marker>
        ))}

        {memories.map(m => (
          <Marker 
            key={m.id} 
            position={[m.lat, m.lng]} 
            icon={createMemoryIcon()} 
          >
            <Popup className="memory-popup">
              <div className="w-48 overflow-hidden rounded-xl bg-neutral-900 border border-neutral-800">
                <img src={m.imageUrl} className="w-full h-32 object-cover" />
                <div className="p-3">
                  <p className="text-[10px] font-black uppercase text-orange-500 mb-1">{m.locationName}</p>
                  <p className="text-xs text-neutral-200 font-medium italic">"{m.caption}"</p>
                </div>
              </div>
            </Popup>
          </Marker>
        ))}
      </MapContainer>

      {/* Floating Speedo */}
      {isTracking && currentLocation && (
        <div className="absolute top-4 right-4 bg-neutral-900/90 backdrop-blur-md border border-neutral-800 p-3 rounded-2xl flex flex-col items-center min-w-[80px] z-[1000] shadow-xl">
          <span className="text-3xl font-black text-orange-500 leading-none">
            {Math.round(currentLocation.speed)}
          </span>
          <span className="text-[10px] font-bold text-neutral-400 uppercase tracking-tighter">KM/H</span>
        </div>
      )}
    </div>
  );
};

export default MapView;
