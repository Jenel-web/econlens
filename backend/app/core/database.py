from supabase import create_client, Client
from app.core.config import settings

# Create a single supabase client instance
if settings.SUPABASE_URL and settings.SUPABASE_KEY:
    supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
else:
    # Set to None if credentials aren't loaded properly
    # This might happen if config is imported before load_dotenv in main.py, 
    # so we'll wrap it in a function or just initialize it carefully.
    supabase = None

def get_supabase_client() -> Client:
    global supabase
    if supabase is None:
        if settings.SUPABASE_URL and settings.SUPABASE_KEY:
            supabase = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
        else:
            raise Exception("Supabase credentials not found. Check your .env file.")
    return supabase
