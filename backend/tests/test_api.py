import os
import sys

_BACKEND_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _BACKEND_DIR not in sys.path:
    sys.path.insert(0, _BACKEND_DIR)

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.db.session import get_db
from app.models.models import Base

# Setup in-memory SQLite database for testing
TEST_DATABASE_URL = "sqlite:///./test_cloud.db"
test_engine = create_engine(TEST_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)

Base.metadata.drop_all(bind=test_engine)
Base.metadata.create_all(bind=test_engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


def test_health_endpoints():
    r1 = client.get("/health")
    assert r1.status_code == 200
    assert r1.json()["status"] == "healthy"
    assert r1.json()["service"] == "RiderMate 2.0 API"

    r2 = client.get("/api/health")
    assert r2.status_code == 200
    assert r2.json()["status"] == "healthy"


def test_auth_register_and_login():
    # 1. Register User 1
    reg_resp = client.post(
        "/api/v1/auth/register",
        json={
            "email": "rider1@ridermate.app",
            "password": "SecurePassword123!",
            "full_name": "Rithwik Rider",
            "username": "rithwik",
            "phone": "+919876543210",
        },
    )
    assert reg_resp.status_code == 201
    data = reg_resp.json()
    assert "access_token" in data
    assert data["user"]["email"] == "rider1@ridermate.app"
    assert data["user"]["username"] == "rithwik"

    # 2. Login User 1
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "rider1@ridermate.app", "password": "SecurePassword123!"},
    )
    assert login_resp.status_code == 200
    token = login_resp.json()["access_token"]

    # 3. Get /me
    me_resp = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert me_resp.status_code == 200
    assert me_resp.json()["username"] == "rithwik"


def test_community_post_and_idempotency():
    # Register second user
    client.post(
        "/api/v1/auth/register",
        json={
            "email": "rider2@ridermate.app",
            "password": "SecurePassword123!",
            "full_name": "Ghost Rider",
            "username": "ghostrider",
        },
    )
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "rider2@ridermate.app", "password": "SecurePassword123!"},
    )
    token = login_resp.json()["access_token"]

    # 1. Create post with Idempotency Key
    idempotency_key = "test_idem_post_001"
    post_payload = {
        "type": "text",
        "caption": "Night ride across the western ghats! 🏍️⚡",
        "privacy": "public",
    }
    p1 = client.post(
        "/api/v1/community/posts",
        json=post_payload,
        headers={"Authorization": f"Bearer {token}", "x-idempotency-key": idempotency_key},
    )
    assert p1.status_code == 201
    post_id = p1.json()["id"]

    # 2. Retry identical post with same Idempotency Key -> returns exact same post ID without creating duplicate
    p2 = client.post(
        "/api/v1/community/posts",
        json=post_payload,
        headers={"Authorization": f"Bearer {token}", "x-idempotency-key": idempotency_key},
    )
    assert p2.status_code == 201
    assert p2.json()["id"] == post_id

    # 3. Like Post
    like_resp = client.post(f"/api/v1/community/posts/{post_id}/like", headers={"Authorization": f"Bearer {token}"})
    assert like_resp.status_code == 200
    assert like_resp.json()["likes_count"] == 1

    # 4. Comment on Post
    comment_resp = client.post(
        f"/api/v1/community/posts/{post_id}/comments",
        json={"text": "Awesome route!"},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert comment_resp.status_code == 201
    assert comment_resp.json()["text"] == "Awesome route!"

    # 5. Fetch Feed
    feed_resp = client.get("/api/v1/community/feed", headers={"Authorization": f"Bearer {token}"})
    assert feed_resp.status_code == 200
    posts = feed_resp.json()
    assert len(posts) >= 1
    assert posts[0]["id"] == post_id
    assert posts[0]["is_liked"] is True


def test_squads_and_invite_codes():
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "rider1@ridermate.app", "password": "SecurePassword123!"},
    )
    token1 = login_resp.json()["access_token"]

    login_resp2 = client.post(
        "/api/v1/auth/login",
        json={"email": "rider2@ridermate.app", "password": "SecurePassword123!"},
    )
    token2 = login_resp2.json()["access_token"]

    # 1. Create Squad
    squad_resp = client.post(
        "/api/v1/squads/",
        json={"name": "Bengaluru Throttle Club", "description": "Weekend rides"},
        headers={"Authorization": f"Bearer {token1}"},
    )
    assert squad_resp.status_code == 201
    squad_data = squad_resp.json()
    squad_id = squad_data["id"]
    invite_code = squad_data["invite_code"]
    assert invite_code.startswith("RM-")

    # 2. Join Squad with invite code from User 2
    join_resp = client.post(
        f"/api/v1/squads/{squad_id}/join",
        json={"invite_code": invite_code},
        headers={"Authorization": f"Bearer {token2}"},
    )
    assert join_resp.status_code == 200
    assert join_resp.json()["message"] == "Successfully joined squad"

    # 3. Check Squad details
    details_resp = client.get(f"/api/v1/squads/{squad_id}")
    assert details_resp.status_code == 200
    assert details_resp.json()["members_count"] == 2


