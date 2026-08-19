from datetime import datetime, timezone
from typing import List, Optional
from sqlalchemy import String, Integer, Float, Boolean, DateTime, Date, ForeignKey, Text, func, UniqueConstraint
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
import uuid
import random
import string


class Base(DeclarativeBase):
    pass


def generate_uuid() -> str:
    return str(uuid.uuid4())


def generate_referral_code() -> str:
    chars = "".join(random.choices(string.ascii_uppercase + string.digits, k=6))
    return f"RM-{chars}"


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


# ── 1. Users & Auth ──────────────────────────────────────────────
class UserModel(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    email: Mapped[str] = mapped_column(String, unique=True, nullable=False, index=True)
    username: Mapped[str] = mapped_column(String, unique=True, nullable=False, index=True)
    full_name: Mapped[str] = mapped_column(String, nullable=False)
    phone: Mapped[str] = mapped_column(String, default="")
    phone_hash: Mapped[str] = mapped_column(String, default="", index=True)
    referral_code: Mapped[str] = mapped_column(String, unique=True, default=generate_referral_code, index=True)
    referred_by: Mapped[Optional[str]] = mapped_column(String, ForeignKey("users.id"), nullable=True)
    photo_url: Mapped[str] = mapped_column(String, default="")
    bio: Mapped[str] = mapped_column(Text, default="")
    password_hash: Mapped[str] = mapped_column(String, nullable=False)
    rider_level: Mapped[str] = mapped_column(String, default="Novice")
    xp: Mapped[int] = mapped_column(Integer, default=0)
    distance_km: Mapped[float] = mapped_column(Float, default=0.0)
    total_rides: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now, onupdate=utc_now)

    profile: Mapped[Optional["ProfileModel"]] = relationship("ProfileModel", back_populates="user", uselist=False, cascade="all, delete-orphan")
    vehicles: Mapped[List["VehicleModel"]] = relationship("VehicleModel", back_populates="user", cascade="all, delete-orphan")
    rides: Mapped[List["RideModel"]] = relationship("RideModel", back_populates="user", cascade="all, delete-orphan")
    posts: Mapped[List["PostModel"]] = relationship("PostModel", back_populates="author", cascade="all, delete-orphan")
    referrals_made: Mapped[List["ReferralModel"]] = relationship("ReferralModel", foreign_keys="ReferralModel.referrer_id", cascade="all, delete-orphan")


class ReferralModel(Base):
    __tablename__ = "referrals"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    referrer_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    referred_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), unique=True, index=True)
    referral_code: Mapped[str] = mapped_column(String, nullable=False)
    status: Mapped[str] = mapped_column(String, default="converted")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)



# ── 2. Profiles & Preferences ───────────────────────────────────
class ProfileModel(Base):
    __tablename__ = "profiles"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), unique=True, index=True)
    avatar_url: Mapped[str] = mapped_column(String, default="")
    preferred_units: Mapped[str] = mapped_column(String, default="metric")
    preferred_theme: Mapped[str] = mapped_column(String, default="dark")
    language: Mapped[str] = mapped_column(String, default="en")

    user: Mapped["UserModel"] = relationship("UserModel", back_populates="profile")


# ── 3. Vehicles & Maintenance ───────────────────────────────────
class VehicleModel(Base):
    __tablename__ = "vehicles"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    brand: Mapped[str] = mapped_column(String, nullable=False)
    model: Mapped[str] = mapped_column(String, nullable=False)
    year: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    registration_no: Mapped[str] = mapped_column(String, default="")
    color: Mapped[str] = mapped_column(String, default="")
    is_default: Mapped[bool] = mapped_column(Boolean, default=False)
    odometer_km: Mapped[float] = mapped_column(Float, default=0.0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)

    user: Mapped["UserModel"] = relationship("UserModel", back_populates="vehicles")
    rides: Mapped[List["RideModel"]] = relationship("RideModel", back_populates="vehicle")
    maintenance_records: Mapped[List["MaintenanceRecordModel"]] = relationship("MaintenanceRecordModel", back_populates="vehicle", cascade="all, delete-orphan")


