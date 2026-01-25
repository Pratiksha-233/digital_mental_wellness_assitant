from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import json

db = SQLAlchemy()


class User(db.Model):
    """User model mapping to users1 table"""
    __tablename__ = 'users1'
    
    user_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(100), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    full_name = db.Column(db.String(120), nullable=True)
    age = db.Column(db.Integer, nullable=True)
    gender = db.Column(db.String(20), nullable=True)
    profile_picture = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login = db.Column(db.DateTime, nullable=True)
    is_active = db.Column(db.Boolean, default=True)
    
    # Relationships
    moods = db.relationship('Mood', backref='user', lazy=True, cascade='all, delete-orphan')
    emotion_sessions = db.relationship('EmotionSession', backref='user', lazy=True, cascade='all, delete-orphan')
    emotion_data = db.relationship('EmotionData', backref='user', lazy=True, cascade='all, delete-orphan')
    wellness_logs = db.relationship('WellnessLog', backref='user', lazy=True, cascade='all, delete-orphan')
    recommendations = db.relationship('Recommendation', backref='user', lazy=True, cascade='all, delete-orphan')
    chat_logs = db.relationship('ChatLog', backref='user', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        return {
            'user_id': self.user_id,
            'username': self.username,
            'email': self.email,
            'full_name': self.full_name,
            'age': self.age,
            'gender': self.gender,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'is_active': self.is_active
        }


class Mood(db.Model):
    """Mood model mapping to moods table"""
    __tablename__ = 'moods'
    
    mood_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users1.user_id', ondelete='CASCADE'), nullable=False)
    mood_type = db.Column(db.String(50), nullable=False)
    intensity = db.Column(db.Integer, nullable=True)
    trigger = db.Column(db.Text, nullable=True)
    notes = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'mood_id': self.mood_id,
            'user_id': self.user_id,
            'mood_type': self.mood_type,
            'intensity': self.intensity,
            'trigger': self.trigger,
            'notes': self.notes,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class EmotionSession(db.Model):
    """Emotion session model mapping to emotion_sessions table"""
    __tablename__ = 'emotion_sessions'
    
    session_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users1.user_id', ondelete='CASCADE'), nullable=False)
    session_start = db.Column(db.DateTime, default=datetime.utcnow)
    session_end = db.Column(db.DateTime, nullable=True)
    status = db.Column(db.String(50), default='active')
    notes = db.Column(db.Text, nullable=True)
    
    # Relationships
    emotion_data = db.relationship('EmotionData', backref='session', lazy=True, cascade='all, delete-orphan')
    emotion_stats = db.relationship('EmotionStats', backref='session', uselist=False, cascade='all, delete-orphan')
    
    def to_dict(self):
        return {
            'session_id': self.session_id,
            'user_id': self.user_id,
            'session_start': self.session_start.isoformat() if self.session_start else None,
            'session_end': self.session_end.isoformat() if self.session_end else None,
            'status': self.status,
            'notes': self.notes
        }


class EmotionData(db.Model):
    """Emotion data model mapping to emotion_data table"""
    __tablename__ = 'emotion_data'
    
    emotion_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    session_id = db.Column(db.Integer, db.ForeignKey('emotion_sessions.session_id', ondelete='CASCADE'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users1.user_id', ondelete='CASCADE'), nullable=False)
    emotion_type = db.Column(db.String(50), nullable=False)
    confidence = db.Column(db.Float, nullable=False)
    duration_seconds = db.Column(db.Float, nullable=True)
    intensity_level = db.Column(db.String(20), nullable=True)
    peak_confidence = db.Column(db.Float, nullable=True)
    stability_score = db.Column(db.Float, nullable=True)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'emotion_id': self.emotion_id,
            'session_id': self.session_id,
            'user_id': self.user_id,
            'emotion_type': self.emotion_type,
            'confidence': float(self.confidence),
            'duration_seconds': float(self.duration_seconds) if self.duration_seconds else None,
            'intensity_level': self.intensity_level,
            'peak_confidence': float(self.peak_confidence) if self.peak_confidence else None,
            'stability_score': float(self.stability_score) if self.stability_score else None,
            'timestamp': self.timestamp.isoformat() if self.timestamp else None
        }


class EmotionStats(db.Model):
    """Emotion statistics model mapping to emotion_stats table"""
    __tablename__ = 'emotion_stats'
    
    stat_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    session_id = db.Column(db.Integer, db.ForeignKey('emotion_sessions.session_id', ondelete='CASCADE'), nullable=False, unique=True)
    total_emotions = db.Column(db.Integer, default=0)
    dominant_emotion = db.Column(db.String(50), nullable=True)
    emotion_distribution = db.Column(db.Text, nullable=True)  # JSON string
    average_confidence = db.Column(db.Float, nullable=True)
    session_duration_minutes = db.Column(db.Float, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def set_emotion_distribution(self, dist_dict):
        self.emotion_distribution = json.dumps(dist_dict)
    
    def get_emotion_distribution(self):
        if self.emotion_distribution:
            return json.loads(self.emotion_distribution)
        return {}
    
    def to_dict(self):
        return {
            'stat_id': self.stat_id,
            'session_id': self.session_id,
            'total_emotions': self.total_emotions,
            'dominant_emotion': self.dominant_emotion,
            'emotion_distribution': self.get_emotion_distribution(),
            'average_confidence': float(self.average_confidence) if self.average_confidence else None,
            'session_duration_minutes': float(self.session_duration_minutes) if self.session_duration_minutes else None,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class WellnessLog(db.Model):
    """Wellness log model mapping to wellness_logs table"""
    __tablename__ = 'wellness_logs'
    
    log_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users1.user_id', ondelete='CASCADE'), nullable=False)
    stress_level = db.Column(db.Integer, nullable=True)
    anxiety_level = db.Column(db.Integer, nullable=True)
    wellness_score = db.Column(db.Float, nullable=True)
    notes = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'log_id': self.log_id,
            'user_id': self.user_id,
            'stress_level': self.stress_level,
            'anxiety_level': self.anxiety_level,
            'wellness_score': float(self.wellness_score) if self.wellness_score else None,
            'notes': self.notes,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class DailySummary(db.Model):
    """Daily summary model mapping to daily_summary table"""
    __tablename__ = 'daily_summary'
    
    summary_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users1.user_id', ondelete='CASCADE'), nullable=False)
    date = db.Column(db.Date, nullable=False)
    total_emotions = db.Column(db.Integer, default=0)
    dominant_emotion = db.Column(db.String(50), nullable=True)
    emotion_breakdown = db.Column(db.Text, nullable=True)  # JSON string
    daily_wellness_score = db.Column(db.Float, nullable=True)
    stress_level = db.Column(db.Integer, nullable=True)
    anxiety_level = db.Column(db.Integer, nullable=True)
    notes = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    __table_args__ = (db.UniqueConstraint('user_id', 'date', name='unique_user_date'),)
    
    def set_emotion_breakdown(self, breakdown_dict):
        self.emotion_breakdown = json.dumps(breakdown_dict)
    
    def get_emotion_breakdown(self):
        if self.emotion_breakdown:
            return json.loads(self.emotion_breakdown)
        return {}
    
    def to_dict(self):
        return {
            'summary_id': self.summary_id,
            'user_id': self.user_id,
            'date': str(self.date),
            'total_emotions': self.total_emotions,
            'dominant_emotion': self.dominant_emotion,
            'emotion_breakdown': self.get_emotion_breakdown(),
            'daily_wellness_score': float(self.daily_wellness_score) if self.daily_wellness_score else None,
            'stress_level': self.stress_level,
            'anxiety_level': self.anxiety_level,
            'notes': self.notes
        }


class Recommendation(db.Model):
    """Recommendation model mapping to recommendation table"""
    __tablename__ = 'recommendation'
    
    rec_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users1.user_id', ondelete='CASCADE'), nullable=False)
    recommendation_text = db.Column(db.Text, nullable=False)
    category = db.Column(db.String(100), nullable=True)
    priority = db.Column(db.String(20), default='normal')
    status = db.Column(db.String(20), default='active')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    expires_at = db.Column(db.DateTime, nullable=True)
    
    def to_dict(self):
        return {
            'rec_id': self.rec_id,
            'user_id': self.user_id,
            'recommendation_text': self.recommendation_text,
            'category': self.category,
            'priority': self.priority,
            'status': self.status,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'expires_at': self.expires_at.isoformat() if self.expires_at else None
        }


class ChatLog(db.Model):
    """Chat log model mapping to chat_logs table"""
    __tablename__ = 'chat_logs'
    
    chat_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users1.user_id', ondelete='CASCADE'), nullable=False)
    user_message = db.Column(db.Text, nullable=False)
    bot_response = db.Column(db.Text, nullable=False)
    sentiment = db.Column(db.String(50), nullable=True)
    session_id = db.Column(db.String(100), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'chat_id': self.chat_id,
            'user_id': self.user_id,
            'user_message': self.user_message,
            'bot_response': self.bot_response,
            'sentiment': self.sentiment,
            'session_id': self.session_id,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class EmotionTrend(db.Model):
    """Emotion trend model mapping to emotion_trends table"""
    __tablename__ = 'emotion_trends'
    
    trend_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users1.user_id', ondelete='CASCADE'), nullable=False)
    period_type = db.Column(db.String(50), nullable=False)  # 'daily', 'weekly', 'monthly'
    period_start = db.Column(db.DateTime, nullable=False)
    period_end = db.Column(db.DateTime, nullable=False)
    dominant_emotion = db.Column(db.String(50), nullable=True)
    overall_trend = db.Column(db.String(100), nullable=True)
    emotion_counts = db.Column(db.Text, nullable=True)  # JSON
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'trend_id': self.trend_id,
            'user_id': self.user_id,
            'period_type': self.period_type,
            'period_start': self.period_start.isoformat() if self.period_start else None,
            'period_end': self.period_end.isoformat() if self.period_end else None,
            'dominant_emotion': self.dominant_emotion,
            'overall_trend': self.overall_trend,
            'emotion_counts': json.loads(self.emotion_counts) if self.emotion_counts else {}
        }


class Alert(db.Model):
    """Alert model mapping to alerts table"""
    __tablename__ = 'alerts'
    
    alert_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users1.user_id', ondelete='CASCADE'), nullable=False)
    alert_type = db.Column(db.String(100), nullable=False)
    message = db.Column(db.Text, nullable=False)
    severity = db.Column(db.String(20), default='info')  # 'info', 'warning', 'critical'
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    expires_at = db.Column(db.DateTime, nullable=True)
    
    def to_dict(self):
        return {
            'alert_id': self.alert_id,
            'user_id': self.user_id,
            'alert_type': self.alert_type,
            'message': self.message,
            'severity': self.severity,
            'is_read': self.is_read,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'expires_at': self.expires_at.isoformat() if self.expires_at else None
        }


class AuditLog(db.Model):
    """Audit log model mapping to audit_logs table"""
    __tablename__ = 'audit_logs'
    
    log_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users1.user_id', ondelete='CASCADE'), nullable=True)
    action = db.Column(db.String(100), nullable=False)
    table_name = db.Column(db.String(100), nullable=False)
    record_id = db.Column(db.Integer, nullable=True)
    old_values = db.Column(db.Text, nullable=True)  # JSON
    new_values = db.Column(db.Text, nullable=True)  # JSON
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'log_id': self.log_id,
            'user_id': self.user_id,
            'action': self.action,
            'table_name': self.table_name,
            'record_id': self.record_id,
            'old_values': json.loads(self.old_values) if self.old_values else {},
            'new_values': json.loads(self.new_values) if self.new_values else {},
            'timestamp': self.timestamp.isoformat() if self.timestamp else None
        }
