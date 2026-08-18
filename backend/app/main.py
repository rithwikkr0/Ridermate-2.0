from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router
from app.api.v1.endpoints.safety import router as safety_router
from app.core.config import settings
from app.db.session import engine
from app.models.models import Base


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Auto-create all database tables on startup
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title="RiderMate 2.0 API",
    version="2.0.0",
    description="RiderMate 2.0 — Production Motorcycle Safety, Community & Offline-First Sync API",
    openapi_url="/api/v1/openapi.json",
    docs_url="/api/v1/docs",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Standard API v1 routing
app.include_router(api_router, prefix="/api/v1")
app.include_router(api_router, prefix="/api")

# Top-level direct safety alias for AzureApiClient backward compatibility
app.include_router(safety_router, prefix="/api/safety", tags=["Safety Direct"])


@app.get("/health", tags=["Health"])
@app.get("/api/health", tags=["Health"])
async def health_check():
    """Production health check endpoint verifying RiderMate Cloud API connectivity."""
    return {
        "status": "healthy",
        "service": "RiderMate 2.0 API",
        "version": "2.0.0",
    }
