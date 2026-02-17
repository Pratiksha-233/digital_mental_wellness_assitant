from flask import Blueprint, request, jsonify
import sys
from pathlib import Path

# Ensure project root (backend) is on sys.path so services can be imported
sys.path.insert(0, str(Path(__file__).parent.parent))

from services.ml_service import ml_service
import base64
import numpy as np
from io import BytesIO
import sys
from pathlib import Path

# Add models directory to path to import realtimedetection
models_path = Path(__file__).resolve().parent.parent / 'models'
sys.path.insert(0, str(models_path))

try:
    from PIL import Image
    import cv2
    from realtimedetection import predict_emotion_from_face, model as face_model, face_cascade
    _CV_AVAILABLE = True
except Exception as e:
    print(f"Error importing: {e}")
    _CV_AVAILABLE = False
    face_model = None
    face_cascade = None

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
    Expects: {"image": "base64_encoded_image"}
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
    
    try:
        data = request.get_json()
        image_data = data.get('image', '').strip()
        
        if not image_data:
            return jsonify({'status': 'error', 'message': 'Image data cannot be empty'}), 400
        
        # Decode base64 image
        try:
            # Handle data URL format
            if image_data.startswith('data:image'):
                image_data = image_data.split(',')[1]
            
            image_bytes = base64.b64decode(image_data)
            img = Image.open(BytesIO(image_bytes)).convert('RGB')
            img_array = np.array(img)
        except Exception as e:
            return jsonify({'status': 'error', 'message': f'Invalid image format: {str(e)}'}), 400
        
        # Convert to grayscale for face detection
        gray = cv2.cvtColor(img_array, cv2.COLOR_RGB2GRAY)
        
        # Detect faces
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5, minSize=(30, 30))
        
        if len(faces) == 0:
            return jsonify({
                'status': 'success',
                'emotion': 'No face detected',
                'faces_detected': 0,
                'confidence': 0.0
            }), 200
        
        # Process first face and get emotion
        x, y, w, h = faces[0]
        face_roi = gray[y:y+h, x:x+w]
        
        # Use the face emotion detection model
        emotion, confidence = predict_emotion_from_face(face_roi)
        
        return jsonify({
            'status': 'success',
            'emotion': emotion,
            'faces_detected': len(faces),
            'confidence': confidence
        }), 200
    
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500
