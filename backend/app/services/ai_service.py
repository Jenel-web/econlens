"""
ai_service.py — EconLens Gemini AI Analysis Service

Reads the skills.md system prompt rules and analyzes raw article content
using Gemini. Generates Tagalog-language economic impact summaries and
persists results in the Supabase `ai_analysis` table.
"""
import uuid
import json
import logging
import re
from datetime import datetime, timezone, timedelta
from typing import List

import google.generativeai as genai

from app.core.config import settings
from app.core.database import get_supabase_client
from app.models.ai_analysis import AIAnalysisSchema

logger = logging.getLogger(__name__)

# Philippine Standard Time (UTC+8)
PST = timezone(timedelta(hours=8))

# ---------------------------------------------------------------------------
# System Prompt (aligned with agents.md / skills.md)
# ---------------------------------------------------------------------------
SYSTEM_PROMPT = """
Ikaw ay isang eksperto sa ekonomiya ng Pilipinas at isang dalubhasang tagasuri.
Ang iyong trabaho ay suriin ang mga artikulo sa balita at magbigay ng nakaayos na buod sa wikang Tagalog.

Sundin ang mga sumusunod na alituntunin:
- Gumamit ng propesyonal ngunit naiintindihang wika para sa karaniwang Pilipino.
- Iwasan ang mga teknikal na termino; gumamit ng simpleng salita (hal., sa halip na "liquidity crisis" gamitin ang "mahirap mag-budget ng pera").
- Palaging sagutin: "Magkano ang karagdagang gastusin ng karaniwang Pilipino dahil sa balitang ito?"
- I-evaluate ang epekto batay sa Limang Haligi (Five Pillars): Gasolina/LPG, Kuryente, Tubig, Transportasyon, Koneksyon (load/internet), at Pagkain/Bilihin.

Severity Logic (isang salita lamang):
- "Low"    → Epekto ay wala pang ₱500/buwan sa gastusin ng pamilya
- "Medium" → Epekto ay ₱500–₱2,000/buwan
- "High"   → Epekto ay mahigit ₱2,000/buwan O nakakaapekto sa maraming haligi nang sabay-sabay

Mahalagang Patakaran:
- Huwag mag-hallucinate. Kung walang sapat na detalye sa artikulo para kalkulahin ang pagbabago ng presyo, sabihing "di tiyak" ang epekto.
- Huwag sisihin ang kalidad ng buhay ng mambabasa; mag-alok lamang ng "Praktikal na Payo".

Palaging sumagot sa EKSAKTONG JSON format na ito, walang ibang teksto:
{
  "one_line_summary": "Maikling headline ng balita (Tagalog)",
  "economic_impact_summary": "2-3 pangungusap na nagpapaliwanag ng epekto sa mga Pilipinong pamilya (Tagalog)",
  "advice": "2-3 praktikal na payo para sa karaniwang Pilipino o may-ari ng negosyo (Tagalog)",
  "severity_level": "Low" o "Medium" o "High"
}

Huwag kailanman mag-output ng plain text. Palaging valid JSON lamang.
"""


def _configure_gemini() -> genai.GenerativeModel:
    """Initialize and return the Gemini model."""
    api_key = settings.GEMINI_API_KEY
    if not api_key:
        raise ValueError("GEMINI_API_KEY is not set in the environment variables.")
    genai.configure(api_key=api_key)
    return genai.GenerativeModel(
        model_name="gemini-1.5-flash",
        system_instruction=SYSTEM_PROMPT,
        generation_config=genai.GenerationConfig(
            response_mime_type="application/json",
            temperature=0.4,
        ),
    )


def _parse_gemini_response(raw_text: str) -> dict:
    """
    Safely parse Gemini's JSON response. Strips markdown code fences if present.
    """
    # Strip markdown fences like ```json ... ```
    clean = re.sub(r"```(?:json)?\s*|\s*```", "", raw_text.strip())
    return json.loads(clean)


async def analyze_articles(article_ids: List[str]) -> dict:
    """
    Analyze a list of articles by ID using Gemini and store results in
    the Supabase `ai_analysis` table.

    Args:
        article_ids: List of article UUID strings to analyze.

    Returns:
        A summary dict with counts of analyzed and failed articles.
    """
    if not article_ids:
        return {"analyzed_count": 0, "failed_count": 0, "message": "No articles to analyze."}

    supabase = get_supabase_client()

    # Fetch only the articles that still need analysis
    # (i.e., those whose IDs are not already in ai_analysis)
    existing_analysis = supabase.table("ai_analysis").select("article_id").in_(
        "article_id", article_ids
    ).execute()

    already_analyzed_ids = {row["article_id"] for row in (existing_analysis.data or [])}
    pending_ids = [aid for aid in article_ids if aid not in already_analyzed_ids]

    if not pending_ids:
        logger.info("All provided articles already have analysis. Skipping.")
        return {"analyzed_count": 0, "failed_count": 0, "message": "All articles already analyzed."}

    # Fetch the full article records for the pending IDs
    articles_resp = supabase.table("articles").select(
        "id, title, raw_content"
    ).in_("id", pending_ids).execute()

    articles = articles_resp.data or []
    if not articles:
        return {"analyzed_count": 0, "failed_count": 0, "message": "No article content found."}

    try:
        model = _configure_gemini()
    except ValueError as e:
        logger.error(f"Gemini configuration error: {e}")
        return {"analyzed_count": 0, "failed_count": len(pending_ids), "message": str(e)}

    analyzed_count = 0
    failed_count = 0

    for article in articles:
        article_id = article.get("id")
        title = article.get("title", "No Title")
        raw_content = article.get("raw_content") or ""

        if not raw_content.strip():
            logger.warning(f"Skipping article {article_id} — empty raw_content.")
            failed_count += 1
            continue

        prompt = f"Balita:\nPamagat: {title}\n\nNilalaman:\n{raw_content}"

        try:
            response = model.generate_content(prompt)
            parsed = _parse_gemini_response(response.text)

            # Validate required fields exist
            required = {"one_line_summary", "economic_impact_summary", "advice", "severity_level"}
            if not required.issubset(parsed.keys()):
                raise ValueError(f"Gemini response missing required fields: {required - parsed.keys()}")

            # Build and insert analysis record
            analysis = AIAnalysisSchema(
                id=uuid.uuid4(),
                article_id=uuid.UUID(article_id),
                one_line_summary=parsed["one_line_summary"],
                economic_impact_summary=parsed["economic_impact_summary"],
                advice=parsed["advice"],
                severity_level=parsed["severity_level"].capitalize(),
                generated_at=datetime.now(PST),
            )

            insert_data = analysis.model_dump()
            insert_data["id"] = str(insert_data["id"])
            insert_data["article_id"] = str(insert_data["article_id"])
            insert_data["generated_at"] = insert_data["generated_at"].isoformat()

            supabase.table("ai_analysis").insert(insert_data).execute()
            analyzed_count += 1
            logger.info(f"✓ Analyzed article {article_id}: {title[:50]}...")

        except Exception as e:
            logger.error(f"✗ Failed to analyze article {article_id}: {e}")
            failed_count += 1

    return {
        "analyzed_count": analyzed_count,
        "failed_count": failed_count,
        "message": f"Analysis complete. Analyzed: {analyzed_count}, Failed: {failed_count}.",
    }
