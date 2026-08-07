from fastapi import APIRouter
router = APIRouter()

@router.post("/sos")
async def trigger_sos():
    return {"message": "SOS triggered — wire to emergency dispatch service"}

@router.get("/events")
async def get_safety_events():
    return {"message": "Safety events — wire to Supabase"}
