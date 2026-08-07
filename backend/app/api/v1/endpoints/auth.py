from fastapi import APIRouter
from pydantic import BaseModel, EmailStr

router = APIRouter()


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    username: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


@router.post("/register", response_model=TokenResponse)
async def register(body: RegisterRequest):
    """Register a new RiderMate account."""
    # TODO: Replace with Supabase Auth integration
    return TokenResponse(access_token="mock_access_token", refresh_token="mock_refresh_token")


@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest):
    """Authenticate and return JWT tokens."""
    # TODO: Replace with Supabase Auth integration
    return TokenResponse(access_token="mock_access_token", refresh_token="mock_refresh_token")


@router.post("/logout")
async def logout():
    """Invalidate the current session."""
    return {"message": "Logged out successfully"}
