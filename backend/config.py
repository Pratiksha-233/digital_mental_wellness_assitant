import os
import cv2
from datetime import timedelta

try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception:
    pass


class Config:
    """Base configuration"""
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    
    # Flask settings
    JSON_SORT_KEYS = False
    JSONIFY_PRETTYPRINT_REGULAR = True
    
    # Session configuration
    PERMANENT_SESSION_LIFETIME = timedelta(days=7)
    SESSION_COOKIE_SECURE = False
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'


class MySQLConfig(Config):
    """MySQL Database configuration"""
    MYSQL_HOST = os.environ.get('MYSQL_HOST') or 'localhost'
    MYSQL_USER = os.environ.get('MYSQL_USER') or 'root'
    MYSQL_PASSWORD = os.environ.get('MYSQL_PASSWORD') or 'nayan@337' 
    MYSQL_DATABASE = os.environ.get('MYSQL_DATABASE') or 'mental_wellness'
    MYSQL_PORT = int(os.environ.get('MYSQL_PORT') or 3306)
    
    # SQLAlchemy configuration
    SQLALCHEMY_DATABASE_URI = f'mysql+pymysql://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}:{MYSQL_PORT}/{MYSQL_DATABASE}'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_size': 10,
        'pool_recycle': 3600,
        'pool_pre_ping': True,
    }


class EmotionDetectionConfig:
    """Emotion detection settings"""
    # Model paths
    MODEL_JSON_PATH = 'emotiondetecter2.json'
    MODEL_H5_PATH = 'emotiondetecter2.h5'
    FACE_CASCADE_PATH = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
    
    # Detection parameters
    CONFIDENCE_THRESHOLD = 0.6
    STABLE_FRAME_COUNT = 10
    EMOTION_BUFFER_SIZE = 5
    MIN_DURATION_SECONDS = 2
    FPS = 30
    
    # Emotion labels
    EMOTION_LABELS = ['angry', 'disgust', 'fear', 'happy', 'neutral', 'sad', 'surprise']
    
    # Intensity mapping
    INTENSITY_MAPPING = {
        'low': (0, 2),
        'medium': (2, 5),
        'high': (5, 100)
    }


# Active configuration
config = MySQLConfig()
emotion_config = EmotionDetectionConfig()

# Legacy config for backwards compatibility
DB_CONFIG = {
    'host': os.getenv('MYSQL_HOST', 'localhost'),
    'user': os.getenv('MYSQL_USER', 'root'),
    'password': os.getenv('MYSQL_PASSWORD', 'nayan@337'),
    'database': os.getenv('MYSQL_DATABASE', 'mental_wellness')
}

SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')