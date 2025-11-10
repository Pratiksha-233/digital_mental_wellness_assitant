from flask import Blueprint, request, jsonify
from services.ml_service import ml_service
from services.db_service import insert_mood_log, get_recommendation_for


mood_bp = Blueprint('mood', __name__)


@mood_bp.route('/predict', methods=['POST'])
def predict():
    data = request.json
    user_id = data.get('user_id')
    text = data.get('text')
    if not text:
        return jsonify({'error': 'No text provided'}), 400


    emotion = ml_service.predict_emotion(text)
# store
    insert_mood_log(user_id, text, emotion)
# fetch recommendation
    recs = get_recommendation_for(emotion)
    return jsonify({
    'emotion': str(emotion),      # Convert to string
    'recommendations': recs
    }), 200
