from flask import Blueprint, request, jsonify
import sys
from pathlib import Path

# Ensure project root (backend) is on sys.path so services can be imported
sys.path.insert(0, str(Path(__file__).parent.parent))

try:
    from services.ml_service import ml_service
    _ML_AVAILABLE = True
except ImportError:
    _ML_AVAILABLE = False
    ml_service = None
from services.db_service import insert_journal_entry, insert_chat_message

chat_bp = Blueprint('chat', __name__)


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

    # Crisis‑aware response always takes priority
    if is_crisis:
        return (
            "I'm really glad you told me. Your safety matters a lot. "
            "I am just an assistant and cannot provide emergency help. "
            "If you are in immediate danger or thinking about harming yourself, "
            "please contact your local emergency number or a crisis hotline right away, "
            "or reach out to a trusted person near you."
        )

    # Intent-specific responses take priority over coarse sentiment.
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

    # Relaxation & motivational style replies
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

    # Neutral / mixed sentiment
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

    # Core NLP analysis (emotion + sentiment)
    if not _ML_AVAILABLE:
        analysis = {'emotion': 'Unknown', 'sentiment': 'neutral', 'confidence': 0.0}
    else:
        analysis = ml_service.analyze_text(user_message)
    emotion = analysis.get('emotion', 'Unknown')
    sentiment = analysis.get('sentiment', 'neutral')
    confidence = float(analysis.get('confidence', 0.0) or 0.0)

    # Crisis word detection
    is_crisis, crisis_keywords = _detect_crisis(user_message)

    # Simple intent classification based on keywords
    intent = _classify_intent(user_message)

    # Build motivational / relaxation‑oriented response
    bot_response = _build_response(user_message, analysis, is_crisis, intent)

    # Store chat as journal entry and structured chat history (if we know the user)
    if user_id:
        try:
            insert_journal_entry(user_id, user_message, emotion)
        except Exception:
            # journal insertion is best‑effort only
            pass
        try:
            insert_chat_message(user_id, user_message, bot_response, emotion)
        except Exception:
            # chat_history persistence is also best‑effort
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