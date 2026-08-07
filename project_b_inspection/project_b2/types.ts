
export interface LocationPoint {
  lat: number;
  lng: number;
  timestamp: number;
  speed: number;
}

export interface User {
  uid: string;
  name: string;
  email: string;
  photoURL?: string;
  points: number;
  level: number;
  friends: string[]; // Array of uids
  privacyMode: 'public' | 'friends' | 'private';
}

export interface FriendRequest {
  id: string;
  fromUid: string;
  fromName: string;
  fromEmail: string;
  toUid: string;
  status: 'pending' | 'accepted' | 'rejected';
  timestamp: number;
}

export interface RideSession {
  id: string;
  userId: string;
  startTime: number;
  endTime?: number;
  path: LocationPoint[];
  distance: number;
  avgSpeed: number;
  maxSpeed: number;
  status: 'active' | 'completed';
  aiFeedback?: string;
  safetyScore?: number;
  pointsEarned?: number;
  visibility: 'public' | 'friends' | 'private';
}

export interface Memory {
  id: string;
  userId: string;
  rideId?: string;
  date: number;
  lat: number;
  lng: number;
  imageUrl: string;
  caption: string;
  locationName: string;
  visibility: 'public' | 'friends' | 'private';
}

/**
 * Interface representing a participant in a group ride room.
 */
export interface Participant {
  uid: string;
  lat: number;
  lng: number;
  speed: number;
  updatedAt: number;
  name: string;
}

export interface RideRoom {
  id: string;
  hostId: string;
  name: string;
  participants: Record<string, Participant>;
}

export interface AIChatMessage {
  role: 'user' | 'model';
  text: string;
  timestamp: number;
}
