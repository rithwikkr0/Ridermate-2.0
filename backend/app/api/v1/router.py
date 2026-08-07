from fastapi import APIRouter
from app.api.v1.endpoints import auth, profile, rides, vehicles, safety, community

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(profile.router, prefix="/profile", tags=["Profile"])
api_router.include_router(rides.router, prefix="/rides", tags=["Rides"])
api_router.include_router(vehicles.router, prefix="/vehicles", tags=["Vehicles"])
api_router.include_router(safety.router, prefix="/safety", tags=["Safety"])
api_router.include_router(community.router, prefix="/community", tags=["Community"])
