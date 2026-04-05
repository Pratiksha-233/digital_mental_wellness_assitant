import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from flask import Flask, jsonify, request, send_from_directory, abort
from flask_cors import CORS

try:
    from . import config
except ImportError:
    import config


try:
    from .routes.auth_routes import auth_bp
    from .routes.mood_routes import mood_bp
    from .routes.recommend_routes import rec_bp
    from .routes.chat_routes import chat_bp
    from .routes.realtimedetection_routes import detection_bp
    from .routes.stress_routes import stress_bp
    from .routes.analytics_routes import analytics_bp
    from .routes.voice_routes import voice_bp
except ImportError:

    from routes.auth_routes import auth_bp
    from routes.mood_routes import mood_bp
    from routes.recommend_routes import rec_bp
    from routes.chat_routes import chat_bp
    from routes.realtimedetection_routes import detection_bp
    from routes.stress_routes import stress_bp
    from routes.analytics_routes import analytics_bp
    from routes.voice_routes import voice_bp


app = Flask(__name__)

app.config['SECRET_KEY'] = config.SECRET_KEY
CORS(app)


def _web_build_dir() -> Path:
    """Returns the Flutter web build directory if it exists.

    Expected location (repo layout):
    - <repo>/digital_mental_wellness_assitant/frontend/build/web
    """
    return Path(__file__).resolve().parents[1] / "frontend" / "build" / "web"


def _has_web_build() -> bool:
    d = _web_build_dir()
    return d.exists() and (d / "index.html").exists()


@app.get("/")
def index():

    if _has_web_build():
        return send_from_directory(_web_build_dir(), "index.html")

    payload = {
        "name": "Digital Mental Wellness Assistant API",
        "status": "running",
        "docs": {
            "auth": "/api/auth",
            "mood": "/api/mood",
            "recommend": "/api/recommend",
            "chat": "/api/chat",
            "detection": "/api/detection",
            "stress": "/api/stress",
            "analytics": "/api/analytics",
            "voice": "/api/voice",
        },
        "health": "/health",
    }



    if request.accept_mimetypes.best == "text/html":
        links = "\n".join(
            f"<li><a href='{v}'>{k}: {v}</a></li>" for k, v in payload["docs"].items()
        )
        return (
            "<!doctype html>"
            "<html><head><meta charset='utf-8'><title>API Running</title></head>"
            "<body>"
            "<h2>Digital Mental Wellness Assistant API</h2>"
            "<p>Status: <b>running</b></p>"
            "<p>Health: <a href='/health'>/health</a></p>"
            "<h3>API prefixes</h3>"
            f"<ul>{links}</ul>"
            "</body></html>",
            200,
            {"Content-Type": "text/html; charset=utf-8"},
        )

    return jsonify(payload)


@app.get("/<path:path>")
def web_static_or_spa(path: str):
    """Serves Flutter Web static files and supports SPA routing.

    - If the requested file exists in build/web, serve it.
    - Otherwise, return index.html so Flutter handles client-side routes.
    """
    if not _has_web_build():
        abort(404)

    web_dir = _web_build_dir()
    candidate = web_dir / path
    if candidate.exists() and candidate.is_file():
        return send_from_directory(web_dir, path)

    return send_from_directory(web_dir, "index.html")


@app.get("/health")
def health():
    return jsonify({"status": "ok"})



app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(mood_bp, url_prefix='/api/mood')
app.register_blueprint(rec_bp, url_prefix='/api/recommend')
app.register_blueprint(chat_bp, url_prefix='/api/chat')
app.register_blueprint(detection_bp, url_prefix='/api/detection')
app.register_blueprint(stress_bp, url_prefix='/api/stress')
app.register_blueprint(analytics_bp, url_prefix='/api/analytics')
app.register_blueprint(voice_bp, url_prefix='/api/voice')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)