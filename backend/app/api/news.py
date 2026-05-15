from fastapi import APIRouter, HTTPException
from app.services.news_service import fetch_and_store_news

router = APIRouter()

@router.post("/fetch", summary="Manually trigger news ingestion pipeline")
async def manual_fetch_news():
    """
    Manually fetch articles from NewsAPI, filter them for economic relevance,
    deduplicate against the Supabase database, and save new articles.
    """
    result = await fetch_and_store_news()
    
    if result.get("status") == "error":
        raise HTTPException(status_code=500, detail=result.get("message"))
        
    return result
