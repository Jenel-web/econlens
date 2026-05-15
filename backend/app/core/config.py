import os
import pathlib
from dotenv import load_dotenv

# Try loading .env from project root
ROOT_DIR = pathlib.Path(__file__).resolve().parent.parent.parent.parent
load_dotenv(ROOT_DIR / ".env")

class Settings:
    @property
    def SUPABASE_URL(self) -> str:
        return os.getenv("SUPABASE_URL", "")
    
    @property
    def SUPABASE_KEY(self) -> str:
        return os.getenv("SUPABASE_KEY", "")
    
    @property
    def NEWSAPI_KEY(self) -> str:
        return os.getenv("NEWSAPI_KEY", "")

    @property
    def GEMINI_API_KEY(self) -> str:
        return os.getenv("GEMINI_API_KEY", "")

settings = Settings()
