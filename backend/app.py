from flask import Flask, jsonify
from flask_cors import CORS
from datetime import datetime
from config import MySQLConfig
from database.models import db
import os


def create_app(config_class=MySQLConfig):
    """Application factory"""
    app = Flask(__name__)
    
    # Load configuration
    app.config.from_object(config_class)
    
    # Initialize extensions
    db.init_app(app)
    CORS(app)
    
    # Create tables in application context
    with app.app_context():
        try:
            db.create_all()
            print("✓ Database tables created/verified")
        except Exception as e:
            print(f"✗ Error creating tables: {str(e)}")
    
    # Health check endpoint
    @app.route('/api/health', methods=['GET'])
    def health_check():
        """Health check endpoint"""
        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.utcnow().isoformat(),
            'database': 'connected'
        }), 200
    
    # Error handlers
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({'error': 'Not found'}), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        db.session.rollback()
        return jsonify({'error': 'Internal server error'}), 500
    
    # Blueprint registration (to be implemented)
    # from routes.auth_routes import auth_bp
    # from routes.mood_routes import mood_bp
    # from routes.emotion_routes import emotion_bp
    # app.register_blueprint(auth_bp, url_prefix='/api/auth')
    # app.register_blueprint(mood_bp, url_prefix='/api/moods')
    # app.register_blueprint(emotion_bp, url_prefix='/api/emotions')
    
    return app


if __name__ == '__main__':
    app = create_app()
    print("✓ Flask app initialized")
    print(f"✓ Database URI: {MySQLConfig.SQLALCHEMY_DATABASE_URI}")
    print("🚀 Starting server on http://localhost:5000")
    app.run(debug=True, host='0.0.0.0', port=5000)