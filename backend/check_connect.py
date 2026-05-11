"""
check_connect.py — Standalone connectivity test for EconImpact PH backend.

Run from the project root:
    python backend/check_connect.py

Expected output (server running):
    ✅ Backend is reachable!
    Status  : 200
    Response: {
      "status": "online",
      "version": "0.1.0",
      "environment": "development"
    }

Expected output (server NOT running):
    ❌ Connection failed! Is the server running?
    Error: HTTPConnectionPool(...): Max retries exceeded
"""

import json
import sys
import requests

# Ensure UTF-8 output on Windows terminals that default to cp1252
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

BACKEND_URL = "http://127.0.0.1:8000"
HEALTH_ENDPOINT = f"{BACKEND_URL}/health"


def test_connection():
    print("=" * 50)
    print("  EconImpact PH — Backend Connectivity Check")
    print("=" * 50)
    print(f"  Endpoint : {HEALTH_ENDPOINT}\n")

    try:
        response = requests.get(HEALTH_ENDPOINT, timeout=5)

        if response.status_code == 200:
            print("[OK] Backend is reachable!")
        else:
            print(f"[WARN] Backend responded with an unexpected status.")

        print(f"  Status  : {response.status_code}")
        pretty = json.dumps(response.json(), indent=2)
        print(f"  Response: {pretty}")

    except requests.exceptions.ConnectionError as e:
        print("[FAIL] Connection failed! Is the server running?")
        print(f"  Error: {e}")
    except requests.exceptions.Timeout:
        print("[FAIL] Connection timed out after 5 seconds.")
        print(f"  Make sure uvicorn is running at {BACKEND_URL}")
    except Exception as e:
        print(f"[FAIL] Unexpected error: {e}")

    print("=" * 50)


if __name__ == "__main__":
    test_connection()