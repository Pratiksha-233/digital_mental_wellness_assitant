from flask import Blueprint, jsonify, request
from services.db_service import get_recommendation_for, get_user_progress


rec_bp = Blueprint('recommend', __name__)


@rec_bp.route('/<emotion>', methods=['GET'])
def get_for(emotion):
    recs = get_recommendation_for(emotion)
    return jsonify({'recommendations': recs})


@rec_bp.route('/progress', methods=['GET'])
def progress():
    """Return progress counts for a user. Query string: ?user_id=123"""
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'error': 'user_id is required'}), 400
    try:
        user_id_int = int(user_id)
    except Exception:
        return jsonify({'error': 'invalid user_id'}), 400

    stats = get_user_progress(user_id_int)
    return jsonify({'progress': stats}), 200