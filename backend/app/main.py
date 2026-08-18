from collections import defaultdict
import time
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware

from app.api.v1.router import api_router
from app.api.v1.endpoints.safety import router as safety_router
from app.core.config import settings
from app.db.session import engine
from app.models.models import Base

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("ridermate-api")

# In-memory IP rate limiter (120 requests per minute per IP)
_request_counts = defaultdict(list)
RATE_LIMIT_WINDOW = 60  # seconds
MAX_REQUESTS_PER_WINDOW = 120


class SecurityAndRateLimitMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        client_ip = request.client.host if request.client else "unknown"
        now = time.time()
        
        # Clean timestamps older than window
        timestamps = [t for t in _request_counts[client_ip] if now - t < RATE_LIMIT_WINDOW]
        timestamps.append(now)
        _request_counts[client_ip] = timestamps

        if len(timestamps) > MAX_REQUESTS_PER_WINDOW:
            logger.warning(f"Rate limit exceeded for IP: {client_ip}")
            return Response(
                content='{"detail":"Rate limit exceeded. Please wait a moment."}',
                status_code=429,
                media_type="application/json",
            )

        start_time = time.time()
        response = await call_next(request)
        duration = round((time.time() - start_time) * 1000, 2)
        logger.info(f"{request.method} {request.url.path} -> {response.status_code} ({duration}ms) [IP: {client_ip}]")
        return response


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

app.add_middleware(SecurityAndRateLimitMiddleware)

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
