import os
import uuid
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from app.models.models import UserModel
from app.core.deps import get_current_user
from app.core.config import settings

router = APIRouter()


@router.post("/upload")
async def upload_media(
    file: UploadFile = File(...),
    current_user: UserModel = Depends(get_current_user),
):
    """Upload photo/media file to Azure Blob Storage and return accessible public URL."""
    allowed_extensions = [".jpg", ".jpeg", ".png", ".webp", ".mp4"]
    ext = os.path.splitext(file.filename or "")[1].lower()
    if ext not in allowed_extensions:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid file extension {ext}. Allowed: {allowed_extensions}",
        )

    file_bytes = await file.read()
    if len(file_bytes) > 25 * 1024 * 1024:  # 25 MB max
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File size exceeds 25MB limit",
        )

    blob_name = f"{current_user.id}/{uuid.uuid4()}{ext}"
    azure_conn_str = os.environ.get("AZURE_STORAGE_CONNECTION_STRING", "")
    container_name = os.environ.get("AZURE_STORAGE_CONTAINER", "media")

    if azure_conn_str:
        try:
            from azure.storage.blob import BlobServiceClient, ContentSettings
            blob_service_client = BlobServiceClient.from_connection_string(azure_conn_str)
            container_client = blob_service_client.get_container_client(container_name)
            blob_client = container_client.get_blob_client(blob_name)

            content_type = file.content_type or "image/jpeg"
            blob_client.upload_blob(
                file_bytes,
                overwrite=True,
                content_settings=ContentSettings(content_type=content_type),
            )
            blob_url = blob_client.url
            return {"url": blob_url, "blob_name": blob_name, "size_bytes": len(file_bytes)}
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Azure Blob Storage upload failed: {str(e)}",
            )
    else:
        # Local mock storage for development/testing
        upload_dir = "uploads"
        os.makedirs(upload_dir, exist_ok=True)
        local_path = os.path.join(upload_dir, f"{uuid.uuid4()}{ext}")
        with open(local_path, "wb") as f:
            f.write(file_bytes)
        return {
            "url": f"/static/{os.path.basename(local_path)}",
            "blob_name": blob_name,
            "size_bytes": len(file_bytes),
        }
