import asyncio
import os
import sys

# Setup environment to run from outside the FastAPI context
sys.path.append("C:/Users/Administrator/Downloads/LearningOOP/newApp/backend")
from app.core.database import get_supabase_client
from app.services.ai_service import analyze_articles

async def debug_ai_failures():
    supabase = get_supabase_client()
    
    # Get all articles
    all_articles_resp = supabase.table("articles").select("id, raw_content").execute()
    all_articles = all_articles_resp.data or []
    
    # Get all analyzed articles
    existing_analysis = supabase.table("ai_analysis").select("article_id").execute()
    already_analyzed_ids = {row["article_id"] for row in (existing_analysis.data or [])}
    
    pending_articles = [a for a in all_articles if a["id"] not in already_analyzed_ids]
    
    if not pending_articles:
        print("No pending articles found.")
        return
        
    print(f"Found {len(pending_articles)} pending articles.")
    
    # Check how many have short raw_content
    insufficient = [a for a in pending_articles if not (a.get("raw_content") or "").strip() or len((a.get("raw_content") or "").strip()) < 10]
    print(f"Of those, {len(insufficient)} have insufficient raw_content (< 10 chars).")
    
    valid_pending = [a for a in pending_articles if a not in insufficient]
    print(f"Valid pending articles for analysis: {len(valid_pending)}")
    
    if valid_pending:
        # Try analyzing just the first one directly
        print(f"Attempting to analyze article ID: {valid_pending[0]['id']}")
        try:
            result = await analyze_articles([valid_pending[0]["id"]])
            print("Result:", result)
        except Exception as e:
            print("Exception during analysis:", e)

if __name__ == "__main__":
    asyncio.run(debug_ai_failures())
