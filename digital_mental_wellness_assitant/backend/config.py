import os
try:
	from dotenv import load_dotenv
	load_dotenv()
except Exception:
	pass

DB_CONFIG = {
	'host': os.getenv('DB_HOST', 'localhost'),
	'user': os.getenv('DB_USER', 'root'),
<<<<<<< HEAD
	'password': os.getenv('DB_PASS', 'Pra@#ti825'),
	'database': os.getenv('DB_NAME', 'mental_wellness')
=======
	'password': os.getenv('DB_PASS', 'nayan@337'),
	'database': os.getenv('DB_NAME', 'mental_wellness'),
	'port': int(os.getenv('DB_PORT', 3306)),
	'autocommit': False,
	'use_unicode': True,
	'charset': 'utf8mb4',
	'collation': 'utf8mb4_unicode_ci',
	'raise_on_warnings': False
>>>>>>> 7e55bbb5 (stress level)
}

SECRET_KEY = os.getenv('SECRET_KEY', 'your-secret-key-change-in-production')
DEBUG = os.getenv('FLASK_DEBUG', True)
TESTING = os.getenv('FLASK_TESTING', False)

ML_MODEL_PATH = os.getenv('ML_MODEL_PATH', 'models/sentiment_model.h5')
EMOTION_MODEL_PATH = os.getenv('EMOTION_MODEL_PATH', '../emotiondetecter.h5')