"""Simple script to verify DB connection using backend.services.db_service.get_connection().

Usage (from project root):
    python -m backend.check_db_connection
    
Or from backend folder:
    python check_db_connection.py
"""
import sys
from pathlib import Path

# Add parent (backend) directory to path so services can be imported
sys.path.insert(0, str(Path(__file__).resolve().parent))

from services.db_service import get_connection


def main():
    conn = get_connection()
    if conn:
        try:
            cur = conn.cursor()
            cur.execute('SELECT VERSION()')
            version = cur.fetchone()
            print('Connected to MySQL server. Version:', version)
            cur.close()
            conn.close()
            return 0
        except Exception as e:
            print('Query failed:', e)
            return 2
    else:
        print('Failed to connect to DB')
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
