from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import uuid


class AIAnalysisSchema(BaseModel):
    """
    Pydantic model representing the ai_analysis table in Supabase.
    Columns: id, article_id, ano_ang_nangyari, paano_ito_makakaapekto_satin,
             advice, tinatantyang_epekto_sa_budget, apektadong_larangan,
             severity_level, generated_at
    """
    id: Optional[uuid.UUID] = None
    article_id: uuid.UUID
    ano_ang_nangyari: str
    paano_ito_makakaapekto_satin: str
    advice: str
    tinatantyang_epekto_sa_budget: str
    apektadong_larangan: str
    severity_level: str  # 'low', 'medium', or 'high'
    generated_at: Optional[datetime] = None
