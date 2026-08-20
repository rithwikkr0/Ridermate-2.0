from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    # App
    APP_NAME: str = "RiderMate 2.0 API"
    API_VERSION: str = "2.0.0"
    DEBUG: bool = False

    # Security
    SECRET_KEY: str = "CHANGE_ME_IN_PRODUCTION_USE_256_BIT_RANDOM_KEY"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Database (PostgreSQL / SQLite fallback)
    DATABASE_URL: str = ""

    # Azure Blob Storage
    AZURE_STORAGE_CONNECTION_STRING: str = ""
    AZURE_STORAGE_CONTAINER_NAME: str = "media"

    # Google OAuth
    GOOGLE_CLIENT_ID: str = "568128073681-39l950in9qgk3iqj0qn775qn9b7uni1v.apps.googleusercontent.com"

    # CORS
    ALLOWED_ORIGINS: List[str] = ["*"]


settings = Settings()

