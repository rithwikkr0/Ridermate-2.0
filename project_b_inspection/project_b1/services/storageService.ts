import { Ride, UserProfile, Memory, CoachStats } from '../types';

const BASE_KEYS = {
  PROFILE: 'ridermate_profile',
  RIDES: 'ridermate_rides',
  MEMORIES: 'ridermate_memories',
  SESSION: 'ridermate_session',
  USERS: 'ridermate_users', // Map of email -> password
};

// --- Helper for User-Scoped Keys ---
const getStorageKey = (key: string): string => {
  const sessionStr = localStorage.getItem(BASE_KEYS.SESSION);
  if (!sessionStr) return key; // Fallback for non-logged in (shouldn't happen in protected app)
  
  try {
    const session = JSON.parse(sessionStr);
    return `${session.email}_${key}`;
  } catch (e) {
    return key;
  }
};

// --- Mock Initial Data (Templates) ---
const INITIAL_RIDES_TEMPLATE: Ride[] = [
  {
    id: 'ride-demo-1',
    startTime: Date.now() - 86400000 * 2,
    endTime: Date.now() - 86400000 * 2 + 1800000,
    distanceKm: 12.5,
    durationMinutes: 30,
    maxSpeed: 55,
    avgSpeed: 25,
    overspeedEvents: 0,
    points: 125,
    safetyScore: 95,
    path: []
  },
  {
    id: 'ride-demo-2',
    startTime: Date.now() - 86400000,
    endTime: Date.now() - 86400000 + 3600000,
    distanceKm: 28.2,
    durationMinutes: 60,
    maxSpeed: 72,
    avgSpeed: 28,
    overspeedEvents: 3,
    points: 200,
    safetyScore: 78,
    path: []
  }
];

const INITIAL_MEMORIES_TEMPLATE: Memory[] = [
    {
      id: 'mem-demo-1',
      note: 'Great view of the hills!',
      latitude: 12.9716,
      longitude: 77.5946,
      timestamp: Date.now() - 1000000,
      privacy: 'Public',
      imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=600&q=80'
    }
];

// --- Auth Services ---

export const isAuthenticated = (): boolean => {
  return !!localStorage.getItem(BASE_KEYS.SESSION);
};

// Internal helper to set session and init data
const setSessionAndInitData = (email: string) => {
  // 1. Set Session
  localStorage.setItem(BASE_KEYS.SESSION, JSON.stringify({ email, loginTime: Date.now() }));
  
  // 2. Initialize User Data if new
  const profileKey = getStorageKey(BASE_KEYS.PROFILE);
  if (!localStorage.getItem(profileKey)) {
    const defaultProfile: UserProfile = {
      name: email.split('@')[0], // Default name from email
      age: 25,
      city: 'Bangalore',
      vehicleType: 'Motorcycle',
      weight: 70
    };
    localStorage.setItem(profileKey, JSON.stringify(defaultProfile));
    
    // Seed initial demo data for the new user so the app isn't empty
    localStorage.setItem(getStorageKey(BASE_KEYS.RIDES), JSON.stringify(INITIAL_RIDES_TEMPLATE));
    localStorage.setItem(getStorageKey(BASE_KEYS.MEMORIES), JSON.stringify(INITIAL_MEMORIES_TEMPLATE));
  }
};

export const registerUser = (email: string, password: string): { success: boolean; message?: string } => {
  const usersStr = localStorage.getItem(BASE_KEYS.USERS);
  const users = usersStr ? JSON.parse(usersStr) : {};

  if (users[email]) {
    return { success: false, message: 'User already exists. Please login.' };
  }

  // Save credentials
  users[email] = password;
  localStorage.setItem(BASE_KEYS.USERS, JSON.stringify(users));

  // Log them in immediately
  setSessionAndInitData(email);
  return { success: true };
};

export const loginUser = (email: string, password: string): { success: boolean; message?: string } => {
  const usersStr = localStorage.getItem(BASE_KEYS.USERS);
  const users = usersStr ? JSON.parse(usersStr) : {};

  if (!users[email]) {
    return { success: false, message: 'User not found. Please sign up.' };
  }

  if (users[email] !== password) {
    return { success: false, message: 'Incorrect password.' };
  }

  setSessionAndInitData(email);
  return { success: true };
};

export const logoutUser = () => {
  localStorage.removeItem(BASE_KEYS.SESSION);
};

export const getCurrentUserEmail = (): string | null => {
    const sessionStr = localStorage.getItem(BASE_KEYS.SESSION);
    if (!sessionStr) return null;
    try {
        return JSON.parse(sessionStr).email;
    } catch {
        return null;
    }
};

// --- Data Services ---

export const getProfile = (): UserProfile => {
  const key = getStorageKey(BASE_KEYS.PROFILE);
  const stored = localStorage.getItem(key);
  if (stored) return JSON.parse(stored);
  return {
    name: 'Rider',
    age: 24,
    city: 'Bangalore',
    vehicleType: 'Motorcycle',
    weight: 70
  };
};

export const saveProfile = (profile: UserProfile) => {
  const key = getStorageKey(BASE_KEYS.PROFILE);
  localStorage.setItem(key, JSON.stringify(profile));
};

export const getRides = (): Ride[] => {
  const key = getStorageKey(BASE_KEYS.RIDES);
  const stored = localStorage.getItem(key);
  if (stored) return JSON.parse(stored);
  return [];
};

export const saveRide = (ride: Ride) => {
  const key = getStorageKey(BASE_KEYS.RIDES);
  const rides = getRides();
  const updated = [ride, ...rides];
  localStorage.setItem(key, JSON.stringify(updated));
};

export const getMemories = (): Memory[] => {
  const key = getStorageKey(BASE_KEYS.MEMORIES);
  const stored = localStorage.getItem(key);
  if (stored) return JSON.parse(stored);
  return [];
};

export const saveMemory = (memory: Memory) => {
  const key = getStorageKey(BASE_KEYS.MEMORIES);
  const memories = getMemories();
  const updated = [memory, ...memories];
  localStorage.setItem(key, JSON.stringify(updated));
};

export const getWeeklyStats = (): CoachStats => {
  const rides = getRides();
  const oneWeekAgo = Date.now() - 7 * 24 * 60 * 60 * 1000;
  const recentRides = rides.filter(r => r.startTime > oneWeekAgo);

  const totalKm = recentRides.reduce((acc, r) => acc + r.distanceKm, 0);
  const totalOverspeeds = recentRides.reduce((acc, r) => acc + r.overspeedEvents, 0);
  const totalPoints = recentRides.reduce((acc, r) => acc + r.points, 0);
  
  // Weighted average for safety score (more recent rides matter? For now simple average)
  const totalScore = recentRides.reduce((acc, r) => acc + r.safetyScore, 0);
  const avgSafetyScore = recentRides.length ? Math.round(totalScore / recentRides.length) : 100;

  const lastRide = rides.length > 0 ? rides[0] : undefined;

  return {
    totalKmWeek: parseFloat(totalKm.toFixed(1)),
    totalRidesWeek: recentRides.length,
    totalOverspeedsWeek: totalOverspeeds,
    totalPointsWeek: totalPoints,
    avgSafetyScore: avgSafetyScore,
    lastRide: lastRide ? {
      date: lastRide.startTime,
      distanceKm: lastRide.distanceKm,
      durationMinutes: lastRide.durationMinutes,
      overspeeds: lastRide.overspeedEvents,
      avgSpeed: lastRide.avgSpeed,
      score: lastRide.safetyScore
    } : undefined
  };
};