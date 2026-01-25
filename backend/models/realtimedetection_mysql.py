import os
import cv2
from keras.models import model_from_json
import numpy as np
from collections import deque
import time
from datetime import datetime
import json

# MySQL connector
try:
    import mysql.connector
except Exception as e:
    raise ImportError("mysql.connector is required. Install with 'pip install mysql-connector-python'") from e

# Try loading DB config from backend.config or environment
def _load_db_config():
    cfg = None
    try:
        # attempt import from backend.config
        from backend import config as backend_config  # type: ignore
        cfg = getattr(backend_config, "DB_CONFIG", None) or getattr(backend_config, "DATABASE_CONFIG", None)
    except Exception:
        try:
            import config as cfg_module  # type: ignore
            cfg = getattr(cfg_module, "DB_CONFIG", None) or getattr(cfg_module, "DATABASE_CONFIG", None)
        except Exception:
            cfg = None

    if not cfg:
        cfg = {
            "host": os.getenv("DB_HOST", "localhost"),
            "user": os.getenv("DB_USER", "root"),
            "password": os.getenv("DB_PASSWORD", "nayan@337"),
            "database": os.getenv("DB_NAME", "mental_wellness"),
            "port": int(os.getenv("DB_PORT", "3306")),
            "raise_on_warnings": True,
            "autocommit": False
        }
    return cfg

DB_CONFIG = _load_db_config()

def get_mysql_connection():
    return mysql.connector.connect(
        host=DB_CONFIG.get("host"),
        user=DB_CONFIG.get("user"),
        password=DB_CONFIG.get("password"),
        database=DB_CONFIG.get("database"),
        port=DB_CONFIG.get("port"),
        raise_on_warnings=DB_CONFIG.get("raise_on_warnings", True)
    )

# ============================================================================
# DATABASE CONNECTION - FETCH USER FROM MySQL (mental_wellness)
# ============================================================================
def get_current_user():
    """Fetch current logged-in user from MySQL mental_wellness database"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT user_id, username, email FROM users1 ORDER BY last_login DESC LIMIT 1"
        )
        result = cursor.fetchone()
        cursor.close()
        conn.close()

        if result:
            return {"user_id": result[0], "username": result[1], "email": result[2]}
        else:
            return create_default_user()
    except Exception as e:
        print(f"Error fetching user: {e}")
        return create_default_user()

def create_default_user():
    """Create default user if none exists"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO users1 (username, email, created_at) VALUES (%s, %s, NOW())",
            ("default_user", "default@mentalwellness.com"),
        )
        conn.commit()
        user_id = cursor.lastrowid
        cursor.close()
        conn.close()
        return {"user_id": user_id, "username": "default_user", "email": "default@mentalwellness.com"}
    except Exception as e:
        print(f"Error creating default user: {e}")
        return None

# ============================================================================
# GET CURRENT USER
# ============================================================================
current_user = get_current_user()
if not current_user:
    print("Failed to get user. Exiting...")
    exit()

print(f"\n✓ User: {current_user['username']} (ID: {current_user['user_id']})")
print(f"✓ Email: {current_user['email']}\n")

# ============================================================================
# CREATE SESSION IN DATABASE (MySQL)
# ============================================================================
def create_emotion_session(user_id, username):
    """Create emotion detection session in MySQL database"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO emotion_sessions (user_id, username, session_start, session_status, device_type) "
            "VALUES (%s, %s, NOW(), %s, %s)",
            (user_id, username, "active", "webcam"),
        )
        conn.commit()
        session_id = cursor.lastrowid
        cursor.close()
        conn.close()
        return session_id
    except Exception as e:
        print(f"Error creating session: {e}")
        return None

# ============================================================================
# STORE EMOTION IN DATABASE (MySQL)
# ============================================================================
def store_emotion_to_db(session_id, user_id, username, emotion_type, confidence, duration, intensity_level="medium"):
    """Store detected emotion to MySQL database"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO emotion_data (session_id, user_id, username, emotion_type, confidence, duration_seconds, intensity_level, detected_at) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, NOW())",
            (session_id, user_id, username, emotion_type, float(confidence), float(duration), intensity_level),
        )
        conn.commit()
        emotion_id = cursor.lastrowid
        cursor.close()
        conn.close()
        return emotion_id
    except Exception as e:
        print(f"Error storing emotion: {e}")
        return None

