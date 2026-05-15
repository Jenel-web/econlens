"""
main.py — EconImpact PH FastAPI Backend
Entry point for the FastAPI application.
"""
import os
import pathlib
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

from app.api.news import router as news_router

# --- Load .env from project root ---
ROOT_DIR = pathlib.Path(__file__).resolve().parent.parent.parent
load_dotenv(ROOT_DIR / ".env")

# --- App Initialisation ---
app = FastAPI(
    title="EconImpact PH API",
    description="Backend for EconImpact PH — bridging news with economic impact for marginalized Filipinos.",
    version="0.1.0",
)

# --- CORS (allow Flutter app to call this API) ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # Tighten in production
    allow_credentials=False, # Must be False if allow_origins is '*'
    allow_methods=["*"],
    allow_headers=["*"],
)


# --- Routers ---
app.include_router(news_router, prefix="/api/v1", tags=["News"])

# ------------------------------------------------------------------
# Health / Root Endpoints
# ------------------------------------------------------------------

@app.get("/")
async def root():
    """Root endpoint — confirms the API is reachable."""
    return {"status": "online", "service": "EconImpact PH API"}


@app.get("/health")
async def health():
    """Health check endpoint for Flutter frontend and monitoring tools."""
    return {
        "status": "online",
        "version": "0.1.0",
        "environment": os.getenv("ENVIRONMENT", "development"),
    }
