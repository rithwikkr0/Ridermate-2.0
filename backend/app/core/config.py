from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    # App
    APP_NAME: str = "RiderMate 2.0 API"
    API_VERSION: str = "2.0.0"
    DEBUG: bool = False

    # Security
    SECRET_KEY: str = "CHANGE_ME_IN_PRODUCTION_USE_256_BIT_RANDOM_KEY"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Supabase (Free Tier)
    SUPABASE_URL: str = ""
    SUPABASE_ANON_KEY: str = ""
    SUPABASE_SERVICE_KEY: str = ""

    # Database
    DATABASE_URL: str = ""

    # CORS
    ALLOWED_ORIGINS: List[str] = ["*"]

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
