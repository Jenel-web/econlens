"""
test_gemini.py
--------------
Quick smoke test for the Gemini integration.

Loads GEMINI_API_KEY from the root .env file, sends a single
economic-impact prompt using gemini-1.5-flash, and prints the response.

Usage (from /backend):
    python test_gemini.py
"""

import os
import sys
import pathlib
from dotenv import load_dotenv
import google.generativeai as genai

# Reconfigure stdout to handle UTF-8 (fixes Peso symbol ₱ error on Windows)
if sys.stdout.encoding != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8')

# ── Load .env from the project root (one level up from /backend) ──────────────
ROOT_DIR = pathlib.Path(__file__).resolve().parent.parent
dotenv_path = ROOT_DIR / ".env"

if not dotenv_path.exists():
    # Fallback to current directory if not found in parent
    dotenv_path = pathlib.Path(".env").resolve()

load_dotenv(dotenv_path)

# ── Validate key ──────────────────────────────────────────────────────────────
api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise ValueError(
        f"GEMINI_API_KEY is not set in your .env file at {dotenv_path}.\n"
        "Please check the file and ensure it contains: GEMINI_API_KEY=your_key"
    )

# ── Configure Gemini ──────────────────────────────────────────────────────────
genai.configure(api_key=api_key)
model = genai.GenerativeModel("gemini-pro-latest")

# ── Send prompt ───────────────────────────────────────────────────────────────
PROMPT = 'Explain how a ₱2 oil price hike affects a jeepney driver.'

print("=" * 60)
print("EconImpact PH — Gemini Test")
print("=" * 60)
print(f"Model  : gemini-1.5-flash")
print(f"Prompt : {PROMPT}")
print("-" * 60)

try:
    response = model.generate_content(PROMPT)
    print(response.text)
except Exception as e:
    print(f"Error calling Gemini API: {e}")

print("=" * 60)
print("Test complete.")
