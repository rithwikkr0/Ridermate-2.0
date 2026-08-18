from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from typing import List, Optional

from app.db.session import get_db
from app.models.models import UserModel, FriendshipModel, FriendRequestModel, BlockedUserModel
from app.core.deps import get_current_user

router = APIRouter()


class FriendRequestPayload(BaseModel):
    receiver_id: str


@router.post("/request", status_code=status.HTTP_201_CREATED)
def send_friend_request(
    body: FriendRequestPayload,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Send a friend request to another rider."""
    if body.receiver_id == current_user.id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot send friend request to yourself")

    receiver = db.query(UserModel).filter(UserModel.id == body.receiver_id).first()
    if not receiver:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Rider not found")

    # Check if blocked
    is_blocked = db.query(BlockedUserModel).filter(
        ((BlockedUserModel.user_id == current_user.id) & (BlockedUserModel.blocked_user_id == body.receiver_id)) |
        ((BlockedUserModel.user_id == body.receiver_id) & (BlockedUserModel.blocked_user_id == current_user.id))
    ).first()
    if is_blocked:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot interact with blocked user")

    # Check if already friends
    existing_friend = db.query(FriendshipModel).filter(
        FriendshipModel.user_id == current_user.id,
        FriendshipModel.friend_id == body.receiver_id,
    ).first()
    if existing_friend:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Already friends with this rider")

    # Check existing pending request
    existing_req = db.query(FriendRequestModel).filter(
        FriendRequestModel.sender_id == current_user.id,
        FriendRequestModel.receiver_id == body.receiver_id,
        FriendRequestModel.status == "pending",
    ).first()
    if existing_req:
        return {"message": "Friend request already sent", "request_id": existing_req.id}

    req = FriendRequestModel(sender_id=current_user.id, receiver_id=body.receiver_id, status="pending")
    db.add(req)
    db.commit()
    db.refresh(req)
    return {"message": "Friend request sent successfully", "request_id": req.id}


@router.post("/{request_id}/accept")
def accept_friend_request(
    request_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Accept incoming friend request and establish friendship."""
    req = db.query(FriendRequestModel).filter(
        FriendRequestModel.id == request_id,
        FriendRequestModel.receiver_id == current_user.id,
        FriendRequestModel.status == "pending",
    ).first()
    if not req:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pending friend request not found")

    req.status = "accepted"

    # Create bidirectional friendship
    f1 = FriendshipModel(user_id=req.sender_id, friend_id=req.receiver_id)
    f2 = FriendshipModel(user_id=req.receiver_id, friend_id=req.sender_id)
    db.add_all([f1, f2])
    db.commit()

    return {"message": "Friend request accepted"}


@router.post("/{request_id}/reject")
def reject_friend_request(
    request_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Reject incoming friend request."""
    req = db.query(FriendRequestModel).filter(
        FriendRequestModel.id == request_id,
        FriendRequestModel.receiver_id == current_user.id,
    ).first()
    if not req:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Friend request not found")

    req.status = "rejected"
    db.commit()
    return {"message": "Friend request rejected"}


@router.get("/")
def get_friends(
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Fetch friends and pending incoming friend requests for the authenticated user."""
    friendships = db.query(FriendshipModel).filter(FriendshipModel.user_id == current_user.id).all()
    friend_ids = [f.friend_id for f in friendships]

    friends = db.query(UserModel).filter(UserModel.id.in_(friend_ids)).all() if friend_ids else []

    incoming_requests = db.query(FriendRequestModel).filter(
        FriendRequestModel.receiver_id == current_user.id,
        FriendRequestModel.status == "pending",
    ).all()

    requests_data = []
    for r in incoming_requests:
        sender = db.query(UserModel).filter(UserModel.id == r.sender_id).first()
        if sender:
            requests_data.append({
                "request_id": r.id,
                "sender_id": sender.id,
                "sender_name": sender.full_name,
                "sender_avatar": sender.photo_url,
                "created_at": r.created_at,
            })

    return {
        "friends": [
            {
                "id": f.id,
                "username": f.username,
                "full_name": f.full_name,
                "photo_url": f.photo_url,
                "rider_level": f.rider_level,
                "distance_km": f.distance_km,
            }
            for f in friends
        ],
        "incoming_requests": requests_data,
    }


@router.post("/block/{user_id}")
def block_user(
    user_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Block a rider."""
    existing = db.query(BlockedUserModel).filter(
        BlockedUserModel.user_id == current_user.id,
        BlockedUserModel.blocked_user_id == user_id,
    ).first()
    if not existing:
        block = BlockedUserModel(user_id=current_user.id, blocked_user_id=user_id)
        db.add(block)

        # Remove any existing friendships
        db.query(FriendshipModel).filter(
            ((FriendshipModel.user_id == current_user.id) & (FriendshipModel.friend_id == user_id)) |
            ((FriendshipModel.user_id == user_id) & (FriendshipModel.friend_id == current_user.id))
        ).delete(synchronize_session=False)

        db.commit()
    return {"message": "User blocked"}


@router.delete("/block/{user_id}")
def unblock_user(
    user_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Unblock a rider."""
    db.query(BlockedUserModel).filter(
        BlockedUserModel.user_id == current_user.id,
        BlockedUserModel.blocked_user_id == user_id,
    ).delete()
    db.commit()
    return {"message": "User unblocked"}
