"""Voice Input API Routes

Endpoints for processing voice/audio input and converting to text.
"""

from flask import Blueprint, request, jsonify
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

try:
    from services.ml_service import ml_service
    _ML_AVAILABLE = True
except ImportError:
    _ML_AVAILABLE = False
    ml_service = None

voice_bp = Blueprint('voice', __name__)


@voice_bp.route('/transcribe', methods=['POST'])
def transcribe_audio():
    """
    Transcribe audio file to text.
    
    Expects multipart form data:
      - 'audio': audio file (WAV, MP3, OGG, etc.)
      - 'language' (optional): language code (default: 'en-US')
    
    Returns:
        {
            "status": "success",
            "text": "transcribed text from audio",
            "language": "en-US",
            "confidence": 0.95
        }
    """
    if 'audio' not in request.files:
        return jsonify({'error': 'No audio file provided'}), 400
    
    audio_file = request.files['audio']
    if audio_file.filename == '':
        return jsonify({'error': 'No audio file selected'}), 400
    
    try:
        from io import BytesIO
        import numpy as np
        
        # Read audio file
        audio_data = BytesIO(audio_file.read())
        
        # Try to use SpeechRecognition library
        try:
            import speech_recognition as sr
            
            recognizer = sr.Recognizer()
            with sr.AudioFile(audio_data) as source:
                audio = recognizer.record(source)
            
            try:
                text = recognizer.recognize_google(audio)
                confidence = 0.95  # Google API doesn't return confidence
                
                return jsonify({
                    'status': 'success',
                    'text': text,
                    'language': request.form.get('language', 'en-US'),
                    'confidence': confidence,
                }), 200
            except sr.UnknownValueError:
                return jsonify({
                    'status': 'error',
                    'message': 'Could not understand audio'
                }), 400
            except sr.RequestError as e:
                return jsonify({
                    'status': 'error',
                    'message': f'Speech recognition service error: {str(e)}'
                }), 503
        
        except ImportError:
            # Fallback: return placeholder if library not available
            return jsonify({
                'status': 'error',
                'message': 'Speech recognition not available. Install: pip install SpeechRecognition pydub'
            }), 503
    
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Error processing audio: {str(e)}'
        }), 500


@voice_bp.route('/predict-voice', methods=['POST'])
def predict_voice():
    """
    Process voice input and predict emotion/intent from transcribed text.
    
    Expects multipart form data:
      - 'audio': audio file (WAV, MP3, OGG, etc.)
      - 'user_id' (optional): user ID for logging
      - 'language' (optional): language code (default: 'en-US')
    
    Returns:
        {
            "status": "success",
            "text": "transcribed text",
            "emotion": "detected emotion",
            "sentiment": "positive/negative/neutral",
            "intent": "detected intent",
            "confidence": 0.92,
            "is_crisis": false
        }
    """
    if 'audio' not in request.files:
        return jsonify({'error': 'No audio file provided'}), 400
    
    audio_file = request.files['audio']
    if audio_file.filename == '':
        return jsonify({'error': 'No audio file selected'}), 400
    
    try:
        from io import BytesIO
        
        # Step 1: Transcribe audio to text
        audio_data = BytesIO(audio_file.read())
        
        try:
            import speech_recognition as sr
            
            recognizer = sr.Recognizer()
            with sr.AudioFile(audio_data) as source:
                audio = recognizer.record(source)
            
            try:
                transcribed_text = recognizer.recognize_google(audio)
            except sr.UnknownValueError:
                return jsonify({
                    'status': 'error',
                    'message': 'Could not understand audio'
                }), 400
            except sr.RequestError as e:
                return jsonify({
                    'status': 'error',
                    'message': f'Speech recognition service error: {str(e)}'
                }), 503
        
        except ImportError:
            return jsonify({
                'status': 'error',
                'message': 'Speech recognition not available'
            }), 503
        
        # Step 2: Analyze the transcribed text
        if not _ML_AVAILABLE:
            return jsonify({'error': 'ML service not available'}), 503
        
        # Use existing ML service to analyze text
        analysis = ml_service.analyze_text(transcribed_text)
        
        # Step 3: Return combined result
        return jsonify({
            'status': 'success',
            'text': transcribed_text,
            'emotion': analysis.get('emotion'),
            'sentiment': analysis.get('sentiment'),
            'intent': analysis.get('intent'),
            'confidence': analysis.get('confidence', 0.0),
            'is_crisis': analysis.get('is_crisis', False),
        }), 200
    
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Error processing voice input: {str(e)}'
        }), 500
