import os
import uuid
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Query
from app.models.models import UserModel
from app.core.deps import get_current_user
from app.core.config import settings

router = APIRouter()


def _generate_blob_sas_url(azure_conn_str: str, container_name: str, blob_name: str, expiry_hours: int = 2) -> str:
    """Generate a secure, short-lived SAS read URL for private blob storage."""
    pairs = dict(item.split("=", 1) for item in azure_conn_str.split(";") if "=" in item)
    account_name = pairs.get("AccountName")
    account_key = pairs.get("AccountKey")
    if not account_name or not account_key:
        return ""
    from azure.storage.blob import generate_blob_sas, BlobSasPermissions
    sas_token = generate_blob_sas(
        account_name=account_name,
        container_name=container_name,
        blob_name=blob_name,
        account_key=account_key,
        permission=BlobSasPermissions(read=True),
        expiry=datetime.now(timezone.utc) + timedelta(hours=expiry_hours),
    )
    blob_endpoint = pairs.get("BlobEndpoint", f"https://{account_name}.blob.core.windows.net/")
    if not blob_endpoint.endswith("/"):
        blob_endpoint += "/"
    return f"{blob_endpoint}{container_name}/{blob_name}?{sas_token}"


@router.post("/upload")
async def upload_media(
    file: UploadFile = File(...),
    current_user: UserModel = Depends(get_current_user),
):
    """Upload photo/media file to private Azure Blob Storage and return secure signed SAS URL."""
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
            sas_url = _generate_blob_sas_url(azure_conn_str, container_name, blob_name, expiry_hours=24)
            return {
                "url": sas_url or blob_client.url,
                "blob_name": blob_name,
                "size_bytes": len(file_bytes),
                "is_secured_sas": bool(sas_url),
            }
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Azure Blob Storage upload failed: {str(e)}",
            )
    else:
        # Local fallback storage for development/testing
        upload_dir = "uploads"
        os.makedirs(upload_dir, exist_ok=True)
        local_path = os.path.join(upload_dir, f"{uuid.uuid4()}{ext}")
        with open(local_path, "wb") as f:
            f.write(file_bytes)
        return {
            "url": f"/static/{os.path.basename(local_path)}",
            "blob_name": blob_name,
            "size_bytes": len(file_bytes),
            "is_secured_sas": False,
        }


@router.get("/sas-url")
async def get_media_sas_url(
    blob_name: str = Query(..., description="The blob path in storage"),
    current_user: UserModel = Depends(get_current_user),
):
    """Generate a fresh short-lived SAS read URL for an existing private blob."""
    azure_conn_str = os.environ.get("AZURE_STORAGE_CONNECTION_STRING", "")
    container_name = os.environ.get("AZURE_STORAGE_CONTAINER", "media")
    if not azure_conn_str:
        return {"url": f"/static/{blob_name}", "blob_name": blob_name}

    sas_url = _generate_blob_sas_url(azure_conn_str, container_name, blob_name, expiry_hours=2)
    if not sas_url:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate secure SAS URL",
        )
    return {"url": sas_url, "blob_name": blob_name, "expires_in_hours": 2}

