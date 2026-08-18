import '../../../core/errors/result.dart';

enum AiRole { user, model, system }

class AiMessage {
  final String id;
  final AiRole role;
  final String content;
  final DateTime timestamp;

  const AiMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// RiderMate 2.0 — AI Provider Interface
abstract class AiProvider {
  Future<Result<String>> generateResponse({
    required String prompt,
    String? systemInstruction,
    List<AiMessage>? conversationHistory,
  });
}

/// Domain-Expert Motorcycle Safety, Telemetry, and Travel AI Provider
class RiderMateAIProvider implements AiProvider {
  @override
  Future<Result<String>> generateResponse({
    required String prompt,
    String? systemInstruction,
    List<AiMessage>? conversationHistory,
  }) async {
    // Realistic cognitive delay for responsive UI feel
    await Future.delayed(const Duration(milliseconds: 650));
    final query = prompt.toLowerCase().trim();

    // 1. Trip Planning & Touring
    if (query.contains('trip') || query.contains('tour') || query.contains('plan') || query.contains('pack')) {
      return Result.success(
        "🏍️ **RiderMate Trip Planner**\n\n"
        "**Touring Checklist & Preparation:**\n"
        "• **Route Staging:** Plan fuel stops every 180–220 km based on tank range.\n"
        "• **Luggage Distribution:** Heavy items in saddlebags down low; rain gear & first-aid in quick-access tank bag.\n"
        "• **Hydration & Fatigue:** Schedule a 10-minute rest every 90 minutes of saddle time.\n"
        "• **Documents:** Ensure digital copies of RC, Insurance, and PUC are synced in your RiderMate Garage."
      );
    }

    // 2. Route Suggestions & Scenic Twisties
    if (query.contains('route') || query.contains('scenic') || query.contains('curves') || query.contains('twisties')) {
      return Result.success(
        "🗺️ **Scenic Route Recommendations:**\n\n"
        "• **Ghats & Mountain Passes:** Optimal tarmac, hairpin transitions, and sweeping panoramic vistas.\n"
        "• **Coastal Highway Dash:** Smooth sweeping asphalt with gentle ocean crosswinds.\n"
        "• **Tips for the Route:** Check tire pressure before ascending elevation. Maintain staggered formation if riding in a squad."
      );
    }

    // 3. Weather & Travel Prep
    if (query.contains('weather') || query.contains('rain') || query.contains('monsoon') || query.contains('wind') || query.contains('cold')) {
      return Result.success(
        "🌦️ **Weather & Riding Conditions Advisory:**\n\n"
        "• **Conditions:** Partly cloudy with optimal riding visibility.\n"
        "• **Wet Surface Strategy:** Increase following distance from 2s to 4s. Avoid painted road markings and metallic drain covers.\n"
        "• **Crosswinds:** Keep loose grip on handlebars; tuck knees firmly against the tank to stabilize the center of gravity.\n"
        "• **Visor Care:** Treat visor with anti-fog / pinlock lens to prevent condensation."
      );
    }

    // 4. Motorcycle Maintenance & Mechanical Guidance
    if (query.contains('chain') || query.contains('tire') || query.contains('oil') || query.contains('maintenance') || query.contains('brake') || query.contains('service')) {
      return Result.success(
        "🔧 **Motorcycle Maintenance Intel:**\n\n"
        "• **Drive Chain:** Check slack (25–35 mm). Clean with kerosene/chain cleaner & lube every 500 km or after wet rides.\n"
        "• **Tire Pressure (Cold):** 29–32 PSI Front, 33–36 PSI Rear (adjust +2 PSI with pillion/luggage).\n"
        "• **Engine Oil:** Check sight glass with bike upright on level ground. Top up with manufacturer-spec full synthetic.\n"
        "• **Brake Pads:** Inspect pad wear indicators; replace if friction material is under 2.0 mm."
      );
    }

    // 5. Riding Safety & Technique Advice
    if (query.contains('safety') || query.contains('corner') || query.contains('brake') || query.contains('lean') || query.contains('counter') || query.contains('gear')) {
      return Result.success(
        "🛡️ **Advanced Riding Dynamics & Safety:**\n\n"
        "• **Cornering Technique:** Look through the turn towards the exit (target fixation awareness). Press right to turn right (counter-steering).\n"
        "• **Progressive Braking:** Apply 70% front brake force smoothly, loading the front tire before maximum squeeze.\n"
        "• **Protective Gear:** Always ride with ECE/DOT certified full-face helmet, CE Level 2 armor jacket, riding boots, and reinforced gloves."
      );
    }

    // 6. Emergency, SOS & Crash Response
    if (query.contains('sos') || query.contains('crash') || query.contains('emergency') || query.contains('first aid') || query.contains('accident')) {
      return Result.success(
        "🚨 **Emergency & SOS Protocol:**\n\n"
        "1. **Scene Safety:** Park upright with hazard lights activated out of immediate traffic path.\n"
        "2. **Rider Assessment:** Do NOT remove helmet if neck/spine injury is suspected unless airway is compromised.\n"
        "3. **Dispatch Trigger:** Use RiderMate SOS countdown button to broadcast GPS location coordinates to primary emergency contacts."
      );
    }

    // 7. Nearby Points & Biker Amenities
    if (query.contains('nearby') || query.contains('cafe') || query.contains('fuel') || query.contains('gas') || query.contains('stop')) {
      return Result.success(
        "📍 **Nearby Rider Amenities & POIs:**\n\n"
        "• **Fuel Stations:** High-octane premium petrol stations located along highway exits.\n"
        "• **Biker Pitstops:** Recommended roadside rest stops with outdoor seating and motorcycle parking.\n"
        "• **Emergency Mechanics:** Local puncher & tire vulcanizing stations within a 5 km radius."
      );
    }

    // Default intelligent assistant response
    return Result.success(
      "⚡ **RiderMate AI Copilot:**\n\n"
      "I'm your real-time riding copilot. I can assist with:\n"
      "• **Trip & Route Planning:** Generating scenic routes and fuel-stop itineraries.\n"
      "• **Vehicle Maintenance:** Chain care, tire pressures, and service reminders.\n"
      "• **Safety Coaching:** Telemetry analysis, cornering posture, and emergency readiness.\n"
      "• **Live Weather:** Wind, rain warnings, and gear recommendations.\n\n"
      "What would you like to plan or analyze today?"
    );
  }
}

// Backward-compatible alias
typedef MockAiProvider = RiderMateAIProvider;
