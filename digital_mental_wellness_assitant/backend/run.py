#!/usr/bin/env python
"""
Backend startup script for the Digital Mental Wellness Assistant.
Runs the Flask development server on http://0.0.0.0:5000

Usage:
    python run.py
"""

import sys
from pathlib import Path

# Ensure the backend module can be imported
backend_path = Path(__file__).parent
sys.path.insert(0, str(backend_path))

from app import app

if __name__ == '__main__':
    print("\n" + "="*60)
    print("🧠 Digital Mental Wellness Assistant - Backend")
    print("="*60)
    print("\n📡 Starting Flask development server...")
    print("🌐 Server running at: http://0.0.0.0:5000")
    print("\n📚 API Endpoints:")
    print("   • /api/auth/register         - Register new user")
    print("   • /api/auth/login            - User login")
    print("   • /api/mood/log              - Log mood entry")
    print("   • /api/mood/logs             - Get mood history")
    print("   • /api/journal/entries       - Get journal entries")
    print("   • /api/stress/calculate      - Calculate stress level")
    print("   • /api/stress/history        - Get stress history")
    print("   • /api/stress/stats          - Get stress statistics")
    print("\n💡 Press CTRL+C to stop the server")
    print("="*60 + "\n")
    
    app.run(host='0.0.0.0', port=5000, debug=True)
