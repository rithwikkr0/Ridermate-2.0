from datetime import datetime
from typing import List, Optional
from sqlalchemy import String, Integer, Float, Boolean, DateTime, Date, ForeignKey, Text, ARRAY, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
import uuid

class Base(DeclarativeBase):
    pass

def generate_uuid():
    return str(uuid.uuid4())

# 1. Users
class UserModel(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    email: Mapped[str] = mapped_column(String, unique=True, nullable=False, index=True)
    username: Mapped[str] = mapped_column(String, unique=True, nullable=False, index=True)
    full_name: Mapped[str] = mapped_column(String, nullable=False)
    phone: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    rider_level: Mapped[str] = mapped_column(String, default="Beginner")
    xp: Mapped[int] = mapped_column(Integer, default=0)
    bio: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    profile: Mapped[Optional["ProfileModel"]] = relationship("ProfileModel", back_populates="user", uselist=False)
    vehicles: Mapped[List["VehicleModel"]] = relationship("VehicleModel", back_populates="user")
    rides: Mapped[List["RideModel"]] = relationship("RideModel", back_populates="user")

# 2. Profiles
class ProfileModel(Base):
    __tablename__ = "profiles"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), unique=True)
    avatar_url: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    preferred_units: Mapped[str] = mapped_column(String, default="metric")
    preferred_theme: Mapped[str] = mapped_column(String, default="dark")
    language: Mapped[str] = mapped_column(String, default="en")

    user: Mapped["UserModel"] = relationship("UserModel", back_populates="profile")

# 3. Vehicles
class VehicleModel(Base):
    __tablename__ = "vehicles"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"))
    brand: Mapped[str] = mapped_column(String, nullable=False)
    model: Mapped[str] = mapped_column(String, nullable=False)
    year: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    registration_no: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    color: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    is_default: Mapped[bool] = mapped_column(Boolean, default=False)
    odometer_km: Mapped[float] = mapped_column(Float, default=0.0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user: Mapped["UserModel"] = relationship("UserModel", back_populates="vehicles")
    rides: Mapped[List["RideModel"]] = relationship("RideModel", back_populates="vehicle")
    fuel_records: Mapped[List["FuelRecordModel"]] = relationship("FuelRecordModel", back_populates="vehicle")
    maintenance_records: Mapped[List["MaintenanceRecordModel"]] = relationship("MaintenanceRecordModel", back_populates="vehicle")

# 4. Rides
class RideModel(Base):
    __tablename__ = "rides"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"))
    vehicle_id: Mapped[Optional[str]] = mapped_column(String, ForeignKey("vehicles.id"), nullable=True)
    title: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    ended_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    distance_km: Mapped[float] = mapped_column(Float, default=0.0)
    avg_speed_kmh: Mapped[float] = mapped_column(Float, default=0.0)
    max_speed_kmh: Mapped[float] = mapped_column(Float, default=0.0)
    duration_secs: Mapped[int] = mapped_column(Integer, default=0)
    safety_score: Mapped[int] = mapped_column(Integer, default=100)
    calories: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user: Mapped["UserModel"] = relationship("UserModel", back_populates="rides")
    vehicle: Mapped[Optional["VehicleModel"]] = relationship("VehicleModel", back_populates="rides")
    points: Mapped[List["RidePointModel"]] = relationship("RidePointModel", back_populates="ride", cascade="all, delete-orphan")

# 5. Ride Points
class RidePointModel(Base):
    __tablename__ = "ride_points"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    ride_id: Mapped[str] = mapped_column(String, ForeignKey("rides.id", ondelete="CASCADE"))
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    altitude_m: Mapped[float] = mapped_column(Float, default=0.0)
    speed_kmh: Mapped[float] = mapped_column(Float, default=0.0)
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    ride: Mapped["RideModel"] = relationship("RideModel", back_populates="points")

# 6. Fuel Records
class FuelRecordModel(Base):
    __tablename__ = "fuel_records"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    vehicle_id: Mapped[str] = mapped_column(String, ForeignKey("vehicles.id", ondelete="CASCADE"))
    date: Mapped[datetime] = mapped_column(Date, nullable=False)
    liters: Mapped[float] = mapped_column(Float, nullable=False)
    total_cost: Mapped[float] = mapped_column(Float, nullable=False)
    odometer_km: Mapped[float] = mapped_column(Float, nullable=False)
    mileage_kmpl: Mapped[Optional[float]] = mapped_column(Float, nullable=True)

    vehicle: Mapped["VehicleModel"] = relationship("VehicleModel", back_populates="fuel_records")

# 7. Maintenance Records
class MaintenanceRecordModel(Base):
    __tablename__ = "maintenance_records"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    vehicle_id: Mapped[str] = mapped_column(String, ForeignKey("vehicles.id", ondelete="CASCADE"))
    title: Mapped[str] = mapped_column(String, nullable=False)
    date: Mapped[datetime] = mapped_column(Date, nullable=False)
    cost: Mapped[float] = mapped_column(Float, default=0.0)
    workshop_name: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    invoice_number: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    vehicle: Mapped["VehicleModel"] = relationship("VehicleModel", back_populates="maintenance_records")

# 8. Safety Events
class SafetyEventModel(Base):
    __tablename__ = "safety_events"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"))
    ride_id: Mapped[Optional[str]] = mapped_column(String, ForeignKey("rides.id"), nullable=True)
    event_type: Mapped[str] = mapped_column(String, nullable=False)
    severity: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    latitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    longitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    g_force: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

# 9. Emergency Contacts
class EmergencyContactModel(Base):
    __tablename__ = "emergency_contacts"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"))
    name: Mapped[str] = mapped_column(String, nullable=False)
    phone: Mapped[str] = mapped_column(String, nullable=False)
    relation: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    priority: Mapped[int] = mapped_column(Integer, default=1)

# 10. AI Conversations
class AiConversationModel(Base):
    __tablename__ = "ai_conversations"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"))
    role: Mapped[str] = mapped_column(String, nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
