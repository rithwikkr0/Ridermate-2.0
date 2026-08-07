from fastapi import APIRouter
router = APIRouter()

@router.get("/me")
async def get_profile():
    return {"message": "Profile endpoint — wire to Supabase"}

@router.patch("/me")
async def update_profile():
    return {"message": "Update profile — wire to Supabase"}
