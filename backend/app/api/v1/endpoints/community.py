from fastapi import APIRouter
router = APIRouter()

@router.get("/feed")
async def get_social_feed():
    return {"message": "Social feed — wire to Supabase"}

@router.get("/clubs")
async def get_clubs():
    return {"message": "Clubs list — wire to Supabase"}

@router.get("/leaderboard")
async def get_leaderboard():
    return {"message": "Leaderboard — wire to Supabase"}
