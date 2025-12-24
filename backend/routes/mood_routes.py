from flask import Blueprint, request, jsonify
from services.ml_service import ml_service
from services.db_service import insert_journal_entry, get_recommendation_for
from services.db_service import insert_mood_log, get_mood_logs_by_user, get_journal_entries_by_user


mood_bp = Blueprint('mood', __name__)


@mood_bp.route('/predict', methods=['POST'])
def predict():
    data = request.json
    user_id = data.get('user_id')
    text = data.get('text')
    if not text:
        return jsonify({'error': 'No text provided'}), 400


    emotion = ml_service.predict_emotion(text)
    # store as a journal entry (text + predicted emotion)
    if user_id:
        try:
            ok, err = insert_journal_entry(user_id, text, emotion)
        except Exception:
            ok, err = False, 'insert_failed'
    else:
        ok, err = False, 'missing_user_id'
# fetch recommendation
    recs = get_recommendation_for(emotion)
    return jsonify({
    'emotion': str(emotion),      # Convert to string
    'recommendations': recs
    }), 200




@mood_bp.route('/log', methods=['POST'])
def log_mood():
    """Save a full mood log. Expects JSON with keys: user_id (optional), mood_label, energy_level, activities (array), note (optional)"""
    data = request.json or {}
    print("➡️ /api/mood/log payload:", data)
    # Operate solely on user_id; firebase_uid removed
    user_id = data.get('user_id')
    mood_label = data.get('mood_label')
    energy_level = data.get('energy_level')
    activities = data.get('activities', [])
    note = data.get('note', '')

    if not mood_label:
        return jsonify({'error': 'mood_label is required'}), 400

    # serialize activities as comma-separated string for simplicity
    activities_serialized = ','.join(activities) if isinstance(activities, list) else str(activities)

    # Require a valid user_id to associate the mood with a user
    if not user_id:
        return jsonify({'error': 'user_id is required to associate the mood with a user'}), 400

    ok, err = insert_mood_log(user_id, mood_label, energy_level, activities_serialized, note)
    if not ok:
        return jsonify({'error': 'Failed to save mood log', 'detail': err}), 500
    return jsonify({'status': 'saved'}), 200





@mood_bp.route('/logs', methods=['GET'])
def fetch_logs():
    """Fetch mood logs for a user. Accepts query param: user_id"""
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'error': 'user_id is required'}), 400

    try:
        user_id_int = int(user_id)
    except Exception:
        return jsonify({'error': 'invalid user_id'}), 400

    rows = get_mood_logs_by_user(user_id_int)
    return jsonify(rows), 200



@mood_bp.route('/journals', methods=['GET'])
def fetch_journals():
    """Fetch journal entries for a user. Accepts query param: user_id"""
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'error': 'user_id is required'}), 400

    try:
        user_id_int = int(user_id)
    except Exception:
        return jsonify({'error': 'invalid user_id'}), 400

    rows = get_journal_entries_by_user(user_id_int)
    return jsonify(rows), 200
