from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import Session
from typing import Optional

from app.db.session import get_db
from app.models.models import UserModel, ProfileModel
from app.core.security import hash_password, verify_password, create_access_token
from app.core.deps import get_current_user

router = APIRouter()


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6)
    full_name: str
    username: str
    phone: Optional[str] = ""


class LoginRequest(BaseModel):
    email: str  # Can be email or username
    password: str


class UserResponse(BaseModel):
    id: str
    email: str
    username: str
    full_name: str
    phone: str
    photo_url: str
    bio: str
    rider_level: str
    xp: int
    distance_km: float
    total_rides: int

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(body: RegisterRequest, db: Session = Depends(get_db)):
    """Register a new RiderMate rider account with bcrypt password hashing."""
    normalized_email = body.email.strip().lower()
    normalized_username = body.username.strip().lower()

    # Check for existing email or username
    existing_user = db.query(UserModel).filter(
        (UserModel.email == normalized_email) | (UserModel.username == normalized_username)
    ).first()
    if existing_user:
        if existing_user.email == normalized_email:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already taken")

    # Hash password and create user
    user = UserModel(
        email=normalized_email,
        username=normalized_username,
        full_name=body.full_name.strip(),
        phone=body.phone or "",
        password_hash=hash_password(body.password),
    )
    db.add(user)
    db.flush()

    # Create associated default profile
    profile = ProfileModel(
        user_id=user.id,
        avatar_url="",
        preferred_units="metric",
        preferred_theme="dark",
        language="en",
    )
    db.add(profile)
    db.commit()
    db.refresh(user)

    token = create_access_token(subject=user.id)
    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=UserResponse.model_validate(user),
    )


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest, db: Session = Depends(get_db)):
    """Authenticate rider via email/username and password, returning JWT access token."""
    login_id = body.email.strip().lower()

    user = db.query(UserModel).filter(
        (UserModel.email == login_id) | (UserModel.username == login_id)
    ).first()

    if not user or not verify_password(body.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email/username or password",
        )

    token = create_access_token(subject=user.id)
    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=UserResponse.model_validate(user),
    )


@router.get("/me", response_model=UserResponse)
def get_me(current_user: UserModel = Depends(get_current_user)):
    """Return currently authenticated rider identity."""
    return UserResponse.model_validate(current_user)
