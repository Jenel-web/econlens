import asyncio
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

    # FIX: Loop through IDs individually with an asyncio.sleep delay to prevent 429 blocks
    total_analyzed = 0
    total_failed = 0
    
    for article_id in all_ids:
        single_result = await analyze_articles([article_id])
        total_analyzed += single_result.get("analyzed_count", 0)
        total_failed += single_result.get("failed_count", 0)
        
        # Pause for 4 seconds between requests to clear the Free Tier RPM limit
        await asyncio.sleep(4)

    return {
        "status": "success",
        "message": f"Analysis complete with rate-limiting. Total items processed: {len(all_ids)}",
        "analyzed_count": total_analyzed,
        "failed_count": total_failed
    }
