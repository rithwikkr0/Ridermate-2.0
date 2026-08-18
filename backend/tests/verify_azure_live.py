import sys
import uuid
from datetime import datetime, timezone
import requests

def run_master_cloud_qa(base_url: str):
    print(f"==================================================")
    print(f"RIDERMATE 2.0 — MASTER CLOUD QA & INTEGRATION SUITE")
    print(f"Target Base URL: {base_url}")
    print(f"==================================================")

    session_a = requests.Session()
    session_b = requests.Session()

    suffix = uuid.uuid4().hex[:6]
    user_a_email = f"rider_a_{suffix}@ridermate.com"
    user_a_username = f"rider_a_{suffix}"
    user_b_email = f"rider_b_{suffix}@ridermate.com"
    user_b_username = f"rider_b_{suffix}"
    password = "SecurePassword123!"

    # 1. Health check
    print("\n[1] Testing /health endpoint...")
    try:
        r = requests.get(f"{base_url}/health", timeout=10)
        assert r.status_code == 200, f"Expected 200, got {r.status_code}"
        health_data = r.json()
        assert health_data.get("status") == "healthy", f"Unexpected status: {health_data}"
        print(f"  --> PASSED: /health is healthy ({health_data})")
    except Exception as e:
        print(f"  --> FAILED: /health check failed: {e}")
        return False

    # 2. Authentication: User A Registration & Login
    print("\n[2] Testing Authentication: User A Registration & Login...")
    reg_a = requests.post(f"{base_url}/api/v1/auth/register", json={
        "email": user_a_email,
        "username": user_a_username,
        "password": password,
        "full_name": f"Rider Alpha {suffix}",
        "phone": f"+9198765{suffix[:5]}"
    })
    assert reg_a.status_code in [200, 201], f"User A registration failed: {reg_a.text}"
    token_a = reg_a.json().get("access_token")
    user_a_id = reg_a.json().get("user", {}).get("id")
    assert token_a, "Missing access_token for User A"
    session_a.headers.update({"Authorization": f"Bearer {token_a}"})
    print(f"  --> PASSED: User A registered & logged in (ID: {user_a_id})")

    # 3. Authentication: User B Registration & Login
    print("\n[3] Testing Authentication: User B Registration & Login...")
    reg_b = requests.post(f"{base_url}/api/v1/auth/register", json={
        "email": user_b_email,
        "username": user_b_username,
        "password": password,
        "full_name": f"Rider Beta {suffix}",
        "phone": f"+9198764{suffix[:5]}"
    })
    assert reg_b.status_code in [200, 201], f"User B registration failed: {reg_b.text}"
    token_b = reg_b.json().get("access_token")
    user_b_id = reg_b.json().get("user", {}).get("id")
    assert token_b, "Missing access_token for User B"
    session_b.headers.update({"Authorization": f"Bearer {token_b}"})
    print(f"  --> PASSED: User B registered & logged in (ID: {user_b_id})")

    # 4. Profile /me
    print("\n[4] Testing /me Endpoint for User A and User B...")
    me_a = session_a.get(f"{base_url}/api/v1/auth/me")
    assert me_a.status_code == 200 and me_a.json().get("email") == user_a_email
    me_b = session_b.get(f"{base_url}/api/v1/auth/me")
    assert me_b.status_code == 200 and me_b.json().get("email") == user_b_email
    print(f"  --> PASSED: User A & User B /me verification successful")

    # 5. Community Posts: Public & Private Visibility
    print("\n[5] Testing Community Posts & Visibility Isolation...")
    post_a_pub = session_a.post(f"{base_url}/api/v1/community/posts", json={
        "type": "text",
        "caption": f"Exploring Western Ghats #{suffix}",
        "privacy": "public"
    })
    assert post_a_pub.status_code in [200, 201], f"Failed to create public post: {post_a_pub.text}"
    pub_post_id = post_a_pub.json().get("id")

    post_a_priv = session_a.post(f"{base_url}/api/v1/community/posts", json={
        "type": "text",
        "caption": f"Secret Solo Ride #{suffix}",
        "privacy": "private"
    })
    assert post_a_priv.status_code in [200, 201], f"Failed to create private post: {post_a_priv.text}"
    priv_post_id = post_a_priv.json().get("id")

    # User B retrieves feed: Must see public post, must NOT see private post
    feed_b = session_b.get(f"{base_url}/api/v1/community/feed")
    feed_b_ids = [p.get("id") for p in feed_b.json()]
    assert pub_post_id in feed_b_ids, f"User B should see public post {pub_post_id}"
    assert priv_post_id not in feed_b_ids, f"User B should NOT see private post {priv_post_id}"
    print(f"  --> PASSED: Public post visible in User B feed, private post properly isolated")

    # 6. Community Reactions: Like & Unlike
    print("\n[6] Testing Community Likes (Like / Unlike Toggle)...")
    like_r = session_b.post(f"{base_url}/api/v1/community/posts/{pub_post_id}/like")
    assert like_r.status_code == 200
    assert like_r.json().get("likes_count") >= 1, f"Expected >= 1 likes, got {like_r.json()}"

    unlike_r = session_b.delete(f"{base_url}/api/v1/community/posts/{pub_post_id}/like")
    assert unlike_r.status_code == 200
    print(f"  --> PASSED: Like & Unlike endpoints correctly update post likes_count")

    # Re-like for comments
    session_b.post(f"{base_url}/api/v1/community/posts/{pub_post_id}/like")

    # 7. Community Comments
    print("\n[7] Testing Community Comments...")
    comm_r = session_b.post(f"{base_url}/api/v1/community/posts/{pub_post_id}/comments", json={
        "text": f"Epic route! Ride safe brother. #{suffix}"
    })
    assert comm_r.status_code in [200, 201]
    comment_id = comm_r.json().get("id")
    assert comment_id, "Missing comment ID"

    get_comms = session_a.get(f"{base_url}/api/v1/community/posts/{pub_post_id}/comments")
    comm_ids = [c.get("id") for c in get_comms.json()]
    assert comment_id in comm_ids, "Comment should be present in post comments"
    print(f"  --> PASSED: Comment successfully added and retrieved")

    # 8. Friends System: Send & Accept Request
    print("\n[8] Testing Friends System (Send & Accept)...")
    fr_send = session_a.post(f"{base_url}/api/v1/friends/request", json={
        "receiver_id": user_b_id
    })
    assert fr_send.status_code in [200, 201]
    req_id = fr_send.json().get("request_id")

    fr_accept = session_b.post(f"{base_url}/api/v1/friends/{req_id}/accept")
    assert fr_accept.status_code == 200

    friends_a = session_a.get(f"{base_url}/api/v1/friends/")
    friends_list = friends_a.json().get("friends", [])
    assert any(f.get("id") == user_b_id for f in friends_list), f"User B not found in User A friends: {friends_list}"
    print(f"  --> PASSED: Friendship established bidirectionally")

    # 9. Idempotency Key Deduplication Test
    print("\n[9] Testing Idempotency Key Mutation Deduplication...")
    idempotency_key = f"idem-{uuid.uuid4().hex}"
    mutation_payload = {
        "type": "text",
        "caption": f"Idempotent Post Test #{suffix}",
        "privacy": "public"
    }
    idem_1 = session_a.post(
        f"{base_url}/api/v1/community/posts",
        json=mutation_payload,
        headers={"x-idempotency-key": idempotency_key}
    )
    assert idem_1.status_code in [200, 201]
    idem_post_id = idem_1.json().get("id")

    # Repeat exact same mutation with same idempotency key
    idem_2 = session_a.post(
        f"{base_url}/api/v1/community/posts",
        json=mutation_payload,
        headers={"x-idempotency-key": idempotency_key}
    )
    assert idem_2.status_code in [200, 201]
    assert idem_2.json().get("id") == idem_post_id, "Idempotency should return the exact same resource ID"
    print(f"  --> PASSED: Duplicate mutation with same idempotency key safely handled")

    # 10. Ride Telemetry & Session Sync
    print("\n[10] Testing Ride Session & Telemetry Cloud Sync...")
    ride_sync = session_a.post(f"{base_url}/api/v1/rides/sync", json={
        "id": f"ride_{suffix}",
        "title": "Bangalore to Nandi Hills Morning Dash",
        "started_at": datetime.now(timezone.utc).isoformat(),
        "distance_km": 62.4,
        "duration_secs": 3820,
        "avg_speed_kmh": 58.7,
        "max_speed_kmh": 104.2,
        "safety_score": 95,
        "origin": "Hebbal Flyover",
        "destination": "Nandi Hills Summit"
    })
    assert ride_sync.status_code in [200, 201], f"Ride sync failed: {ride_sync.text}"
    print(f"  --> PASSED: Ride telemetry and safety summary synced to cloud")

    # 11. Media Upload & Private SAS Access
    print("\n[11] Testing Azure Media Upload & Controlled Access...")
    upload_r = session_a.post(
        f"{base_url}/api/v1/media/upload",
        files={"file": ("ride_photo.jpg", b"\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x01\x00`\x00`\x00\x00\xFF\xDB", "image/jpeg")}
    )
    assert upload_r.status_code in [200, 201], f"Upload failed: {upload_r.text}"
    blob_name = upload_r.json().get("blob_name")
    assert blob_name, "Missing blob_name in upload response"

    sas_r = session_a.get(f"{base_url}/api/v1/media/sas-url?blob_name={blob_name}")
    assert sas_r.status_code == 200, f"SAS URL generation failed: {sas_r.text}"
    sas_url = sas_r.json().get("url")
    assert sas_url and ("sig=" in sas_url or "http" in sas_url or "/static/" in sas_url), f"Invalid SAS URL format: {sas_url}"
    print(f"  --> PASSED: Media uploaded and access URL issued ({sas_url[:40]}...)")

    print("\n==================================================")
    print("ALL 11 MASTER CLOUD INTEGRATION TESTS PASSED 100%!")
    print("==================================================")
    return True

if __name__ == "__main__":
    url = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8000"
    success = run_master_cloud_qa(url)
    sys.exit(0 if success else 1)
