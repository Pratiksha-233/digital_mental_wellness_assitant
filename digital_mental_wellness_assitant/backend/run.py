#!/usr/bin/env python
"""
Backend startup script for the Digital Mental Wellness Assistant.
Runs the Flask development server on http://0.0.0.0:5000

Usage:
    python run.py

Options:
    --https   Start with a self-signed (dev) TLS certificate so you can open
              https://<your-laptop-ip>:5000 on a phone.
"""

import sys
import socket
import argparse
from typing import Optional
from pathlib import Path


backend_path = Path(__file__).parent
sys.path.insert(0, str(backend_path))

from app import app


def _get_lan_ipv4() -> Optional[str]:
    """Best-effort LAN IPv4 for printing a usable phone URL."""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

        sock.connect(("8.8.8.8", 80))
        ip = sock.getsockname()[0]
        sock.close()
        return ip
    except Exception:
        return None

if __name__ == '__main__':
    parser = argparse.ArgumentParser(add_help=True)
    parser.add_argument(
        "--https",
        action="store_true",
        help="Run server with a self-signed dev certificate (https).",
    )
    args = parser.parse_args()

    print("\n" + "="*60)
    print("🧠 Digital Mental Wellness Assistant - Backend")
    print("="*60)
    print("\n📡 Starting Flask development server...")
    scheme = "https" if args.https else "http"
    print(f"🌐 Server binding: {scheme}://0.0.0.0:5000")

    lan_ip = _get_lan_ipv4()
    if lan_ip:
        print(f"📱 Phone URL (same Wi-Fi): {scheme}://{lan_ip}:5000")
        print(f"🩺 Health check:          {scheme}://{lan_ip}:5000/health")
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



    ssl_context = None
    if args.https:

        try:
            import cryptography

            ssl_context = "adhoc"
        except Exception as e:
            print("\n[WARN] HTTPS requested but TLS dependencies are missing.")
            print("       Install with: pip install cryptography")
            print(f"       Details: {e}")
            print("       Falling back to HTTP.\n")
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True,
        use_reloader=False,
        ssl_context=ssl_context,
    )
