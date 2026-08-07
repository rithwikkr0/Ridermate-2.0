
import { GoogleGenAI, Type } from "@google/genai";
import { RideSession, AIChatMessage } from "../types";

// Always use the API key directly from process.env.API_KEY as per guidelines.
const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

/**
 * Analyzes motorcycle ride metrics for safety and performance feedback.
 * Uses gemini-3-pro-preview for advanced reasoning as it is a complex text task.
 */
export const analyzeRideSafety = async (metrics: {
  distance: number;
  avgSpeed: number;
  maxSpeed: number;
  duration: number;
}) => {
  try {
    const response = await ai.models.generateContent({
      model: "gemini-3-pro-preview",
      contents: `Analyze this motorcycle ride.
      Metrics: ${metrics.distance.toFixed(2)}km, Avg ${metrics.avgSpeed.toFixed(1)}km/h, Max ${metrics.maxSpeed.toFixed(1)}km/h.`,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            feedback: { type: Type.STRING },
            safetyScore: { type: Type.NUMBER },
            tips: { type: Type.ARRAY, items: { type: Type.STRING } },
            points: { type: Type.NUMBER }
          },
          required: ["feedback", "safetyScore", "tips", "points"]
        }
      }
    });
    // Access .text property directly and return parsed JSON
    return JSON.parse(response.text || '{}');
  } catch (error) {
    return {
      feedback: "Great work, Captain. Your throttle control is improving.",
      safetyScore: 85,
      tips: ["Check blind spots", "Smooth braking"],
      points: 40
    };
  }
};

/**
 * Generates a weekly progress report and a legendary challenge.
 * Uses gemini-3-pro-preview for advanced reasoning.
 */
export const getWeeklyReport = async (history: RideSession[]) => {
  try {
    const stats = history.map(h => ({ d: h.distance, s: h.safetyScore, v: h.avgSpeed }));
    const response = await ai.models.generateContent({
      model: "gemini-3-pro-preview",
      contents: `Generate a Weekly Rider Report based on these 7-day stats: ${JSON.stringify(stats)}.
      Provide a summary of progress and one "Legendary Challenge" for the next week.`,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            summary: { type: Type.STRING },
            progressTrend: { type: Type.STRING },
            challenge: { type: Type.STRING }
          },
          required: ["summary", "progressTrend", "challenge"]
        }
      }
    });
    return JSON.parse(response.text || '{}');
  } catch (error) {
    return { 
      summary: "You've been consistent this week.", 
      progressTrend: "Stable", 
      challenge: "Complete a 100km ride." 
    };
  }
};

/**
 * Fetches conversational AI companion response with ride context.
 * Uses gemini-3-pro-preview for advanced reasoning.
 */
export const getAICompanionResponse = async (history: RideSession[], chatHistory: AIChatMessage[], userQuery: string) => {
  const rideContext = history.slice(0, 5).map(r => ({ d: r.distance, v: r.avgSpeed, q: r.safetyScore }));
  const systemInstruction = `You are "RiderMate AI". Expert coach.
  History: ${JSON.stringify(rideContext)}. Use terms: Rider, Captain. Friendly, alert, protective.`;

  try {
    const response = await ai.models.generateContent({
      model: "gemini-3-pro-preview",
      // contents parameter can be a direct string
      contents: userQuery,
      config: { systemInstruction, temperature: 0.8 }
    });
    return response.text || "Eyes on the road, Rider! The signal is dropping. 🏍️";
  } catch (error) {
    return "Eyes on the road, Rider! The signal is dropping. 🏍️";
  }
};
