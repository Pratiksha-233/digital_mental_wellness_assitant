from flask import Blueprint, request, jsonify
from datetime import datetime
import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).parent.parent))

try:
    from services.ml_service import ml_service
    _ML_AVAILABLE = True
except ImportError:
    _ML_AVAILABLE = False
    ml_service = None
from services.db_service import insert_journal_entry, insert_chat_message

# New: history + session summaries for review.
from services.db_service import (
    get_chat_history_by_user,
    get_chat_session_summaries_by_user,
)

chat_bp = Blueprint('chat', __name__)


# Simple, safe journaling prompts.
# These are intentionally non-clinical and avoid giving medical advice.
JOURNALING_PROMPTS = [
    "What’s one thing that felt heavy today, and what did you need in that moment?",
    "Name 3 emotions you felt today. What might each one be trying to tell you?",
    "What’s one small win from today—even if it felt tiny?",
    "If a close friend had your day, what would you say to them?",
    "What’s one worry you’re carrying? What’s one step you *can* take (however small)?",
    "What helped you cope in the past that you could try again this week?",
]


CRISIS_KEYWORDS = [
    'suicide',
    'kill myself',
    'hurt myself',
    'self harm',
    'self-harm',
    'end it all',
    'can\'t go on',
    'want to die',
    'wish I was dead',
    'wish I were dead',
    'overdose',
]


def _detect_crisis(text: str):
    lowered = text.lower()
    matched = [kw for kw in CRISIS_KEYWORDS if kw in lowered]
    return bool(matched), matched


def _classify_intent(text: str):
    t = text.lower()
    if any(w in t for w in ['hi', 'hello', 'hey']):
        return 'greeting'
    if any(w in t for w in ['sleep', 'insomnia', "can't sleep", 'cannot sleep', 'nightmare']):
        return 'sleep_issue'
    if any(w in t for w in ['anxious', 'anxiety', 'panic', 'overwhelmed', 'worried', 'worry']):
        return 'anxiety'
    if any(w in t for w in ['stress', 'stressed', 'burnout', 'pressure']):
        return 'stress'
    if any(w in t for w in ['motivation', 'unmotivated', 'lazy', 'procrast']):
        return 'motivation'
    if any(w in t for w in ['help', 'support']):
        return 'help_request'
    if any(w in t for w in ['tip', 'relax', 'breathe', 'exercise']):
        return 'relaxation_request'
    if any(w in t for w in ['thank', 'thanks']):
        return 'gratitude'
    return 'general_reflection'


def _build_response(user_message: str, analysis: dict, is_crisis: bool, intent: str):
    emotion = (analysis.get('emotion') or '').lower()
    sentiment = analysis.get('sentiment') or 'neutral'


    if is_crisis:
        return (
            "I'm really glad you told me. Your safety matters a lot. "
            "I am just an assistant and cannot provide emergency help. "
            "If you are in immediate danger or thinking about harming yourself, "
            "please contact your local emergency number or a crisis hotline right away, "
            "or reach out to a trusted person near you."
        )


    if intent == 'sleep_issue':
        return (
            "Sleep struggles can feel exhausting—thanks for telling me. "
            "A few gentle, practical things you can try tonight: keep lights low 60–90 minutes before bed, "
            "avoid caffeine late in the day, and do a slow breathing pattern (inhale 4, exhale 6) for 3–5 minutes. "
            "If your mind is racing, write down worries/to‑dos on paper, then return to the pillow. "
            "Do you want quick tips for falling asleep or for waking up during the night?"
        )

    if intent == 'anxiety':
        return (
            "That sounds really uncomfortable. Let’s try something that can lower the intensity quickly: "
            "do 5 slow breaths (in 4, out 6), then the 5‑4‑3‑2‑1 grounding exercise—name 5 things you see, "
            "4 you feel, 3 you hear, 2 you smell, and 1 you taste. "
            "If you want, tell me what’s triggering the anxiety right now and we can break it into smaller steps."
        )


    if sentiment == 'negative':
        if 'sad' in emotion or 'fear' in emotion:
            return (
                "I’m really sorry you’re feeling this way. You’re not alone in this. "
                "A couple of gentle ideas: try 4‑7‑8 breathing for a few minutes, "
                "or write down one thing that felt even slightly okay today."
            )
        if 'anger' in emotion:
            return (
                "Those feelings are valid. It may help to pause, relax your shoulders, "
                "and take 10 slow breaths. Afterwards, a short walk or stretching break "
                "can release some of that tension."
            )
        return (
            "Thank you for sharing how you feel. It might help to take a brief pause: "
            "uncross your legs, rest your feet on the floor, and breathe in for 4, hold for 4, "
            "out for 6 a few times. I can also suggest more self‑care ideas if you’d like."
        )

    if sentiment == 'positive':
        return (
            "I’m glad to hear some positive energy. You could reinforce it by doing "
            "one small thing that recharges you—like a short walk, listening to a favorite song, "
            "or sending a kind message to someone you care about."
        )


    return (
        "Thanks for opening up. I’m here to listen. If you want, "
        "I can suggest a quick relaxation technique or a small self‑care activity."
    )


