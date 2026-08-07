from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
    assert response.json()["version"] == "2.0.0"

def test_auth_login_mock():
    response = client.post("/api/v1/auth/login", json={"email": "rider@ridermate.app", "password": "password123"})
    assert response.status_code == 200
    assert "access_token" in response.json()

def test_auth_register_mock():
    response = client.post("/api/v1/auth/register", json={"email": "new@ridermate.app", "password": "password123", "full_name": "New Rider", "username": "newrider"})
    assert response.status_code == 200
    assert "access_token" in response.json()