class MaintenanceRecordModel(Base):
    __tablename__ = "maintenance_records"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    vehicle_id: Mapped[str] = mapped_column(String, ForeignKey("vehicles.id", ondelete="CASCADE"), index=True)
    title: Mapped[str] = mapped_column(String, nullable=False)
    date: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)
    cost: Mapped[float] = mapped_column(Float, default=0.0)
    workshop_name: Mapped[str] = mapped_column(String, default="")
    invoice_number: Mapped[str] = mapped_column(String, default="")
    notes: Mapped[str] = mapped_column(Text, default="")

    vehicle: Mapped["VehicleModel"] = relationship("VehicleModel", back_populates="maintenance_records")


# ── 4. Rides & Telemetry ─────────────────────────────────────────
class RideModel(Base):
    __tablename__ = "rides"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    vehicle_id: Mapped[Optional[str]] = mapped_column(String, ForeignKey("vehicles.id"), nullable=True)
    title: Mapped[str] = mapped_column(String, default="Solo Ride")
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)
    ended_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    distance_km: Mapped[float] = mapped_column(Float, default=0.0)
    avg_speed_kmh: Mapped[float] = mapped_column(Float, default=0.0)
    max_speed_kmh: Mapped[float] = mapped_column(Float, default=0.0)
    duration_secs: Mapped[int] = mapped_column(Integer, default=0)
    safety_score: Mapped[int] = mapped_column(Integer, default=100)
    calories: Mapped[int] = mapped_column(Integer, default=0)
    weather: Mapped[str] = mapped_column(String, default="")
    origin: Mapped[str] = mapped_column(String, default="")
    destination: Mapped[str] = mapped_column(String, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)

    user: Mapped["UserModel"] = relationship("UserModel", back_populates="rides")
    vehicle: Mapped[Optional["VehicleModel"]] = relationship("VehicleModel", back_populates="rides")


# ── 5. Community Posts, Likes & Comments ────────────────────────
class PostModel(Base):
    __tablename__ = "community_posts"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    type: Mapped[str] = mapped_column(String, default="text")  # text, photo, ride, memory
    caption: Mapped[str] = mapped_column(Text, default="")
    media_url: Mapped[str] = mapped_column(String, default="")
    ride_id: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    memory_id: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    privacy: Mapped[str] = mapped_column(String, default="public")  # public, friends, private
    likes_count: Mapped[int] = mapped_column(Integer, default=0)
    comments_count: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)

    author: Mapped["UserModel"] = relationship("UserModel", back_populates="posts")
    likes: Mapped[List["PostLikeModel"]] = relationship("PostLikeModel", back_populates="post", cascade="all, delete-orphan")
    comments: Mapped[List["PostCommentModel"]] = relationship("PostCommentModel", back_populates="post", cascade="all, delete-orphan")


class PostLikeModel(Base):
    __tablename__ = "post_likes"
    __table_args__ = (UniqueConstraint("post_id", "user_id", name="uq_post_user_like"),)

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    post_id: Mapped[str] = mapped_column(String, ForeignKey("community_posts.id", ondelete="CASCADE"), index=True)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)

    post: Mapped["PostModel"] = relationship("PostModel", back_populates="likes")


class PostCommentModel(Base):
    __tablename__ = "post_comments"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    post_id: Mapped[str] = mapped_column(String, ForeignKey("community_posts.id", ondelete="CASCADE"), index=True)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    author_name: Mapped[str] = mapped_column(String, nullable=False)
    author_avatar: Mapped[str] = mapped_column(String, default="")
    text: Mapped[str] = mapped_column(Text, nullable=False)
    parent_comment_id: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)

    post: Mapped["PostModel"] = relationship("PostModel", back_populates="comments")


class SavedPostModel(Base):
    __tablename__ = "saved_posts"
    __table_args__ = (UniqueConstraint("user_id", "post_id", name="uq_user_saved_post"),)

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    post_id: Mapped[str] = mapped_column(String, ForeignKey("community_posts.id", ondelete="CASCADE"), index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)


class ReportModel(Base):
    __tablename__ = "content_reports"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    reporter_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    item_type: Mapped[str] = mapped_column(String, nullable=False)  # post, comment, user
    item_id: Mapped[str] = mapped_column(String, nullable=False)
    reason: Mapped[str] = mapped_column(String, nullable=False)
    details: Mapped[str] = mapped_column(Text, default="")
    status: Mapped[str] = mapped_column(String, default="pending")  # pending, reviewed, resolved
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)


