from fastapi import APIRouter
from app.api.v1.endpoints import auth, community, friends, squads, rides, safety, media

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(community.router, prefix="/community", tags=["Community"])
api_router.include_router(friends.router, prefix="/friends", tags=["Friends"])
api_router.include_router(squads.router, prefix="/squads", tags=["Squads"])
api_router.include_router(rides.router, prefix="/rides", tags=["Rides"])
api_router.include_router(safety.router, prefix="/safety", tags=["Safety"])
api_router.include_router(media.router, prefix="/media", tags=["Media"])
