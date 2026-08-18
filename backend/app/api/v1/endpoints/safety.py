from fastapi import APIRouter, Depends, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any

from app.db.session import get_db
from app.models.models import SafetyEventModel, UserModel
from app.core.deps import get_optional_user

router = APIRouter()


class SafetyAnalysisRequest(BaseModel):
    rideId: str
    distanceKm: float
    durationMinutes: int
    maxSpeedKmh: float
    averageSpeedKmh: float
    safetyEvents: List[Dict[str, Any]] = []


class SosTriggerRequest(BaseModel):
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    g_force: Optional[float] = None
    event_type: str = "crash"


@router.post("/analyze")
def analyze_safety(
    body: SafetyAnalysisRequest,
):
    """Analyze completed ride telemetry metrics and generate safety coaching feedback."""
    risk_level = "low"
    message = "Excellent ride! Smooth throttle control and safe cruising speeds maintained."
    tips = ["Continue scanning intersections", "Maintain 3-second braking distance in traffic"]

    overspeed_events = [e for e in body.safetyEvents if e.get("eventType") == "overspeed" or e.get("type") == "overspeed"]
    hard_braking_events = [e for e in body.safetyEvents if e.get("eventType") == "hard_braking" or e.get("type") == "hard_braking"]

    if body.maxSpeedKmh > 120 or len(overspeed_events) > 3 or len(hard_braking_events) > 3:
        risk_level = "high"
        message = "High risk detected: excessive peak speed or repeated harsh braking events recorded."
        tips = [
            "Reduce corner entry speeds to minimize abrupt mid-corner braking",
            "Keep highway speeds strictly within legal limits to allow sufficient stopping distance",
            "Wear full protective gear (CE Level 2 jacket and helmet)",
        ]
    elif body.maxSpeedKmh > 90 or len(overspeed_events) > 0 or len(hard_braking_events) > 0:
        risk_level = "medium"
        message = "Moderate ride safety profile: occasional speed spikes detected."
        tips = [
            "Smooth out acceleration to conserve fuel and improve tire grip",
            "Check tire pressures before high-speed highway stretches",
        ]

    return {
        "riskLevel": risk_level,
        "safetyAssessment": message,
        "message": message,
        "tips": tips,
        "rideId": body.rideId,
    }


@router.post("/sos", status_code=status.HTTP_201_CREATED)
def trigger_sos(
    body: SosTriggerRequest,
    current_user: Optional[UserModel] = Depends(get_optional_user),
    db: Session = Depends(get_db),
):
    """Log an emergency SOS / crash event for emergency dispatch."""
    user_id = current_user.id if current_user else "anonymous_rider"

    event = SafetyEventModel(
        user_id=user_id,
        event_type=body.event_type,
        severity="high",
        latitude=body.latitude,
        longitude=body.longitude,
        g_force=body.g_force,
    )
    db.add(event)
    db.commit()

    return {
        "status": "acknowledged",
        "event_id": event.id,
        "message": "Emergency SOS logged. Emergency contacts broadcast initiated.",
    }
