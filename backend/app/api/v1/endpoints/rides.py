from fastapi import APIRouter
router = APIRouter()

@router.get("/")
async def list_rides():
    return {"message": "Rides list — wire to Supabase PostgreSQL"}

@router.post("/")
async def create_ride():
    return {"message": "Start ride — wire to Supabase"}

@router.get("/{ride_id}")
async def get_ride(ride_id: str):
    return {"ride_id": ride_id, "message": "Get ride — wire to Supabase"}
