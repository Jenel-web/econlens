import os
from dotenv import load_dotenv

# Directly load the local configuration environment
load_dotenv()

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
