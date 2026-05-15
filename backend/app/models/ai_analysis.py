from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import uuid


class AIAnalysisSchema(BaseModel):
    """
    Pydantic model representing the ai_analysis table in Supabase.
    Columns: id, article_id, one_line_summary, economic_impact_summary,
             advice, severity_level, generated_at
    """
    id: Optional[uuid.UUID] = None
    article_id: uuid.UUID
    one_line_summary: str
    economic_impact_summary: str
    advice: str
    severity_level: str  # "Low", "Medium", or "High"
    generated_at: Optional[datetime] = None
