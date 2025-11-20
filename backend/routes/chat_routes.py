from flask import Blueprint, request, jsonify
from services.ml_service import ml_service
from services.db_service import insert_mood_log

chat_bp = Blueprint('chat', __name__)


@chat_bp.route('/message', methods=['POST'])
def message():
    data = request.json
    user_id = data.get('user_id')
    user_message = data.get('message')
    if not user_message:
        return jsonify({'error': 'No message'}), 400


    emotion = ml_service.predict_emotion(user_message)
# very simple bot: respond based on emotion
    responses = {
        'Anxiety': 'I hear you. Try a breathing exercise for 3 minutes.',
        'Sad': 'I am sorry you feel that way — would you like some calming exercises?',
        'Angry': 'It might help to step away and breathe for a moment.',
        'Happy': 'That is great to hear! Keep it up.'
        }


    bot_response = responses.get(emotion, 'Thanks for sharing — I am here to listen.')
# store chat
    insert_mood_log(user_id, user_message, emotion)
    return jsonify({'response': bot_response, 'emotion': emotion})