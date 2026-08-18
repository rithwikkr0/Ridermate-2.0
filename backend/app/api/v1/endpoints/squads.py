from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from typing import List, Optional
import random
import string
from datetime import datetime

from app.db.session import get_db
from app.models.models import SquadModel, SquadMemberModel, GroupRideModel, UserModel
from app.core.deps import get_current_user, get_optional_user

router = APIRouter()


class CreateSquadRequest(BaseModel):
    name: str
    description: str = ""
    is_private: bool = False
    icon_url: str = ""


class JoinSquadRequest(BaseModel):
    invite_code: str


class CreateGroupRideRequest(BaseModel):
    title: str
    description: str = ""
    start_time: datetime
    start_location: str = ""
    destination: str = ""


def generate_invite_code(name: str) -> str:
    prefix = name[:4].upper().replace(" ", "")
    if len(prefix) < 2:
        prefix = "RM"
    rand_chars = "".join(random.choices(string.ascii_uppercase + string.digits, k=4))
    return f"RM-{prefix}-{rand_chars}"


@router.post("/", status_code=status.HTTP_201_CREATED)
def create_squad(
    body: CreateSquadRequest,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create a new squad and assign the creator as Admin."""
    code = generate_invite_code(body.name)

    # Ensure unique invite code
    while db.query(SquadModel).filter(SquadModel.invite_code == code).first() is not None:
        code = generate_invite_code(body.name)

    squad = SquadModel(
        name=body.name.strip(),
        description=body.description.strip(),
        creator_id=current_user.id,
        invite_code=code,
        is_private=body.is_private,
        icon_url=body.icon_url,
        members_count=1,
    )
    db.add(squad)
    db.flush()

    member = SquadMemberModel(
        squad_id=squad.id,
        user_id=current_user.id,
        role="admin",
    )
    db.add(member)
    db.commit()
    db.refresh(squad)

    return {
        "id": squad.id,
        "name": squad.name,
        "description": squad.description,
        "creator_id": squad.creator_id,
        "invite_code": squad.invite_code,
        "is_private": squad.is_private,
        "members_count": squad.members_count,
        "icon_url": squad.icon_url,
        "created_at": squad.created_at,
    }


@router.post("/{squad_id}/join")
def join_squad(
    squad_id: str,
    body: JoinSquadRequest,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Join squad via invite code."""
    squad = db.query(SquadModel).filter(SquadModel.id == squad_id).first()
    if not squad:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Squad not found")

    if squad.invite_code.upper() != body.invite_code.strip().upper():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid squad invite code")

    existing_member = db.query(SquadMemberModel).filter(
        SquadMemberModel.squad_id == squad_id,
        SquadMemberModel.user_id == current_user.id,
    ).first()
    if existing_member:
        return {"message": "Already a member of this squad", "role": existing_member.role}

    member = SquadMemberModel(squad_id=squad_id, user_id=current_user.id, role="member")
    db.add(member)
    squad.members_count += 1
    db.commit()

    return {"message": "Successfully joined squad", "squad_id": squad_id}


@router.get("/")
def list_squads(
    current_user: Optional[UserModel] = Depends(get_optional_user),
    db: Session = Depends(get_db),
):
    """List squads (public squads or squads the user belongs to)."""
    squads = db.query(SquadModel).filter(SquadModel.is_private == False).all()  # noqa: E712

    user_squad_ids = set()
    if current_user:
        user_squad_ids = {m.squad_id for m in db.query(SquadMemberModel).filter(SquadMemberModel.user_id == current_user.id).all()}

    return [
        {
            "id": s.id,
            "name": s.name,
            "description": s.description,
            "creator_id": s.creator_id,
            "invite_code": s.invite_code,
            "is_private": s.is_private,
            "members_count": s.members_count,
            "icon_url": s.icon_url,
            "is_member": s.id in user_squad_ids,
            "created_at": s.created_at,
        }
        for s in squads
    ]


@router.get("/{squad_id}")
def get_squad_details(
    squad_id: str,
    db: Session = Depends(get_db),
):
    """Get full squad roster and group rides."""
    squad = db.query(SquadModel).filter(SquadModel.id == squad_id).first()
    if not squad:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Squad not found")

    members = db.query(SquadMemberModel).filter(SquadMemberModel.squad_id == squad_id).all()
    rides = db.query(GroupRideModel).filter(GroupRideModel.squad_id == squad_id).order_by(GroupRideModel.start_time.asc()).all()

    member_details = []
    for m in members:
        user = db.query(UserModel).filter(UserModel.id == m.user_id).first()
        if user:
            member_details.append({
                "user_id": user.id,
                "full_name": user.full_name,
                "username": user.username,
                "photo_url": user.photo_url,
                "role": m.role,
                "joined_at": m.joined_at,
            })

    return {
        "id": squad.id,
        "name": squad.name,
        "description": squad.description,
        "creator_id": squad.creator_id,
        "invite_code": squad.invite_code,
        "is_private": squad.is_private,
        "members_count": squad.members_count,
        "icon_url": squad.icon_url,
        "members": member_details,
        "group_rides": [
            {
                "id": r.id,
                "title": r.title,
                "description": r.description,
                "start_time": r.start_time,
                "start_location": r.start_location,
                "destination": r.destination,
            }
            for r in rides
        ],
    }


@router.post("/{squad_id}/rides", status_code=status.HTTP_201_CREATED)
def schedule_group_ride(
    squad_id: str,
    body: CreateGroupRideRequest,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Schedule a group ride for the squad."""
    squad = db.query(SquadModel).filter(SquadModel.id == squad_id).first()
    if not squad:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Squad not found")

    ride = GroupRideModel(
        squad_id=squad_id,
        creator_id=current_user.id,
        title=body.title,
        description=body.description,
        start_time=body.start_time,
        start_location=body.start_location,
        destination=body.destination,
    )
    db.add(ride)
    db.commit()
    db.refresh(ride)

    return {"message": "Group ride scheduled", "ride_id": ride.id}
