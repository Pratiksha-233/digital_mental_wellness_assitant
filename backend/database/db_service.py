from datetime import datetime, timedelta
from sqlalchemy import and_, or_, func
from .models import (
    db, User, Mood, EmotionSession, EmotionData, EmotionStats,
    WellnessLog, DailySummary, Recommendation, ChatLog, EmotionTrend,
    Alert, AuditLog
)
import json


class DatabaseService:
    """Service layer for all database operations"""
    
    # ======================== USER OPERATIONS ========================
    
    @staticmethod
    def create_user(username, email, password_hash, full_name=None, age=None, gender=None):
        """Create a new user"""
        try:
            user = User(
                username=username,
                email=email,
                password_hash=password_hash,
                full_name=full_name,
                age=age,
                gender=gender
            )
            db.session.add(user)
            db.session.commit()
            print(f"✓ User created: {username} (ID: {user.user_id})")
            return user
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error creating user: {str(e)}")
            return None
    
    @staticmethod
    def get_user_by_id(user_id):
        """Get user by ID"""
        try:
            user = User.query.get(user_id)
            return user
        except Exception as e:
            print(f"✗ Error fetching user: {str(e)}")
            return None
    
    @staticmethod
    def get_user_by_username(username):
        """Get user by username"""
        try:
            user = User.query.filter_by(username=username).first()
            return user
        except Exception as e:
            print(f"✗ Error fetching user: {str(e)}")
            return None
    
    @staticmethod
    def update_user_last_login(user_id):
        """Update user's last login time"""
        try:
            user = User.query.get(user_id)
            if user:
                user.last_login = datetime.utcnow()
                db.session.commit()
                print(f"✓ Last login updated for user {user_id}")
                return True
            return False
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error updating last login: {str(e)}")
            return False
    
    # ======================== MOOD OPERATIONS ========================
    
    @staticmethod
    def add_mood(user_id, mood_type, intensity=None, trigger=None, notes=None):
        """Add a new mood entry"""
        try:
            mood = Mood(
                user_id=user_id,
                mood_type=mood_type,
                intensity=intensity,
                trigger=trigger,
                notes=notes
            )
            db.session.add(mood)
            db.session.commit()
            print(f"✓ Mood recorded: {mood_type} (ID: {mood.mood_id})")
            return mood
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error adding mood: {str(e)}")
            return None
    
    @staticmethod
    def get_user_moods(user_id, limit=50):
        """Get recent moods for a user"""
        try:
            moods = Mood.query.filter_by(user_id=user_id).order_by(
                Mood.created_at.desc()
            ).limit(limit).all()
            return moods
        except Exception as e:
            print(f"✗ Error fetching moods: {str(e)}")
            return []
    
    # ======================== EMOTION SESSION OPERATIONS ========================
    
    @staticmethod
    def create_emotion_session(user_id, username):
        """Create a new emotion detection session"""
        try:
            session = EmotionSession(
                user_id=user_id,
                session_start=datetime.utcnow(),
                status='active',
                notes=f"Session for {username}"
            )
            db.session.add(session)
            db.session.commit()
            print(f"✓ Emotion session created (ID: {session.session_id})")
            return session
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error creating session: {str(e)}")
            return None
    
    @staticmethod
    def end_emotion_session(session_id):
        """End an emotion detection session"""
        try:
            session = EmotionSession.query.get(session_id)
            if session:
                session.session_end = datetime.utcnow()
                session.status = 'completed'
                db.session.commit()
                print(f"✓ Session ended (ID: {session_id})")
                return True
            return False
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error ending session: {str(e)}")
            return False
    
    @staticmethod
    def get_user_sessions(user_id, limit=10):
        """Get recent sessions for a user"""
        try:
            sessions = EmotionSession.query.filter_by(user_id=user_id).order_by(
                EmotionSession.session_start.desc()
            ).limit(limit).all()
            return sessions
        except Exception as e:
            print(f"✗ Error fetching sessions: {str(e)}")
            return []
    
    # ======================== EMOTION DATA OPERATIONS ========================
    
    @staticmethod
    def add_emotion(session_id, user_id, emotion_type, confidence, 
                   duration_seconds=None, intensity_level=None, 
                   peak_confidence=None, stability_score=None):
        """Add emotion data to database"""
        try:
            emotion = EmotionData(
                session_id=session_id,
                user_id=user_id,
                emotion_type=emotion_type,
                confidence=confidence,
                duration_seconds=duration_seconds,
                intensity_level=intensity_level,
                peak_confidence=peak_confidence,
                stability_score=stability_score,
                timestamp=datetime.utcnow()
            )
            db.session.add(emotion)
            db.session.commit()
            print(f"✓ Emotion stored: {emotion_type} (confidence: {confidence:.2f}, ID: {emotion.emotion_id})")
            return emotion
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error adding emotion: {str(e)}")
            return None
    
    @staticmethod
    def get_session_emotions(session_id):
        """Get all emotions for a session"""
        try:
            emotions = EmotionData.query.filter_by(session_id=session_id).order_by(
                EmotionData.timestamp.asc()
            ).all()
            return emotions
        except Exception as e:
            print(f"✗ Error fetching emotions: {str(e)}")
            return []
    
    @staticmethod
    def get_user_emotions(user_id, limit=100):
        """Get recent emotions for a user"""
        try:
            emotions = EmotionData.query.filter_by(user_id=user_id).order_by(
                EmotionData.timestamp.desc()
            ).limit(limit).all()
            return emotions
        except Exception as e:
            print(f"✗ Error fetching emotions: {str(e)}")
            return []
    
    @staticmethod
    def get_emotion_distribution(session_id):
        """Calculate emotion distribution for a session"""
        try:
            emotions = EmotionData.query.filter_by(session_id=session_id).all()
            distribution = {}
            for emotion in emotions:
                emotion_type = emotion.emotion_type
                distribution[emotion_type] = distribution.get(emotion_type, 0) + 1
            return distribution
        except Exception as e:
            print(f"✗ Error calculating distribution: {str(e)}")
            return {}
    
    # ======================== EMOTION STATS OPERATIONS ========================
    
    @staticmethod
    def create_emotion_stats(session_id, user_id):
        """Create statistics for a session"""
        try:
            session = EmotionSession.query.get(session_id)
            emotions = EmotionData.query.filter_by(session_id=session_id).all()
            
            if not emotions:
                print("✗ No emotions found for stats calculation")
                return None
            
            total_emotions = len(emotions)
            emotion_distribution = DatabaseService.get_emotion_distribution(session_id)
            dominant_emotion = max(emotion_distribution, key=emotion_distribution.get) if emotion_distribution else None
            avg_confidence = sum(e.confidence for e in emotions) / total_emotions if emotions else 0
            
            session_duration = (session.session_end - session.session_start).total_seconds() / 60 if session.session_end else 0
            
            stats = EmotionStats(
                session_id=session_id,
                total_emotions=total_emotions,
                dominant_emotion=dominant_emotion,
                average_confidence=avg_confidence,
                session_duration_minutes=session_duration
            )
            stats.set_emotion_distribution(emotion_distribution)
            
            db.session.add(stats)
            db.session.commit()
            print(f"✓ Emotion stats created (Total: {total_emotions}, Dominant: {dominant_emotion})")
            return stats
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error creating stats: {str(e)}")
            return None
    
    @staticmethod
    def get_session_stats(session_id):
        """Get statistics for a session"""
        try:
            stats = EmotionStats.query.filter_by(session_id=session_id).first()
            return stats
        except Exception as e:
            print(f"✗ Error fetching stats: {str(e)}")
            return None
    
    # ======================== WELLNESS LOG OPERATIONS ========================
    
    @staticmethod
    def add_wellness_log(user_id, stress_level=None, anxiety_level=None, wellness_score=None, notes=None):
        """Add wellness log entry"""
        try:
            log = WellnessLog(
                user_id=user_id,
                stress_level=stress_level,
                anxiety_level=anxiety_level,
                wellness_score=wellness_score,
                notes=notes
            )
            db.session.add(log)
            db.session.commit()
            print(f"✓ Wellness log added (ID: {log.log_id})")
            return log
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error adding wellness log: {str(e)}")
            return None
    
    @staticmethod
    def get_user_wellness_logs(user_id, limit=30):
        """Get recent wellness logs for user"""
        try:
            logs = WellnessLog.query.filter_by(user_id=user_id).order_by(
                WellnessLog.created_at.desc()
            ).limit(limit).all()
            return logs
        except Exception as e:
            print(f"✗ Error fetching wellness logs: {str(e)}")
            return []
    
    # ======================== DAILY SUMMARY OPERATIONS ========================
    
    @staticmethod
    def create_daily_summary(user_id, date=None):
        """Create or update daily summary"""
        try:
            if date is None:
                date = datetime.utcnow().date()
            
            summary = DailySummary.query.filter_by(
                user_id=user_id,
                date=date
            ).first()
            
            if not summary:
                summary = DailySummary(user_id=user_id, date=date)
            
            # Calculate emotions for the day
            start_time = datetime.combine(date, datetime.min.time())
            end_time = datetime.combine(date, datetime.max.time())
            
            day_emotions = EmotionData.query.filter(
                and_(
                    EmotionData.user_id == user_id,
                    EmotionData.timestamp >= start_time,
                    EmotionData.timestamp <= end_time
                )
            ).all()
            
            if day_emotions:
                emotion_breakdown = {}
                for emotion in day_emotions:
                    emotion_type = emotion.emotion_type
                    emotion_breakdown[emotion_type] = emotion_breakdown.get(emotion_type, 0) + 1
                
                summary.total_emotions = len(day_emotions)
                summary.dominant_emotion = max(emotion_breakdown, key=emotion_breakdown.get)
                summary.set_emotion_breakdown(emotion_breakdown)
            
            db.session.add(summary)
            db.session.commit()
            print(f"✓ Daily summary created/updated (Date: {date})")
            return summary
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error creating daily summary: {str(e)}")
            return None
    
    @staticmethod
    def get_daily_summary(user_id, date=None):
        """Get daily summary"""
        try:
            if date is None:
                date = datetime.utcnow().date()
            
            summary = DailySummary.query.filter_by(
                user_id=user_id,
                date=date
            ).first()
            return summary
        except Exception as e:
            print(f"✗ Error fetching daily summary: {str(e)}")
            return None
    
    @staticmethod
    def get_user_weekly_summary(user_id):
        """Get weekly summary (last 7 days)"""
        try:
            today = datetime.utcnow().date()
            week_ago = today - timedelta(days=7)
            
            summaries = DailySummary.query.filter(
                and_(
                    DailySummary.user_id == user_id,
                    DailySummary.date >= week_ago,
                    DailySummary.date <= today
                )
            ).order_by(DailySummary.date.asc()).all()
            return summaries
        except Exception as e:
            print(f"✗ Error fetching weekly summary: {str(e)}")
            return []
    
    # ======================== RECOMMENDATION OPERATIONS ========================
    
    @staticmethod
    def add_recommendation(user_id, recommendation_text, category=None, priority='normal', expires_at=None):
        """Add a recommendation"""
        try:
            rec = Recommendation(
                user_id=user_id,
                recommendation_text=recommendation_text,
                category=category,
                priority=priority,
                status='active',
                expires_at=expires_at
            )
            db.session.add(rec)
            db.session.commit()
            print(f"✓ Recommendation added (ID: {rec.rec_id})")
            return rec
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error adding recommendation: {str(e)}")
            return None
    
    @staticmethod
    def get_user_recommendations(user_id, status='active'):
        """Get active recommendations for user"""
        try:
            recs = Recommendation.query.filter(
                and_(
                    Recommendation.user_id == user_id,
                    Recommendation.status == status
                )
            ).order_by(
                Recommendation.created_at.desc()
            ).all()
            return recs
        except Exception as e:
            print(f"✗ Error fetching recommendations: {str(e)}")
            return []
    
    # ======================== CHAT LOG OPERATIONS ========================
    
    @staticmethod
    def add_chat_log(user_id, user_message, bot_response, sentiment=None, session_id=None):
        """Add chat log entry"""
        try:
            chat = ChatLog(
                user_id=user_id,
                user_message=user_message,
                bot_response=bot_response,
                sentiment=sentiment,
                session_id=session_id
            )
            db.session.add(chat)
            db.session.commit()
            print(f"✓ Chat log added (ID: {chat.chat_id})")
            return chat
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error adding chat log: {str(e)}")
            return None
    
    @staticmethod
    def get_user_chat_logs(user_id, limit=50):
        """Get chat history for user"""
        try:
            logs = ChatLog.query.filter_by(user_id=user_id).order_by(
                ChatLog.created_at.desc()
            ).limit(limit).all()
            return logs
        except Exception as e:
            print(f"✗ Error fetching chat logs: {str(e)}")
            return []
    
    # ======================== ALERT OPERATIONS ========================
    
    @staticmethod
    def create_alert(user_id, alert_type, message, severity='info', expires_at=None):
        """Create an alert"""
        try:
            alert = Alert(
                user_id=user_id,
                alert_type=alert_type,
                message=message,
                severity=severity,
                is_read=False,
                expires_at=expires_at
            )
            db.session.add(alert)
            db.session.commit()
            print(f"✓ Alert created (ID: {alert.alert_id})")
            return alert
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error creating alert: {str(e)}")
            return None
    
    @staticmethod
    def get_user_alerts(user_id, unread_only=False):
        """Get alerts for user"""
        try:
            query = Alert.query.filter_by(user_id=user_id)
            if unread_only:
                query = query.filter_by(is_read=False)
            alerts = query.order_by(Alert.created_at.desc()).all()
            return alerts
        except Exception as e:
            print(f"✗ Error fetching alerts: {str(e)}")
            return []
    
    @staticmethod
    def mark_alert_as_read(alert_id):
        """Mark alert as read"""
        try:
            alert = Alert.query.get(alert_id)
            if alert:
                alert.is_read = True
                db.session.commit()
                return True
            return False
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error marking alert: {str(e)}")
            return False
    
    # ======================== AUDIT LOG OPERATIONS ========================
    
    @staticmethod
    def log_audit(user_id, action, table_name, record_id=None, old_values=None, new_values=None):
        """Create audit log entry"""
        try:
            audit = AuditLog(
                user_id=user_id,
                action=action,
                table_name=table_name,
                record_id=record_id,
                old_values=json.dumps(old_values) if old_values else None,
                new_values=json.dumps(new_values) if new_values else None
            )
            db.session.add(audit)
            db.session.commit()
            return audit
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error creating audit log: {str(e)}")
            return None
    
    @staticmethod
    def get_user_audit_logs(user_id, limit=50):
        """Get audit logs for user"""
        try:
            logs = AuditLog.query.filter_by(user_id=user_id).order_by(
                AuditLog.timestamp.desc()
            ).limit(limit).all()
            return logs
        except Exception as e:
            print(f"✗ Error fetching audit logs: {str(e)}")
            return []
