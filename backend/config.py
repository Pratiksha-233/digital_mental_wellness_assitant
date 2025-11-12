import os
from dotenv import load_dotenv
load_dotenv()


DB_CONFIG = {
'host': os.getenv('DB_HOST', '127.0.0.1'),
'user': os.getenv('DB_USER', 'root'),
'password': os.getenv('DB_PASS', 'mysqlworld@123'),
'database': os.getenv('DB_NAME', 'mental_wellness')
}


SECRET_KEY = os.getenv('SECRET_KEY', 'replace-me-with-secure-key')