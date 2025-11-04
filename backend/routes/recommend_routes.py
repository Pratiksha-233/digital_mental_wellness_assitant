from flask import Blueprint, jsonify
from services.db_service import get_recommendation_for


rec_bp = Blueprint('recommend', __name__)


@rec_bp.route('/<emotion>', methods=['GET'])
def get_for(emotion):
    recs = get_recommendation_for(emotion)
    return jsonify({'recommendations': recs})