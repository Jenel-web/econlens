from fastapi import APIRouter, HTTPException
from app.services.news_service import fetch_and_store_news
from app.services.ai_service import analyze_articles
from app.core.database import get_supabase_client

router = APIRouter()


@router.post("/fetch", summary="Manually trigger news ingestion + AI analysis pipeline")
async def manual_fetch_news():
    """
    Fetch articles from NewsAPI, filter them for economic relevance,
    deduplicate against Supabase, save new articles, and automatically
    trigger AI analysis for newly inserted records.
    """
    result = await fetch_and_store_news()

    if result.get("status") == "error":
        raise HTTPException(status_code=500, detail=result.get("message"))

    return result


@router.post("/analyze", summary="Analyze all articles without an AI analysis record")
async def analyze_pending_articles():
    """
    Find all articles in the `articles` table that do NOT yet have a
    corresponding record in `ai_analysis`, then run Gemini analysis on them.
    Useful for back-filling analysis on articles ingested before AI service existed.
    """
    supabase = get_supabase_client()

    # Get all article IDs
    all_articles_resp = supabase.table("articles").select("id").execute()
    all_ids = [row["id"] for row in (all_articles_resp.data or [])]

    if not all_ids:
        return {"message": "No articles found in the database.", "analyzed_count": 0}

    result = await analyze_articles(all_ids)
    return result
