import os
from pathlib import Path
try:
	from dotenv import load_dotenv
	load_dotenv()
except Exception:
	pass

DB_CONFIG = {
 'host': os.getenv('DB_HOST', 'localhost'),
 'user': os.getenv('DB_USER', 'root'),
 'password': os.getenv('DB_PASS', 'nayan@337'),
 'database': os.getenv('DB_NAME', 'mental_wellness'),

 'port': int(os.getenv('DB_PORT', 3306)),
 'autocommit': False,
 'use_unicode': True,
 'charset': 'utf8mb4',
 'collation': 'utf8mb4_unicode_ci',
 'raise_on_warnings': False,
 'password': os.getenv('DB_PASS', 'nayan@337'),
 'database': os.getenv('DB_NAME', 'mental_wellness'),

 'port': int(os.getenv('DB_PORT', 3306)),
 'autocommit': False,
 'use_unicode': True,
 'charset': 'utf8mb4',
 'collation': 'utf8mb4_unicode_ci',
 'raise_on_warnings': False
}

# Database engine for local development.
# - sqlite: zero-config local file DB (default)
# - mysql: connect to a running MySQL instance using DB_CONFIG
DB_ENGINE = os.getenv('DB_ENGINE', 'sqlite').strip().lower()

# Used when DB_ENGINE=sqlite (or when falling back to sqlite).
SQLITE_PATH = os.getenv(
	'SQLITE_PATH',
	str(Path(__file__).resolve().parent / 'mental_wellness.sqlite3'),
)

# When DB_ENGINE=mysql but MySQL connection fails, allow falling back to sqlite.
SQLITE_FALLBACK = os.getenv('SQLITE_FALLBACK', 'true').strip().lower() in {'1', 'true', 'yes'}

SECRET_KEY = os.getenv('SECRET_KEY', 'your-secret-key-change-in-production')
DEBUG = os.getenv('FLASK_DEBUG', True)
TESTING = os.getenv('FLASK_TESTING', False)

ML_MODEL_PATH = os.getenv('ML_MODEL_PATH', 'models/sentiment_model.h5')
EMOTION_MODEL_PATH = os.getenv('EMOTION_MODEL_PATH', '../emotiondetecter.h5')