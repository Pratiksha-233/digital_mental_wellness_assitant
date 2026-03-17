from flask import Blueprint, request, jsonify
import sys
from pathlib import Path

# Ensure project root (backend) is on sys.path so services can be imported
sys.path.insert(0, str(Path(__file__).parent.parent))

from services.ml_service import ml_service
from services.db_service import insert_face_detection_log
import base64
from io import BytesIO
import sys
from pathlib import Path

# Add models directory to path to import realtimedetection
models_path = Path(__file__).resolve().parent.parent / 'models'
sys.path.insert(0, str(models_path))

try:
    from PIL import Image, ImageOps
    import cv2
    from realtimedetection import predict_emotion_from_face, model as face_model, face_cascade
    _CV_AVAILABLE = True
except BaseException as e:
    print(f"Error importing: {e}")
    _CV_AVAILABLE = False
    face_model = None
    face_cascade = None

try:
    import numpy as np
    _NUMPY_AVAILABLE = True
except ImportError:
    _NUMPY_AVAILABLE = False
    np = None

try:
    from services.ml_service import ml_service
    _ML_AVAILABLE = True
except ImportError:
    _ML_AVAILABLE = False
    ml_service = None

detection_bp = Blueprint('detection', __name__)


@detection_bp.route('/predict-emotion', methods=['POST'])
def predict_emotion():
    """
    Predict emotion from text input
    Expects: {"text": "user text here"}
    Returns: {"emotion": "emotion_label"}
    """
    try:
        data = request.get_json()
        text = data.get('text', '').strip()
        
        if not text:
            return jsonify({'status': 'error', 'message': 'Text cannot be empty'}), 400
        
        if not _ML_AVAILABLE:
            return jsonify({'status': 'error', 'message': 'ML service not available'}), 503
        
        emotion = ml_service.predict_emotion(text)
        
        return jsonify({
            'status': 'success',
            'emotion': emotion,
            'text': text
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@detection_bp.route('/predict-image', methods=['POST'])
def predict_image():
    """
    Predict emotion from base64 encoded image using face recognition
    Expects: {"image": "base64_encoded_image", "user_id": 1}  # user_id optional, defaults to 1
    Returns: {"emotion": "emotion_label", "confidence": 0.95}
    """
    if not _CV_AVAILABLE:
        return jsonify({
            'status': 'error',
            'message': 'Image processing not available. OpenCV or PIL not installed.'
        }), 503
    
    if face_model is None:
        return jsonify({
            'status': 'error',
            'message': 'Face emotion detection model not loaded.'
        }), 503

    if face_cascade is None or getattr(face_cascade, 'empty', lambda: True)():
        return jsonify({
            'status': 'error',
            'message': 'Face detector not available (Haar cascade not loaded).'
        }), 503
    
    try:
        data = request.get_json()
        image_data = data.get('image', '').strip()
        user_id = data.get('user_id', 1)  # default to user 1 if not provided
        
        if not image_data:
            return jsonify({'status': 'error', 'message': 'Image data cannot be empty'}), 400
        
        # Decode base64 image
        try:
            # Handle data URL format
            if image_data.startswith('data:image'):
                image_data = image_data.split(',')[1]
            
            image_bytes = base64.b64decode(image_data)
            # Respect EXIF orientation (common on mobile/webcam captures)
            img = Image.open(BytesIO(image_bytes))
            img = ImageOps.exif_transpose(img).convert('RGB')
            if not _NUMPY_AVAILABLE:
                return jsonify({'status': 'error', 'message': 'NumPy not available'}), 503
            img_array = np.array(img)
        except Exception as e:
            return jsonify({'status': 'error', 'message': f'Invalid image format: {str(e)}'}), 400
        
        # Convert to grayscale for face detection
        gray0 = cv2.cvtColor(img_array, cv2.COLOR_RGB2GRAY)
        img_h, img_w = gray0.shape[:2]

        # Optional downscale to speed up detection while keeping enough detail
        scale = 1.0
        max_dim = max(img_h, img_w)
        if max_dim > 900:
            scale = 900.0 / float(max_dim)
            new_w = max(1, int(img_w * scale))
            new_h = max(1, int(img_h * scale))
            gray = cv2.resize(gray0, (new_w, new_h), interpolation=cv2.INTER_AREA)
        else:
            gray = gray0

        # Improve contrast for more robust Haar detection
        try:
            clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
            gray = clahe.apply(gray)
        except Exception:
            gray = cv2.equalizeHist(gray)

        # Dynamic minimum face size (helps reduce false negatives on high-res images)
        min_side = min(gray.shape[0], gray.shape[1])
        min_face = max(30, int(min_side * 0.12))

        # Detect faces (tuned for better accuracy than the previous defaults)
        faces = face_cascade.detectMultiScale(
            gray,
            scaleFactor=1.15,
            minNeighbors=6,
            minSize=(min_face, min_face),
        )

        # Convert face boxes back to original image coordinates if we downscaled
        faces_scaled = []
        for (x, y, w, h) in faces:
            if scale != 1.0:
                x = int(x / scale)
                y = int(y / scale)
                w = int(w / scale)
                h = int(h / scale)
            faces_scaled.append((int(x), int(y), int(w), int(h)))

        # Prefer the largest face (most likely the primary subject)
        faces_scaled.sort(key=lambda b: b[2] * b[3], reverse=True)
        
        if len(faces_scaled) == 0:
            # Still log if no face detected
            insert_face_detection_log(user_id, 'No face detected', 0.0, 0, 'image')
            return jsonify({
                'status': 'success',
                'emotion': 'No face detected',
                'faces_detected': 0,
                'confidence': 0.0,
                'image_width': int(img_w),
                'image_height': int(img_h),
                'faces': [],
            }), 200
        
        # Process first face and get emotion
        x, y, w, h = faces_scaled[0]
        # Guard bounds
        x0 = max(0, x)
        y0 = max(0, y)
        x1 = min(img_w, x + w)
        y1 = min(img_h, y + h)
        face_roi = gray0[y0:y1, x0:x1]
        
        # Use the face emotion detection model
        emotion, confidence = predict_emotion_from_face(face_roi)
        
        # Insert into database
        insert_face_detection_log(user_id, emotion, confidence, len(faces_scaled), 'image')

        faces_payload = [
            {'x': int(fx), 'y': int(fy), 'w': int(fw), 'h': int(fh)}
            for (fx, fy, fw, fh) in faces_scaled
        ]
        
        return jsonify({
            'status': 'success',
            'emotion': emotion,
            'faces_detected': len(faces_scaled),
            'confidence': confidence,
            'image_width': int(img_w),
            'image_height': int(img_h),
            'faces': faces_payload,
        }), 200
    
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500