@chat_bp.route('/message', methods=['POST'])
def message():
    data = request.json or {}
    user_id = data.get('user_id')
    user_message = (data.get('message') or '').strip()
    if not user_message:
        return jsonify({'error': 'No message'}), 400


    if not _ML_AVAILABLE:
        analysis = {'emotion': 'Unknown', 'sentiment': 'neutral', 'confidence': 0.0}
    else:
        analysis = ml_service.analyze_text(user_message)
    emotion = analysis.get('emotion', 'Unknown')
    sentiment = analysis.get('sentiment', 'neutral')
    confidence = float(analysis.get('confidence', 0.0) or 0.0)


    is_crisis, crisis_keywords = _detect_crisis(user_message)


    intent = _classify_intent(user_message)


    bot_response = _build_response(user_message, analysis, is_crisis, intent)


    if user_id:
        try:
            insert_chat_message(user_id, user_message, bot_response, emotion)
        except Exception:

            pass

    return jsonify(
        {
            'response': bot_response,
            'emotion': emotion,
            'sentiment': sentiment,
            'confidence': confidence,
            'is_crisis': is_crisis,
            'detected_crisis_keywords': crisis_keywords,
            'intent': intent,
        }
    )


@chat_bp.route('/history', methods=['GET'])
def history():
    """Return recent chat history for a user.

    Query params:
      - user_id (required)
      - limit (optional, default 100, max 500)

    Response:
      - messages: a flat list of message objects {role, text, timestamp, chat_id}
        built from the stored (user_message, bot_response) pairs.

    This supports real-world UX where users can reopen the chat and continue.
    """
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'error': 'user_id is required'}), 400

    try:
        user_id_int = int(user_id)
    except Exception:
        return jsonify({'error': 'invalid user_id'}), 400

    limit_raw = request.args.get('limit')
    try:
        limit = int(limit_raw) if limit_raw else 100
    except Exception:
        limit = 100
    limit = max(1, min(limit, 500))

    rows = get_chat_history_by_user(user_id_int, limit=limit)

    messages = []
    for r in rows:
        ts = r.get('timestamp')
        chat_id = r.get('chat_id')
        user_text = (r.get('user_message') or '').strip()
        bot_text = (r.get('bot_response') or '').strip()
        if user_text:
            messages.append(
                {
                    'role': 'user',
                    'text': user_text,
                    'timestamp': ts,
                    'chat_id': chat_id,
                }
            )
        if bot_text:
            messages.append(
                {
                    'role': 'assistant',
                    'text': bot_text,
                    'timestamp': ts,
                    'chat_id': chat_id,
                }
            )

    return jsonify({'messages': messages}), 200


@chat_bp.route('/sessions', methods=['GET'])
def sessions():
    """Return a light 'past sessions' list for review.

    For simplicity we treat each calendar day as a session.
    Query params:
      - user_id (required)
      - days (optional, default 30)
    """
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'error': 'user_id is required'}), 400

    try:
        user_id_int = int(user_id)
    except Exception:
        return jsonify({'error': 'invalid user_id'}), 400

    days_raw = request.args.get('days')
    try:
        days = int(days_raw) if days_raw else 30
    except Exception:
        days = 30
    days = max(1, min(days, 365))

    rows = get_chat_session_summaries_by_user(user_id_int, days=days)
    return jsonify({'sessions': rows}), 200


@chat_bp.route('/journal/prompt', methods=['GET'])
def journal_prompt():
    """Return a journaling prompt (no persistence)."""
    # Deterministic 'prompt of the day'.
    idx = (datetime.utcnow().toordinal()) % len(JOURNALING_PROMPTS)
    return jsonify({'prompt': JOURNALING_PROMPTS[idx]}), 200


@chat_bp.route('/journal', methods=['POST'])
def journal_save():
    """Save a journal entry.

    Body:
      - user_id (required)
      - text_entry (required)

    We store this in journal_entries and (optionally) run ML emotion tagging.
    """
    data = request.json or {}
    user_id = data.get('user_id')
    text_entry = (data.get('text_entry') or '').strip()
    if not user_id:
        return jsonify({'error': 'user_id is required'}), 400
    if not text_entry:
        return jsonify({'error': 'text_entry is required'}), 400

    try:
        user_id_int = int(user_id)
    except Exception:
        return jsonify({'error': 'invalid user_id'}), 400

    predicted_emotion = 'Unknown'
    if _ML_AVAILABLE:
        try:
            analysis = ml_service.analyze_text(text_entry)
            predicted_emotion = analysis.get('emotion') or 'Unknown'
        except Exception:
            predicted_emotion = 'Unknown'

    ok, err = insert_journal_entry(user_id_int, text_entry, predicted_emotion)
    if not ok:
        return jsonify({'error': 'Failed to save journal entry', 'detail': err}), 500
    return jsonify({'status': 'saved', 'predicted_emotion': predicted_emotion}), 200