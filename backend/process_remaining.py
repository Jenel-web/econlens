    import asyncio
    import os
    import sys
    import time
    import pathlib
    from dotenv import load_dotenv

    # Load .env from project root
    ROOT_DIR = pathlib.Path(__file__).resolve().parent.parent
    load_dotenv(ROOT_DIR / ".env")

    sys.path.append(str(ROOT_DIR / "backend"))
    from app.core.database import get_supabase_client
    from app.services.ai_service import analyze_articles

    async def process_remaining():
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
        
        # Filter out bad content
        valid_pending = [a for a in pending_articles if (a.get("raw_content") or "").strip() and len((a.get("raw_content") or "").strip()) >= 10]
        print(f"Valid pending articles for analysis: {len(valid_pending)}")
        
        # Process one by one to handle rate limits explicitly
        success_count = 0
        for i, article in enumerate(valid_pending):
            print(f"Processing {i+1}/{len(valid_pending)}: {article['id']}")
            retries = 3
            while retries > 0:
                try:
                    # analyze_articles takes a list of IDs
                    result = await analyze_articles([article["id"]])
                    if result.get("failed_count", 0) > 0:
                        # Check if we should retry
                        print(f"Failed to analyze {article['id']}, checking if we can retry...")
                        # The exception is caught inside analyze_articles and we don't get the error code directly,
                        # but if it fails, we will assume it's a rate limit and wait.
                        print("Waiting 45 seconds due to potential rate limit...")
                        await asyncio.sleep(45)
                        retries -= 1
                    else:
                        print(f"Success for {article['id']}")
                        success_count += 1
                        # Base delay to prevent hitting RPM limits
                        await asyncio.sleep(5)
                        break
                except Exception as e:
                    print(f"Error calling analyze_articles: {e}")
                    break

        print(f"Finished processing. Successfully added: {success_count}")

    if __name__ == "__main__":
        asyncio.run(process_remaining())
