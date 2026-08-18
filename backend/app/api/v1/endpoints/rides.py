from fastapi import APIRouter, Depends, HTTPException, status, Header
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import desc
from typing import List, Optional
from datetime import datetime
import json

from app.db.session import get_db
from app.models.models import RideModel, UserModel, IdempotencyRecordModel
from app.core.deps import get_current_user

router = APIRouter()


class SyncRideRequest(BaseModel):
    id: Optional[str] = None
    title: str = "Solo Ride"
    vehicle_id: Optional[str] = None
    started_at: datetime
    ended_at: Optional[datetime] = None
    distance_km: float = 0.0
    avg_speed_kmh: float = 0.0
    max_speed_kmh: float = 0.0
    duration_secs: int = 0
    safety_score: int = 100
    calories: int = 0
    weather: str = ""
    origin: str = ""
    destination: str = ""


@router.post("/sync", status_code=status.HTTP_201_CREATED)
def sync_ride(
    body: SyncRideRequest,
    x_idempotency_key: Optional[str] = Header(None),
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Sync completed ride metadata from offline mobile client with idempotency."""
    if x_idempotency_key:
        existing_rec = db.query(IdempotencyRecordModel).filter(
            IdempotencyRecordModel.idempotency_key == x_idempotency_key,
            IdempotencyRecordModel.user_id == current_user.id,
        ).first()
        if existing_rec:
            return json.loads(existing_rec.response_json)

    # Check if ride with same ID already exists
    if body.id:
        existing_ride = db.query(RideModel).filter(RideModel.id == body.id).first()
        if existing_ride:
            return {"message": "Ride already synced", "ride_id": existing_ride.id}

    ride = RideModel(
        id=body.id,
        user_id=current_user.id,
        vehicle_id=body.vehicle_id,
        title=body.title,
        started_at=body.started_at,
        ended_at=body.ended_at,
        distance_km=body.distance_km,
        avg_speed_kmh=body.avg_speed_kmh,
        max_speed_kmh=body.max_speed_kmh,
        duration_secs=body.duration_secs,
        safety_score=body.safety_score,
        calories=body.calories,
        weather=body.weather,
        origin=body.origin,
        destination=body.destination,
    )
    db.add(ride)

    # Update user cumulative stats
    current_user.distance_km += body.distance_km
    current_user.total_rides += 1
    current_user.xp += int(body.distance_km * 10)

    db.commit()
    db.refresh(ride)

    response_data = {
        "message": "Ride synced successfully",
        "ride_id": ride.id,
        "total_distance_km": current_user.distance_km,
        "total_xp": current_user.xp,
    }

    if x_idempotency_key:
        idempotency_rec = IdempotencyRecordModel(
            idempotency_key=x_idempotency_key,
            user_id=current_user.id,
            endpoint="/api/v1/rides/sync",
            status_code=201,
            response_json=json.dumps(response_data),
        )
        db.add(idempotency_rec)
        db.commit()

    return response_data


@router.get("/")
def get_user_rides(
    limit: int = 50,
    offset: int = 0,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """List synced rides for authenticated rider."""
    rides = db.query(RideModel).filter(
        RideModel.user_id == current_user.id
    ).order_by(desc(RideModel.started_at)).offset(offset).limit(limit).all()

    return [
        {
            "id": r.id,
            "title": r.title,
            "started_at": r.started_at,
            "ended_at": r.ended_at,
            "distance_km": r.distance_km,
            "avg_speed_kmh": r.avg_speed_kmh,
            "max_speed_kmh": r.max_speed_kmh,
            "duration_secs": r.duration_secs,
            "safety_score": r.safety_score,
            "weather": r.weather,
        }
        for r in rides
    ]
