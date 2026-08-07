from fastapi import APIRouter
router = APIRouter()

@router.get("/")
async def list_vehicles():
    return {"message": "Vehicles list — wire to Supabase"}

@router.post("/")
async def add_vehicle():
    return {"message": "Add vehicle — wire to Supabase"}
