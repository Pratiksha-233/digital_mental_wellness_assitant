#!/usr/bin/env python
"""Convenience launcher for the backend Flask app.

Run this from the project root:

    python run.py

This forwards to the backend/app.py application instance.
"""

import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent
BACKEND_DIR = ROOT / "backend"


sys.path.insert(0, str(BACKEND_DIR))

try:
    from backend.app import app
except Exception as exc:

    print("[ERROR] Failed importing backend.app:", exc)
    try:
        import app as _app_module
        app = _app_module.app
    except Exception as inner_exc:
        print("[FATAL] Could not locate Flask app instance:", inner_exc)
        raise


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("🧠 Digital Mental Wellness Assistant - Backend")
    print("=" * 60)
    print("\n📡 Starting Flask development server...")
    print("🌐 Server running at: http://0.0.0.0:5000")
    print("\n📚 Key API Endpoints (including chatbot):")
    print("   • /api/auth/login            - User login")
    print("   • /api/mood/log              - Log mood entry")
    print("   • /api/chat/message          - NLP chatbot (text + crisis detection)")
    print("   • /api/stress/calculate      - Stress calculation")
    print("\n💡 Press CTRL+C to stop the server")
    print("=" * 60 + "\n")

    app.run(host="0.0.0.0", port=5000, debug=True)
