
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getDatabase } from "firebase/database";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

/**
 * PRODUCTION NOTE:
 * Ensure your Firebase Console has the following rules set:
 * 
 * Firestore:
 * allow read, write: if true; (For testing - switch to 'request.auth != null' later)
 * 
 * Realtime Database:
 * { "rules": { ".read": true, ".write": true } }
 * 
 * Storage:
 * allow read, write: if true;
 */

const firebaseConfig = {
  apiKey: "AIzaSy_fake_key", // Replace with your real API Key
  authDomain: "ridermate-prod.firebaseapp.com",
  projectId: "ridermate-prod",
  storageBucket: "ridermate-prod.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef",
  databaseURL: "https://ridermate-prod-default-rtdb.firebaseio.com"
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getDatabase(app);
export const firestore = getFirestore(app);
export const storage = getStorage(app);
