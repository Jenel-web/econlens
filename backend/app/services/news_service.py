import httpx
from datetime import datetime, timezone
import uuid
import logging
from typing import List, Dict, Any

from app.core.config import settings
from app.core.database import get_supabase_client
from app.models.article import ArticleSchema
from app.services import ai_service

logger = logging.getLogger(__name__)

NEWSAPI_URL = "https://newsapi.org/v2/everything"
ECONOMIC_KEYWORDS = [
    "inflation", "peso", "bsp", "economy", "fuel", "agriculture",
    "interest rate", "gdp", "economic", "market", "stocks", "trade"
]

async def fetch_news_from_api() -> List[Dict[str, Any]]:
    """Fetch articles from NewsAPI."""
    if not settings.NEWSAPI_KEY:
        raise ValueError("NEWSAPI_KEY is not set.")

    query = "(Philippines OR \"Metro Manila\" OR BSP) AND (inflation OR \"fuel price\" OR agriculture OR \"interest rate\" OR economy OR \"peso\")"
    params = {
        "q": query,
        "language": "en",
        "sortBy": "publishedAt",
        "apiKey": settings.NEWSAPI_KEY,
        "pageSize": 100
    }

    async with httpx.AsyncClient() as client:
        response = await client.get(NEWSAPI_URL, params=params)
        response.raise_for_status()
        data = response.json()
        return data.get("articles", [])

def filter_economic_news(articles: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Filter articles to ensure they are relevant."""
    filtered = []
    for article in articles:
        # Check if title or description exists and contains any economic keyword
        title = (article.get("title") or "").lower()
        description = (article.get("description") or "").lower()
        content = title + " " + description
        
        if any(keyword in content for keyword in ECONOMIC_KEYWORDS):
            filtered.append(article)
            
    return filtered

async def fetch_and_store_news() -> dict:
    """Main pipeline to fetch, filter, deduplicate, and persist news."""
    # 1. Fetch
    try:
        raw_articles = await fetch_news_from_api()
    except Exception as e:
        logger.error(f"Error fetching news from API: {e}")
        return {"status": "error", "message": f"NewsAPI fetch failed: {str(e)}"}

    # 2. Filter
    relevant_articles = filter_economic_news(raw_articles)
    if not relevant_articles:
        return {"status": "success", "message": "No relevant economic news found.", "inserted_count": 0}

    supabase = get_supabase_client()
    inserted_count = 0
    new_article_ids: List[str] = []  # Track IDs of newly inserted articles

    for article_data in relevant_articles:
        source_url = article_data.get("url")
        if not source_url:
            continue

        # 3. Deduplication: Check if article already exists
        existing = supabase.table("articles").select("id").eq("source_url", source_url).execute()
        if existing.data:
            # Article already exists, skip
            continue

        # Parse published_at
        pub_str = article_data.get("publishedAt")
        if pub_str:
            try:
                published_at = datetime.fromisoformat(pub_str.replace("Z", "+00:00"))
            except ValueError:
                published_at = datetime.now(timezone.utc)
        else:
            published_at = datetime.now(timezone.utc)

        # 4. Persistence: Prepare for insertion
        new_article = ArticleSchema(
            id=uuid.uuid4(),
            title=article_data.get("title", "No Title"),
            source=article_data.get("source", {}).get("name", "Unknown"),
            source_url=source_url,
            published_at=published_at,
            raw_content=article_data.get("content") or article_data.get("description")
        )

        # Convert to dict for Supabase, handle uuid to str
        insert_data = new_article.model_dump()
        insert_data["id"] = str(insert_data["id"])
        insert_data["published_at"] = insert_data["published_at"].isoformat()

        try:
            supabase.table("articles").insert(insert_data).execute()
            new_article_ids.append(insert_data["id"])
            inserted_count += 1
        except Exception as e:
            logger.error(f"Error inserting article {source_url}: {e}")

    # 5. AI Analysis — analyze all newly inserted articles
    analysis_result = {"analyzed_count": 0, "failed_count": 0}
    if new_article_ids:
        logger.info(f"Triggering AI analysis for {len(new_article_ids)} new article(s)...")
        analysis_result = await ai_service.analyze_articles(new_article_ids)

    return {
        "status": "success",
        "message": (
            f"Pipeline completed. "
            f"Fetched {len(raw_articles)}, "
            f"Filtered {len(relevant_articles)}, "
            f"Inserted {inserted_count}, "
            f"Analyzed {analysis_result.get('analyzed_count', 0)}."
        ),
        "inserted_count": inserted_count,
        "analyzed_count": analysis_result.get("analyzed_count", 0),
        "analysis_failed_count": analysis_result.get("failed_count", 0),
    }
