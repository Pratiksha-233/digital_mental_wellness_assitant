from flask import Blueprint, request, jsonify
import sys
from pathlib import Path

# Ensure project root (backend) is on sys.path so services can be imported
sys.path.insert(0, str(Path(__file__).parent.parent))

from services.ml_service import ml_service
from services.db_service import insert_journal_entry

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
    # store chat as a journal entry (text + predicted emotion)
    if user_id:
        try:
            insert_journal_entry(user_id, user_message, emotion)
        except Exception:
            pass
    return jsonify({'response': bot_response, 'emotion': emotion})