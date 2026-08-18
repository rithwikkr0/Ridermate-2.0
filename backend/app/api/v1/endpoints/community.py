from fastapi import APIRouter, Depends, HTTPException, status, Header
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import desc
from typing import List, Optional
from datetime import datetime, timezone, timedelta
import json

from app.db.session import get_db
from app.models.models import (
    PostModel, PostLikeModel, PostCommentModel, SavedPostModel,
    ReportModel, StoryModel, UserModel, IdempotencyRecordModel, BlockedUserModel
)
from app.core.deps import get_current_user, get_optional_user

router = APIRouter()


class CreatePostRequest(BaseModel):
    type: str = "text"  # text, photo, ride, memory
    caption: str = ""
    media_url: str = ""
    ride_id: Optional[str] = None
    memory_id: Optional[str] = None
    privacy: str = "public"  # public, friends, private


class CommentRequest(BaseModel):
    text: str
    parent_comment_id: Optional[str] = None


class ReportRequest(BaseModel):
    item_type: str
    item_id: str
    reason: str
    details: str = ""


class StoryRequest(BaseModel):
    media_url: str
    caption: str = ""


class PostResponse(BaseModel):
    id: str
    user_id: str
    author_name: str
    author_avatar: str
    type: str
    caption: str
    media_url: str
    ride_id: Optional[str] = None
    memory_id: Optional[str] = None
    privacy: str
    likes_count: int
    comments_count: int
    is_liked: bool = False
    is_saved: bool = False
    created_at: datetime


class CommentResponse(BaseModel):
    id: str
    post_id: str
    user_id: str
    author_name: str
    author_avatar: str
    text: str
    parent_comment_id: Optional[str] = None
    created_at: datetime