# ============================================================================
# END SESSION IN DATABASE (MySQL)
# ============================================================================
def end_emotion_session(session_id):
    """End emotion detection session in MySQL database"""
    try:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE emotion_sessions SET session_end = NOW(), session_status = %s WHERE session_id = %s",
            ("completed", session_id),
        )
        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print(f"Error ending session: {e}")
        return False

# ============================================================================
# LOAD MODEL
# ============================================================================
json_file = open("C:/Users/attar/new file/digital_mental_wellness_assitant/emotiondetecter2.json", "r")
model_json = json_file.read()
json_file.close()
model = model_from_json(model_json)
model.load_weights("C:/Users/attar/new file/digital_mental_wellness_assitant/emotiondetecter2.h5")
# Load face cascade
haar_file = cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
face_cascade = cv2.CascadeClassifier(haar_file)

# ============================================================================
# EMOTION LABELS
# ============================================================================
labels = {0: "angry", 1: "disgust", 2: "fear", 3: "happy", 4: "neutral", 5: "sad", 6: "surprise"}

# ============================================================================
# CONFIGURATION PARAMETERS
# ============================================================================
CONFIDENCE_THRESHOLD = 0.6
SMOOTHING_WINDOW = 5
STABLE_FRAME_COUNT = 10
MIN_EMOTION_TIME = 2

# ============================================================================
# EXTRACT FEATURES FUNCTION
# ============================================================================
def extract_features(image):
    feature = np.array(image)
    feature = feature.reshape(1, 48, 48, 1)
    return feature / 255.0

# ============================================================================
# ENHANCED EMOTION BUFFER WITH DATABASE STORAGE
# ============================================================================
class EmotionBuffer:
    def __init__(self, window_size=5, session_id=None, user_id=None, username=None):
        self.buffer = deque(maxlen=window_size)
        self.stable_count = 0
        self.current_emotion = None
        self.emotion_start_time = None
        self.stored_emotions = []
        self.session_id = session_id
        self.user_id = user_id
        self.username = username
        self.last_stored_emotion = None
        self.emotion_count = 0

    def add_prediction(self, emotion, confidence):
        """Add prediction to buffer"""
        if confidence < CONFIDENCE_THRESHOLD:
            return None

        self.buffer.append(emotion)

        if len(self.buffer) > 0:
            most_common = max(set(self.buffer), key=list(self.buffer).count)

            if most_common == self.current_emotion:
                self.stable_count += 1
            else:
                self.current_emotion = most_common
                self.stable_count = 1
                self.emotion_start_time = time.time()

            if self.stable_count >= STABLE_FRAME_COUNT:
                return most_common

        return None

    def store_emotion(self, emotion):
        """Store emotion to database"""
        if self.emotion_start_time and emotion != self.last_stored_emotion:
            duration = time.time() - self.emotion_start_time
            if duration >= MIN_EMOTION_TIME:
                try:
                    # Determine intensity level
                    if duration > 10:
                        intensity = "high"
                    elif duration > 5:
                        intensity = "medium"
                    else:
                        intensity = "low"

                    # Store to database
                    emotion_id = store_emotion_to_db(
                        session_id=self.session_id,
                        user_id=self.user_id,
                        username=self.username,
                        emotion_type=emotion,
                        confidence=0.85,
                        duration=duration,
                        intensity_level=intensity,
                    )

                    if emotion_id:
                        self.stored_emotions.append(
                            {
                                "emotion": emotion,
                                "timestamp": self.emotion_start_time,
                                "duration": duration,
                                "confidence": "high",
                                "id": emotion_id,
                            }
                        )
                        self.last_stored_emotion = emotion
                        self.emotion_count += 1
                        return True
                except Exception as e:
                    print(f"Error storing emotion: {e}")
        return False

    def get_stored_emotions(self):
        """Get all stored emotions"""
        return self.stored_emotions

    def reset(self):
        """Reset buffer"""
        self.buffer.clear()
        self.stable_count = 0
        self.current_emotion = None
        self.emotion_start_time = None

# ============================================================================
# INITIALIZE SESSION AND BUFFER
# ============================================================================
session_id = create_emotion_session(current_user["user_id"], current_user["username"])
if not session_id:
    print("Failed to create session. Exiting...")
    exit()

