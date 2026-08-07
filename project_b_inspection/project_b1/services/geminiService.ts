import { GoogleGenAI } from "@google/genai";
import { CoachStats, UserProfile } from '../types';

const getClient = () => {
  const apiKey = process.env.API_KEY;
  if (!apiKey) {
    console.error("API_KEY is missing from environment variables");
    return null;
  }
  return new GoogleGenAI({ apiKey });
};

export const getCoachSummary = async (stats: CoachStats, profile: UserProfile): Promise<string> => {
  const ai = getClient();
  if (!ai) return "Error: API Key missing.";

  const lastRideInfo = stats.lastRide ? `
    Last Ride Stats:
    - Distance: ${stats.lastRide.distanceKm} km
    - Duration: ${stats.lastRide.durationMinutes} min
    - Average Speed: ${stats.lastRide.avgSpeed.toFixed(1)} km/h
    - Overspeed Events (>60km/h): ${stats.lastRide.overspeeds}
    - Safety Score: ${stats.lastRide.score}/100
  ` : "No rides recorded yet.";

  const prompt = `
    You are RiderMate, an expert AI motorcycle riding coach in India.
    
    Rider Profile:
    Name: ${profile.name}
    City: ${profile.city}
    Vehicle: ${profile.vehicleType}
    
    Weekly Stats (Last 7 Days):
    Total Distance: ${stats.totalKmWeek.toFixed(1)} km
    Total Rides: ${stats.totalRidesWeek}
    Total Overspeed Events: ${stats.totalOverspeedsWeek}
    Total Points: ${stats.totalPointsWeek}
    Overall Safety Score: ${stats.avgSafetyScore}/100

    ${lastRideInfo}

    Task:
    Analyze the rider's performance.
    1. Provide a short, personalized summary of their weekly performance (max 2 sentences).
    2. Give 2 specific, actionable safety tips based on their stats (especially if they have overspeed events). Use a friendly but professional "Coach" tone. 
    If the safety score is low (<70), be firm about safety. If high (>90), praise them.
  `;

  try {
    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: prompt,
    });
    return response.text || "Could not generate summary.";
  } catch (error) {
    console.error("Gemini API Error:", error);
    return "Ride safe! I'm currently having trouble connecting to the coaching server.";
  }
};

export const chatWithCoach = async (message: string, stats: CoachStats, profile: UserProfile, history: string[]): Promise<string> => {
  const ai = getClient();
  if (!ai) return "Error: API Key missing.";

  const systemInstruction = `
    You are RiderMate, a friendly and knowledgeable motorcycle riding companion and safety coach in India.
    You are chatting with ${profile.name} from ${profile.city}.
    
    Current Stats:
    - Weekly Safety Score: ${stats.avgSafetyScore}/100
    - Recent Overspeeds: ${stats.totalOverspeedsWeek}
    - Last Ride Score: ${stats.lastRide?.score || 'N/A'}
    
    Guidelines:
    - Keep answers concise, practical, and easy to read on a mobile device (under 100 words).
    - Focus on road safety, vehicle maintenance, and rider well-being (hydration, rest).
    - If the user asks about going fast, strictly advise against overspeeding and emphasize the dangers on Indian roads.
    - Be conversational and encouraging.
  `;

  const fullPrompt = `
    Previous conversation:
    ${history.join('\n')}
    
    User: ${message}
  `;

  try {
    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: fullPrompt,
      config: {
        systemInstruction: systemInstruction,
      }
    });
    return response.text || "I didn't catch that.";
  } catch (error) {
    console.error("Gemini API Error:", error);
    return "Sorry, I'm offline right now. Ride safe!";
  }
};