@router.post("/posts", response_model=PostResponse, status_code=status.HTTP_201_CREATED)
def create_post(
    body: CreatePostRequest,
    x_idempotency_key: Optional[str] = Header(None),
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Creates a community post with server-side idempotency protection."""
    # Check idempotency record
    if x_idempotency_key:
        existing_record = db.query(IdempotencyRecordModel).filter(
            IdempotencyRecordModel.idempotency_key == x_idempotency_key,
            IdempotencyRecordModel.user_id == current_user.id,
        ).first()
        if existing_record:
            cached_data = json.loads(existing_record.response_json)
            return PostResponse(**cached_data)

    post = PostModel(
        user_id=current_user.id,
        type=body.type,
        caption=body.caption,
        media_url=body.media_url,
        ride_id=body.ride_id,
        memory_id=body.memory_id,
        privacy=body.privacy,
    )
    db.add(post)
    db.commit()
    db.refresh(post)

    resp = PostResponse(
        id=post.id,
        user_id=post.user_id,
        author_name=current_user.full_name,
        author_avatar=current_user.photo_url,
        type=post.type,
        caption=post.caption,
        media_url=post.media_url,
        ride_id=post.ride_id,
        memory_id=post.memory_id,
        privacy=post.privacy,
        likes_count=0,
        comments_count=0,
        is_liked=False,
        is_saved=False,
        created_at=post.created_at,
    )

    if x_idempotency_key:
        idempotency_rec = IdempotencyRecordModel(
            idempotency_key=x_idempotency_key,
            user_id=current_user.id,
            endpoint="/api/v1/community/posts",
            status_code=201,
            response_json=json.dumps(resp.model_dump(), default=str),
        )
        db.add(idempotency_rec)
        db.commit()

    return resp


@router.get("/feed", response_model=List[PostResponse])
def get_feed(
    limit: int = 50,
    offset: int = 0,
    current_user: Optional[UserModel] = Depends(get_optional_user),
    db: Session = Depends(get_db),
):
    """Fetch social feed with privacy rules and blocked-user filtering."""
    query = db.query(PostModel)

    if current_user:
        # Filter out blocked users
        blocked_ids = [b.blocked_user_id for b in db.query(BlockedUserModel).filter(BlockedUserModel.user_id == current_user.id).all()]
        if blocked_ids:
            query = query.filter(~PostModel.user_id.in_(blocked_ids))

        # Show public posts + user's own posts
        query = query.filter((PostModel.privacy == "public") | (PostModel.user_id == current_user.id))
    else:
        query = query.filter(PostModel.privacy == "public")

    posts = query.order_by(desc(PostModel.created_at)).offset(offset).limit(limit).all()

    # Pre-fetch user's likes and saves
    user_liked_post_ids = set()
    user_saved_post_ids = set()
    if current_user:
        user_liked_post_ids = {l.post_id for l in db.query(PostLikeModel).filter(PostLikeModel.user_id == current_user.id).all()}
        user_saved_post_ids = {s.post_id for s in db.query(SavedPostModel).filter(SavedPostModel.user_id == current_user.id).all()}

    results = []
    for p in posts:
        author = db.query(UserModel).filter(UserModel.id == p.user_id).first()
        author_name = author.full_name if author else "Rider"
        author_avatar = author.photo_url if author else ""
        results.append(
            PostResponse(
                id=p.id,
                user_id=p.user_id,
                author_name=author_name,
                author_avatar=author_avatar,
                type=p.type,
                caption=p.caption,
                media_url=p.media_url,
                ride_id=p.ride_id,
                memory_id=p.memory_id,
                privacy=p.privacy,
                likes_count=p.likes_count,
                comments_count=p.comments_count,
                is_liked=p.id in user_liked_post_ids,
                is_saved=p.id in user_saved_post_ids,
                created_at=p.created_at,
            )
        )
    return results


@router.get("/posts/{post_id}", response_model=PostResponse)
def get_post(
    post_id: str,
    current_user: Optional[UserModel] = Depends(get_optional_user),
    db: Session = Depends(get_db),
):
    """Fetch single post by ID."""
    post = db.query(PostModel).filter(PostModel.id == post_id).first()
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")

    author = db.query(UserModel).filter(UserModel.id == post.user_id).first()
    is_liked = False
    is_saved = False
    if current_user:
        is_liked = db.query(PostLikeModel).filter(PostLikeModel.post_id == post_id, PostLikeModel.user_id == current_user.id).first() is not None
        is_saved = db.query(SavedPostModel).filter(SavedPostModel.post_id == post_id, SavedPostModel.user_id == current_user.id).first() is not None

    return PostResponse(
        id=post.id,
        user_id=post.user_id,
        author_name=author.full_name if author else "Rider",
        author_avatar=author.photo_url if author else "",
        type=post.type,
        caption=post.caption,
        media_url=post.media_url,
        ride_id=post.ride_id,
        memory_id=post.memory_id,
        privacy=post.privacy,
        likes_count=post.likes_count,
        comments_count=post.comments_count,
        is_liked=is_liked,
        is_saved=is_saved,
        created_at=post.created_at,
    )


@router.delete("/posts/{post_id}")
def delete_post(
    post_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Delete a post (author only)."""
    post = db.query(PostModel).filter(PostModel.id == post_id).first()
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")
    if post.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to delete this post")

    db.delete(post)
    db.commit()
    return {"message": "Post deleted successfully"}


@router.post("/posts/{post_id}/like")
def like_post(
    post_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Like a post (idempotent)."""
    post = db.query(PostModel).filter(PostModel.id == post_id).first()
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")

    existing_like = db.query(PostLikeModel).filter(
        PostLikeModel.post_id == post_id,
        PostLikeModel.user_id == current_user.id,
    ).first()

    if not existing_like:
        like = PostLikeModel(post_id=post_id, user_id=current_user.id)
        db.add(like)
        post.likes_count += 1
        db.commit()

    return {"message": "Post liked", "likes_count": post.likes_count}


@router.delete("/posts/{post_id}/like")
def unlike_post(
    post_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Unlike a post (idempotent)."""
    post = db.query(PostModel).filter(PostModel.id == post_id).first()
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")

    existing_like = db.query(PostLikeModel).filter(
        PostLikeModel.post_id == post_id,
        PostLikeModel.user_id == current_user.id,
    ).first()

    if existing_like:
        db.delete(existing_like)
        post.likes_count = max(0, post.likes_count - 1)
        db.commit()

    return {"message": "Post unliked", "likes_count": post.likes_count}


@router.post("/posts/{post_id}/comments", response_model=CommentResponse, status_code=status.HTTP_201_CREATED)
def add_comment(
    post_id: str,
    body: CommentRequest,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Add a comment to a post."""
    post = db.query(PostModel).filter(PostModel.id == post_id).first()
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")

    comment = PostCommentModel(
        post_id=post_id,
        user_id=current_user.id,
        author_name=current_user.full_name,
        author_avatar=current_user.photo_url,
        text=body.text.strip(),
        parent_comment_id=body.parent_comment_id,
    )
    db.add(comment)
    post.comments_count += 1
    db.commit()
    db.refresh(comment)

    return CommentResponse(
        id=comment.id,
        post_id=comment.post_id,
        user_id=comment.user_id,
        author_name=comment.author_name,
        author_avatar=comment.author_avatar,
        text=comment.text,
        parent_comment_id=comment.parent_comment_id,
        created_at=comment.created_at,
    )


@router.get("/posts/{post_id}/comments", response_model=List[CommentResponse])
def get_comments(post_id: str, db: Session = Depends(get_db)):
    """Fetch all comments for a post."""
    comments = db.query(PostCommentModel).filter(
        PostCommentModel.post_id == post_id
    ).order_by(PostCommentModel.created_at.asc()).all()

    return [
        CommentResponse(
            id=c.id,
            post_id=c.post_id,
            user_id=c.user_id,
            author_name=c.author_name,
            author_avatar=c.author_avatar,
            text=c.text,
            parent_comment_id=c.parent_comment_id,
            created_at=c.created_at,
        )
        for c in comments
    ]


@router.post("/posts/{post_id}/save")
def save_post(
    post_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Bookmark / save a post."""
    existing_save = db.query(SavedPostModel).filter(
        SavedPostModel.user_id == current_user.id,
        SavedPostModel.post_id == post_id,
    ).first()
    if not existing_save:
        save = SavedPostModel(user_id=current_user.id, post_id=post_id)
        db.add(save)
        db.commit()
    return {"message": "Post saved"}


@router.delete("/posts/{post_id}/save")
def unsave_post(
    post_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Remove bookmark / save from a post."""
    existing_save = db.query(SavedPostModel).filter(
        SavedPostModel.user_id == current_user.id,
        SavedPostModel.post_id == post_id,
    ).first()
    if existing_save:
        db.delete(existing_save)
        db.commit()
    return {"message": "Post removed from saved"}


@router.post("/report")
def report_content(
    body: ReportRequest,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Report inappropriate content or abusive user for moderation review."""
    report = ReportModel(
        reporter_id=current_user.id,
        item_type=body.item_type,
        item_id=body.item_id,
        reason=body.reason,
        details=body.details,
    )
    db.add(report)
    db.commit()
    return {"message": "Report submitted for review"}


@router.post("/stories", status_code=status.HTTP_201_CREATED)
def create_story(
    body: StoryRequest,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create a 24-hour ephemeral moment/story."""
    now = datetime.now(timezone.utc)
    story = StoryModel(
        user_id=current_user.id,
        author_name=current_user.full_name,
        author_avatar=current_user.photo_url,
        media_url=body.media_url,
        caption=body.caption,
        created_at=now,
        expires_at=now + timedelta(hours=24),
    )
    db.add(story)
    db.commit()
    return {"message": "Story posted successfully", "expires_at": story.expires_at}


@router.get("/stories")
def get_active_stories(db: Session = Depends(get_db)):
    """Fetch active stories that have not expired."""
    now = datetime.now(timezone.utc)
    stories = db.query(StoryModel).filter(
        StoryModel.expires_at > now
    ).order_by(desc(StoryModel.created_at)).all()

    return [
        {
            "id": s.id,
            "user_id": s.user_id,
            "author_name": s.author_name,
            "author_avatar": s.author_avatar,
            "media_url": s.media_url,
            "caption": s.caption,
            "created_at": s.created_at,
            "expires_at": s.expires_at,
        }
        for s in stories
    ]