print(f"✓ Session created (ID: {session_id})\n")

emotion_buffer = EmotionBuffer(
    window_size=SMOOTHING_WINDOW,
    session_id=session_id,
    user_id=current_user["user_id"],
    username=current_user["username"],
)

# ============================================================================
# START WEBCAM
# ============================================================================
webcam = cv2.VideoCapture(0)
frame_count = 0
fps_counter = 0
fps_time = time.time()

print("Starting emotion detection... Press 'q' to quit\n")

while True:
    ret, im = webcam.read()

    if not ret:
        print("Error: Cannot read frame from webcam")
        break

    im = cv2.resize(im, (640, 480))
    gray = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, 1.3, 5)

    frame_count += 1
    fps_counter += 1

    if time.time() - fps_time > 1:
        fps = fps_counter
        fps_counter = 0
        fps_time = time.time()

    try:
        if len(faces) > 0:
            for (p, q, r, s) in faces:
                image = gray[q : q + s, p : p + r]
                cv2.rectangle(im, (p, q), (p + r, q + s), (255, 0, 0), 2)

                image = cv2.resize(image, (48, 48))
                img = extract_features(image)

                pred = model.predict(img, verbose=0)
                confidence = pred.max()
                predicted_emotion = labels[pred.argmax()]

                stable_emotion = emotion_buffer.add_prediction(predicted_emotion, confidence)

                # Display unstable prediction
                display_text = f"{predicted_emotion} ({confidence*100:.1f}%)"
                cv2.putText(im, display_text, (p - 10, q - 30), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1, (0, 255, 255), 1)

                # Display stable emotion
                if stable_emotion:
                    cv2.putText(im, f"STABLE: {stable_emotion}", (p - 10, q - 10), cv2.FONT_HERSHEY_COMPLEX_SMALL, 2, (0, 255, 0), 2)
                    emotion_buffer.store_emotion(stable_emotion)

        # Display user info
        cv2.putText(im, f"User: {current_user['username']}", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 0), 2)

        cv2.putText(im, f"FPS: {fps}", (10, 70), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)

        stored_count = emotion_buffer.emotion_count
        cv2.putText(im, f"Emotions Stored: {stored_count}", (10, 110), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)

        cv2.putText(im, "Press 'q' to quit | 's' to view emotions", (10, 450), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (200, 200, 200), 1)

        cv2.imshow("Emotion Detection - Real Time", im)

        key = cv2.waitKey(1) & 0xFF
        if key == ord("q"):
            print("\nExiting...")
            break
        elif key == ord("s"):
            stored_emotions = emotion_buffer.get_stored_emotions()
            if stored_emotions:
                print("\n" + "=" * 70)
                print(f"STORED EMOTIONS FOR: {current_user['username']}")
                print("=" * 70)
                for idx, data in enumerate(stored_emotions, 1):
                    print(f"{idx}. Emotion: {data['emotion'].upper()}")
                    print(f"   Timestamp: {time.ctime(data['timestamp'])}")
                    print(f"   Duration: {data['duration']:.2f}s")
                    print(f"   Confidence: {data['confidence']}")
                    print(f"   Database ID: {data['id']}")
                print("=" * 70)
            else:
                print("No emotions stored yet!")

    except cv2.error as e:
        print(f"OpenCV Error: {e}")
        continue
    except Exception as e:
        print(f"Error: {e}")
        continue

# ============================================================================
# CLEANUP AND FINAL REPORT
# ============================================================================
webcam.release()
cv2.destroyAllWindows()

# End session
end_emotion_session(session_id)

print("\n" + "=" * 70)
print("SESSION SUMMARY")
print("=" * 70)
print(f"User: {current_user['username']}")
print(f"Session ID: {session_id}")

stored_emotions = emotion_buffer.get_stored_emotions()
if stored_emotions:
    print(f"Total emotions detected: {len(stored_emotions)}")
    print("\nEmotion Breakdown:")
    for idx, data in enumerate(stored_emotions, 1):
        print(f"{idx}. {data['emotion'].upper()} - Duration: {data['duration']:.2f}s")
else:
    print("No emotions were stored during the session")

print("=" * 70)
print("✓ Session saved to database successfully!")