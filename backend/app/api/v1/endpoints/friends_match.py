from fastapi import APIRouter, Depends
from pydantic import BaseModel, ConfigDict
from sqlalchemy.orm import Session
from typing import List

from app.db.session import get_db
from app.models.models import UserModel
from app.core.deps import get_current_user

router = APIRouter()


class MatchContactsRequest(BaseModel):
    phone_hashes: List[str]


class ContactMatchUserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    username: str
    full_name: str
    photo_url: str
    rider_level: str


class MatchContactsResponse(BaseModel):
    matches: List[ContactMatchUserResponse]
    total_matched: int


@router.post("/match-contacts", response_model=MatchContactsResponse)
def match_contacts(
    body: MatchContactsRequest,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Match hashed phone numbers against registered riders without exposing raw numbers."""
    cleaned_hashes = [h.strip().lower() for h in body.phone_hashes if h and len(h.strip()) == 64]

    if not cleaned_hashes:
        return MatchContactsResponse(matches=[], total_matched=0)

    matched_users = (
        db.query(UserModel)
        .filter(UserModel.phone_hash.in_(cleaned_hashes), UserModel.id != current_user.id)
        .all()
    )

    results = [
        ContactMatchUserResponse(
            id=u.id,
            username=u.username,
            full_name=u.full_name,
            photo_url=u.photo_url,
            rider_level=u.rider_level,
        )
        for u in matched_users
    ]

    return MatchContactsResponse(matches=results, total_matched=len(results))