def test_safety_analyze_endpoint():
    resp = client.post(
        "/api/safety/analyze",
        json={
            "rideId": "ride-test-123",
            "distanceKm": 54.2,
            "durationMinutes": 62,
            "maxSpeedKmh": 105.0,
            "averageSpeedKmh": 52.4,
            "safetyEvents": [{"type": "overspeed", "speedKmh": 105.0}],
        },
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["riskLevel"] in ["low", "medium", "high"]
    assert "message" in data
    assert len(data["tips"]) > 0


def test_ride_sync_with_idempotency():
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "rider1@ridermate.app", "password": "SecurePassword123!"},
    )
    token = login_resp.json()["access_token"]

    sync_resp = client.post(
        "/api/v1/rides/sync",
        json={
            "id": "ride_uuid_1001",
            "title": "Nandi Hills Sunrise Ride",
            "started_at": "2026-08-18T05:30:00Z",
            "ended_at": "2026-08-18T07:15:00Z",
            "distance_km": 65.4,
            "avg_speed_kmh": 48.2,
            "max_speed_kmh": 85.0,
            "duration_secs": 6300,
            "safety_score": 95,
        },
        headers={"Authorization": f"Bearer {token}", "x-idempotency-key": "idem_ride_1001"},
    )
    assert sync_resp.status_code == 201
    assert sync_resp.json()["ride_id"] == "ride_uuid_1001"


def test_media_upload_and_sas():
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "rider1@ridermate.app", "password": "SecurePassword123!"},
    )
    token = login_resp.json()["access_token"]

    # Upload test image
    file_payload = {"file": ("test_avatar.jpg", b"fake_image_bytes_1234567890", "image/jpeg")}
    upload_resp = client.post(
        "/api/v1/media/upload",
        files=file_payload,
        headers={"Authorization": f"Bearer {token}"},
    )
    assert upload_resp.status_code == 200
    data = upload_resp.json()
    assert "url" in data
    assert "blob_name" in data

    # Query SAS URL
    sas_resp = client.get(
        f"/api/v1/media/sas-url?blob_name={data['blob_name']}",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert sas_resp.status_code == 200
    assert "url" in sas_resp.json()


def test_google_sign_in():
    resp = client.post(
        "/api/v1/auth/google",
        json={
            "id_token": "simulated_google_jwt_token",
            "email": "googlerider@gmail.com",
            "full_name": "Google Explorer",
            "photo_url": "https://example.com/avatar.jpg",
        },
    )
    assert resp.status_code == 200
    data = resp.json()
    assert "access_token" in data
    assert data["user"]["email"] == "googlerider@gmail.com"
    assert data["user"]["username"].startswith("googlerider")


def test_phone_otp_and_verification():
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "rider1@ridermate.app", "password": "SecurePassword123!"},
    )
    token = login_resp.json()["access_token"]

    # 1. Send OTP
    send_resp = client.post("/api/v1/auth/phone/send-otp", json={"phone": "+919876543210"})
    assert send_resp.status_code == 200
    assert send_resp.json()["status"] == "success"

    # 2. Verify OTP
    verify_resp = client.post(
        "/api/v1/auth/phone/verify-otp",
        json={"phone": "+919876543210", "otp": "123456"},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert verify_resp.status_code == 200
    user_data = verify_resp.json()
    assert user_data["phone"] == "+919876543210"


def test_contact_matching_privacy():
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "rider2@ridermate.app", "password": "SecurePassword123!"},
    )
    token = login_resp.json()["access_token"]

    # Compute SHA-256 hash of rider1's phone "+919876543210"
    import hashlib
    h = hashlib.sha256("+919876543210".encode("utf-8")).hexdigest()

    match_resp = client.post(
        "/api/v1/friends/match-contacts",
        json={"phone_hashes": [h, "0" * 64]},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert match_resp.status_code == 200
    matches = match_resp.json()["matches"]
    assert len(matches) >= 1
    assert matches[0]["username"] == "rithwik"