# ── 6. Friendships & Blocks ─────────────────────────────────────
class FriendshipModel(Base):
    __tablename__ = "friendships"
    __table_args__ = (UniqueConstraint("user_id", "friend_id", name="uq_user_friend"),)

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    friend_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    status: Mapped[str] = mapped_column(String, default="accepted")  # accepted
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)


class FriendRequestModel(Base):
    __tablename__ = "friend_requests"
    __table_args__ = (UniqueConstraint("sender_id", "receiver_id", name="uq_sender_receiver_req"),)

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    sender_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    receiver_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    status: Mapped[str] = mapped_column(String, default="pending")  # pending, accepted, rejected
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)


class BlockedUserModel(Base):
    __tablename__ = "blocked_users"
    __table_args__ = (UniqueConstraint("user_id", "blocked_user_id", name="uq_user_blocked"),)

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    blocked_user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)


# ── 7. Squads & Group Rides ──────────────────────────────────────
class SquadModel(Base):
    __tablename__ = "squads"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    name: Mapped[str] = mapped_column(String, nullable=False)
    description: Mapped[str] = mapped_column(Text, default="")
    creator_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    invite_code: Mapped[str] = mapped_column(String, unique=True, nullable=False, index=True)
    is_private: Mapped[bool] = mapped_column(Boolean, default=False)
    members_count: Mapped[int] = mapped_column(Integer, default=1)
    icon_url: Mapped[str] = mapped_column(String, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)

    members: Mapped[List["SquadMemberModel"]] = relationship("SquadMemberModel", back_populates="squad", cascade="all, delete-orphan")
    group_rides: Mapped[List["GroupRideModel"]] = relationship("GroupRideModel", back_populates="squad", cascade="all, delete-orphan")


class SquadMemberModel(Base):
    __tablename__ = "squad_members"
    __table_args__ = (UniqueConstraint("squad_id", "user_id", name="uq_squad_user_member"),)

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    squad_id: Mapped[str] = mapped_column(String, ForeignKey("squads.id", ondelete="CASCADE"), index=True)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    role: Mapped[str] = mapped_column(String, default="member")  # admin, member
    joined_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)

    squad: Mapped["SquadModel"] = relationship("SquadModel", back_populates="members")


class GroupRideModel(Base):
    __tablename__ = "group_rides"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    squad_id: Mapped[str] = mapped_column(String, ForeignKey("squads.id", ondelete="CASCADE"), index=True)
    creator_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"))
    title: Mapped[str] = mapped_column(String, nullable=False)
    description: Mapped[str] = mapped_column(Text, default="")
    start_time: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    start_location: Mapped[str] = mapped_column(String, default="")
    destination: Mapped[str] = mapped_column(String, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)

    squad: Mapped["SquadModel"] = relationship("SquadModel", back_populates="group_rides")


# ── 8. Stories / Moments ─────────────────────────────────────────
class StoryModel(Base):
    __tablename__ = "stories"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    author_name: Mapped[str] = mapped_column(String, nullable=False)
    author_avatar: Mapped[str] = mapped_column(String, default="")
    media_url: Mapped[str] = mapped_column(String, nullable=False)
    caption: Mapped[str] = mapped_column(Text, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)


# ── 9. Idempotency & Sync Records ────────────────────────────────
class IdempotencyRecordModel(Base):
    __tablename__ = "idempotency_records"
    __table_args__ = (UniqueConstraint("idempotency_key", "user_id", name="uq_idempotency_user_key"),)

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    idempotency_key: Mapped[str] = mapped_column(String, nullable=False, index=True)
    user_id: Mapped[str] = mapped_column(String, nullable=False, index=True)
    endpoint: Mapped[str] = mapped_column(String, nullable=False)
    status_code: Mapped[int] = mapped_column(Integer, nullable=False)
    response_json: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)


# ── 10. Safety Events & Emergency Contacts ──────────────────────
class SafetyEventModel(Base):
    __tablename__ = "safety_events"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    ride_id: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    event_type: Mapped[str] = mapped_column(String, nullable=False)  # crash, hard_braking, overspeed
    severity: Mapped[str] = mapped_column(String, default="low")
    latitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    longitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    g_force: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)


class EmergencyContactModel(Base):
    __tablename__ = "emergency_contacts"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=generate_uuid)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id", ondelete="CASCADE"), index=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    phone: Mapped[str] = mapped_column(String, nullable=False)
    relation: Mapped[str] = mapped_column(String, default="Friend")
    is_primary: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utc_now)
