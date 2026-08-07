export interface UserProfile {
  name: string;
  age: number;
  city: string;
  vehicleType: string;
  weight: number;
}

export interface RidePoint {
  latitude: number;
  longitude: number;
  timestamp: number;
  speed: number; // km/h
}

export interface Ride {
  id: string;
  startTime: number;
  endTime: number;
  distanceKm: number;
  durationMinutes: number;
  maxSpeed: number;
  avgSpeed: number;
  overspeedEvents: number;
  points: number;
  safetyScore: number; // 0-100
  path: RidePoint[];
}

export interface Memory {
  id: string;
  note: string;
  latitude: number;
  longitude: number;
  timestamp: number;
  privacy: 'Public' | 'Friends' | 'Private';
  imageUrl?: string;
}

export interface ChatMessage {
  id: string;
  sender: 'user' | 'ai';
  text: string;
  timestamp: number;
}

export interface CoachStats {
  totalKmWeek: number;
  totalRidesWeek: number;
  totalOverspeedsWeek: number;
  totalPointsWeek: number;
  avgSafetyScore: number;
  lastRide?: {
    date: number;
    distanceKm: number;
    durationMinutes: number;
    overspeeds: number;
    avgSpeed: number;
    score: number;
  };
}