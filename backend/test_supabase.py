import os
import sys
import pathlib
from dotenv import load_dotenv
from supabase import create_client, Client

# Fix encoding for special characters on Windows
if sys.stdout.encoding != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8')

# --- Load .env from project root (one level up from /backend) ---
ROOT_DIR = pathlib.Path(__file__).resolve().parent.parent
dotenv_path = ROOT_DIR / ".env"
load_dotenv(dotenv_path)

url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_KEY")

if not url or not key:
    print(f"[ERROR] SUPABASE_URL or SUPABASE_KEY not found in {dotenv_path}")
    sys.exit(1)

# --- Initialize Supabase Client ---
supabase: Client = create_client(url, key)

print("=" * 60)
print("EconImpact PH - Supabase Connection Test")
print("=" * 60)
print(f"Project URL : {url}")
print("-" * 60)

# --- 1. TEST WRITE ---
print("\n[1] Testing Write: Inserting dummy record...")
test_data = {
    "title": "EconLens Connection Test",
    "source": "System Check",
    "source_url": "https://system.check/test",
    "published_at": "2026-05-06T00:00:00+00:00",
}

try:
    insert_response = supabase.table("articles").insert(test_data).execute()

    if not insert_response.data:
        print("[ERROR] Insert returned no data. Check your table schema.")
        sys.exit(1)

    inserted_record = insert_response.data[0]
    inserted_id = inserted_record.get("id")
    print(f"  [OK] Insert successful! ID: {inserted_id}")

    # --- 2. TEST READ ---
    print("\n[2] Testing Read: Fetching the record back...")
    select_response = supabase.table("articles").select("*").eq("id", inserted_id).execute()

    if select_response.data:
        print(f"  [OK] Fetch successful!")
        print(f"  Record: {select_response.data[0]}")
    else:
        print("  [ERROR] Fetch returned no data.")

except Exception as e:
    err = str(e)
    print(f"\n[ERROR] {err}")
    if "PGRST204" in err or "column" in err.lower():
        print("\n  Hint: Column name mismatch. Check your 'articles' table columns in Supabase.")
        print("  The table may not have a 'source' column - adjust the test_data dict to match.")
    elif "42501" in err or "row-level security" in err.lower():
        print("\n  Hint: RLS is still enabled. Disable it in Supabase > Table Editor > articles > RLS.")
    elif "does not exist" in err.lower():
        print("\n  Hint: The 'articles' table does not exist yet. Create it in Supabase first.")

print("\n" + "=" * 60)
print("Test complete.")
print("=" * 60)