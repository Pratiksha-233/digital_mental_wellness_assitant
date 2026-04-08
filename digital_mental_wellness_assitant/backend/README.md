# Backend (Flask) - quick start

1. Create a virtualenv and install requirements:
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt

2. Database configuration (recommended for local dev)

Option A (default, zero-config): SQLite

- No MySQL needed. The backend will create a local DB file automatically.
- Optional `.env`:
  DB_ENGINE=sqlite
  SQLITE_PATH=backend/mental_wellness.sqlite3
  SECRET_KEY=replace-me

Option B: MySQL

- Requires a running MySQL server and correct credentials.
- `.env` example:
  DB_ENGINE=mysql
  DB_HOST=localhost
  DB_USER=root
  DB_PASS=yourpass
  DB_NAME=mental_wellness
  SQLITE_FALLBACK=false
  SECRET_KEY=replace-me

3. (MySQL only) Import `frontend/database/mental_wellness.sql` into MySQL.
4. Run backend:
   python app.py
