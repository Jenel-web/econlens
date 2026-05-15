from pydantic import BaseModel, HttpUrl
from typing import Optional
from datetime import datetime
import uuid

class ArticleSchema(BaseModel):
    id: Optional[uuid.UUID] = None
    title: str
    source: str
    source_url: str
    published_at: datetime
    raw_content: Optional[str] = None
    # created_at is handled by the database
