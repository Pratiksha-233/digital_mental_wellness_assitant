import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from flask import Flask
from flask_cors import CORS

try:
    from . import config
except ImportError:
    import config

<<<<<<< HEAD


from .routes.auth_routes import auth_bp
from .routes.mood_routes import mood_bp
from .routes.recommend_routes import rec_bp
from .routes.chat_routes import chat_bp
from .routes.realtimedetection_routes import detection_bp
=======
try:
    from .routes.auth_routes import auth_bp
    from .routes.mood_routes import mood_bp
    from .routes.recommend_routes import rec_bp
    from .routes.chat_routes import chat_bp
    from .routes.realtimedetection_routes import detection_bp
    from .routes.stress_routes import stress_bp
except ImportError:
    from routes.auth_routes import auth_bp
    from routes.mood_routes import mood_bp
    from routes.recommend_routes import rec_bp
    from routes.chat_routes import chat_bp
    from routes.realtimedetection_routes import detection_bp
    from routes.stress_routes import stress_bp
>>>>>>> 7e55bbb5 (stress level)


app = Flask(__name__)

app.config['SECRET_KEY'] = config.SECRET_KEY
CORS(app)


# register blueprints
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(mood_bp, url_prefix='/api/mood')
app.register_blueprint(rec_bp, url_prefix='/api/recommend')
app.register_blueprint(chat_bp, url_prefix='/api/chat')
app.register_blueprint(detection_bp, url_prefix='/api/detection')
app.register_blueprint(stress_bp, url_prefix='/api/stress')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)