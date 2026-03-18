try:
    import numpy as np
    import pickle
    import os
    from pathlib import Path
    try:
        from tensorflow.keras.models import load_model, model_from_json
        from tensorflow.keras.preprocessing.sequence import pad_sequences
        _TF_AVAILABLE = True
    except Exception:
        _TF_AVAILABLE = False
    NUMPY_AVAILABLE = True
except ImportError:
    NUMPY_AVAILABLE = False
    _TF_AVAILABLE = False
    np = None
    pickle = None
    os = None
    Path = None


class MLService:
    def __init__(self):
        if os is None:
            return
        self.model = None  # Text sentiment model
        self.face_model = None  # Face emotion detection model
        self.tokenizer = None
        self.label_encoder = None
        self.max_len = 100
        
        # Labels for text sentiment
        self.label_map = {
            0: "Sadness",
            1: "Joy",
            2: "Love",
            3: "Anger",
            4: "Fear",
            5: "Surprise"
        }
        
        # Labels for face emotion detection
        self.face_emotion_map = {
            0: 'angry',
            1: 'disgust',
            2: 'fear',
            3: 'happy',
            4: 'neutral',
            5: 'sad',
            6: 'surprise'
        }

        if os is not None:
            cwd = Path(os.getcwd())
        else:
            cwd = None
        svc_dir = Path(__file__).resolve().parent
        project_backend = svc_dir.parent
        project_root = project_backend.parent
        
        # Load text sentiment model
        candidates = [
            project_backend / 'models' / 'sentiment_model.h5',
            project_backend / 'models' / 'models' / 'sentiment_model.h5',
        ]
        if cwd is not None:
            candidates.append(cwd / 'models' / 'sentiment_model.h5')

        tokenizer_path = project_backend / 'models' / 'tokenizer.pkl'
        encoder_path = project_backend / 'models' / 'label_encoder.pkl'

        if not _TF_AVAILABLE:
            print("[WARNING] TensorFlow/Keras not available. ML features will be disabled.")
            return

        # Load text sentiment model
        print(f"[INFO] Looking for sentiment model in {len(candidates)} candidate locations...")
        found = False
        last_exc = None
        for p in candidates:
            try:
                p = p.resolve()
            except Exception:
                p = Path(p)

            if not p.exists():
                print(f"[SKIP] Candidate not found: {p}")
                continue

            try:
                size = p.stat().st_size
            except Exception:
                size = 0

            if size < 100:
                print(f"[WARNING] Candidate file exists but is suspiciously small ({size} bytes): {p}")

            try:
                print(f"[ATTEMPT] Attempting to load sentiment model from: {p}")
                self.model = load_model(str(p), compile=False)
                print(f"[SUCCESS] Loaded sentiment model from: {p}")
                found = True
                break
            except Exception as e:
                print(f"[FAILED] Failed loading from {p}: {e}")
                last_exc = e

        # Load face emotion detection model
        try:
            face_json_path = project_root / 'emotiondetecter1.json'
            face_weights_path = project_root / 'emotiondetecter1.h5'
            
            if face_json_path.exists() and face_weights_path.exists():
                print(f"[ATTEMPT] Loading face emotion model from: {face_json_path}")
                with open(face_json_path, 'r') as json_file:
                    model_json = json_file.read()
                self.face_model = model_from_json(model_json)
                self.face_model.load_weights(str(face_weights_path))
                print("[SUCCESS] Face emotion detection model loaded successfully")
            else:
                print("[WARNING] Face emotion model files not found")
        except Exception as e:
            print(f"[FAILED] Error loading face emotion model: {e}")

        # load tokenizer and encoder if sentiment model loaded
        if found:
            try:
                # prefer tokenizer/encoder next to the loaded model
                model_dir = p.parent if p is not None else project_backend / 'models'
                # check model parent folder first
                candidates_tok = [model_dir / 'tokenizer.pkl', project_backend / 'models' / 'tokenizer.pkl']
                candidates_enc = [p.parent / 'label_encoder.pkl', project_backend / 'models' / 'label_encoder.pkl']

                for tp in candidates_tok:
                    if tp.exists():
                        with open(tp, 'rb') as f:
                            self.tokenizer = pickle.load(f)
                        break
                else:
                    print(f"[WARNING] Tokenizer not found in candidates: {candidates_tok}")

                for ep in candidates_enc:
                    if ep.exists():
                        with open(ep, 'rb') as f:
                            self.label_encoder = pickle.load(f)
                        break
                else:
                    print(f"[WARNING] Label encoder not found in candidates: {candidates_enc}")

                print("[SUCCESS] Model and preprocessing loaded.")
            except Exception as e:
                print("[FAILED] Error loading tokenizer/encoder:", e)
        else:
            print("[FAILED] Could not load any model candidate.")
            if last_exc is not None:
                print("Last error:", last_exc)
            print("Hint: run the training script to (re)create a compatible model, or place a valid Keras .h5 or SavedModel under backend/models/")

    def analyze_text(self, text):
        """Run text through the sentiment model and return
        a small analysis bundle used by the chatbot.

        Returns a dict with keys:
          - emotion: fine‑grained emotion label from the model
          - sentiment: 'positive' | 'negative' | 'neutral'
          - confidence: float probability of the predicted emotion
        """
        if np is None:
            return {
                'emotion': 'Unknown',
                'sentiment': 'neutral',
                'confidence': 0.0,
            }
        if not self.model or not self.tokenizer:
            print("[WARNING] ML model not loaded; returning fallback neutral analysis")
            return {
                'emotion': 'Neutral',
                'sentiment': 'neutral',
                'confidence': 0.0,
            }

        try:
            lowered = (text or '').lower()
            seq = self.tokenizer.texts_to_sequences([text])
            padded = pad_sequences(seq, maxlen=self.max_len, padding='post')
            preds = self.model.predict(padded, verbose=0)
            label_index = int(np.argmax(preds))
            emotion = self.label_map.get(label_index, "Unknown")
            confidence = float(np.max(preds))

            # Map fine‑grained emotion to coarse sentiment
            negative_emotions = {"Sadness", "Anger", "Fear"}
            # NOTE: 'Surprise' is not reliably positive for wellness contexts.
            positive_emotions = {"Joy", "Love"}

            if emotion in positive_emotions:
                sentiment = 'positive'
            elif emotion in negative_emotions:
                sentiment = 'negative'
            else:
                sentiment = 'neutral'

            # Lightweight keyword-based overrides to improve reliability
            # for common wellness topics where the model can be noisy.
            sleep_keywords = [
                "insomnia",
                "can't sleep",
                "cannot sleep",
                "cant sleep",
                "sleepless",
                "sleep problem",
                "sleeping problem",
                "trouble sleeping",
                "wake up",
                "waking up",
                "nightmare",
                "nightmares",
            ]
            anxiety_keywords = [
                "anxious",
                "anxiety",
                "panic",
                "panic attack",
                "worried",
                "worry",
                "overthinking",
                "overwhelmed",
            ]
            sad_keywords = [
                "depressed",
                "depression",
                "hopeless",
                "sad",
                "low",
                "empty",
                "cry",
                "crying",
            ]
            anger_keywords = [
                "angry",
                "anger",
                "furious",
                "irritated",
                "frustrated",
            ]

            has_sleep = any(k in lowered for k in sleep_keywords)
            has_anxiety = any(k in lowered for k in anxiety_keywords)
            has_sad = any(k in lowered for k in sad_keywords)
            has_anger = any(k in lowered for k in anger_keywords)

            # Only override emotion when the model is low-confidence or
            # the predicted emotion contradicts clear negative keywords.
            if has_sleep and (emotion in {"Joy", "Love", "Surprise"} or sentiment != 'negative'):
                if confidence < 0.75 or emotion == "Surprise":
                    emotion = "Fear"
                sentiment = 'negative'
            elif has_anxiety and sentiment != 'negative':
                if confidence < 0.75 or emotion == "Surprise":
                    emotion = "Fear"
                sentiment = 'negative'
            elif has_sad and sentiment != 'negative':
                if confidence < 0.75 or emotion in {"Joy", "Love", "Surprise"}:
                    emotion = "Sadness"
                sentiment = 'negative'
            elif has_anger and sentiment != 'negative':
                if confidence < 0.75 or emotion in {"Joy", "Love", "Surprise"}:
                    emotion = "Anger"
                sentiment = 'negative'

            return {
                'emotion': emotion,
                'sentiment': sentiment,
                'confidence': confidence,
            }
        except Exception as e:
            print("[FAILED] Error during text analysis:", e)
            return {
                'emotion': 'Unknown',
                'sentiment': 'neutral',
                'confidence': 0.0,
            }

    def predict_emotion(self, text):
        """Backward‑compatible wrapper: return only the emotion label."""
        info = self.analyze_text(text)
        return info.get('emotion', 'Unknown')
    
    def predict_face_emotion(self, face_image):
        """Predict emotion from face image"""
        if np is None:
            return 'Unknown', 0.0
        if self.face_model is None:
            print("[WARNING] Face emotion model not loaded")
            return 'Unknown', 0.0
        
        try:
            import cv2
            # Resize to 48x48
            face_resized = cv2.resize(face_image, (48, 48))
            # Normalize
            face_array = np.array(face_resized).reshape(1, 48, 48, 1) / 255.0
            # Predict
            predictions = self.face_model.predict(face_array, verbose=0)
            emotion_idx = np.argmax(predictions[0])
            confidence = float(np.max(predictions[0]))
            emotion = self.face_emotion_map.get(emotion_idx, 'unknown')
            return emotion, confidence
        except Exception as e:
            print(f"[FAILED] Error during face emotion prediction: {e}")
            return 'Unknown', 0.0

try:
    ml_service = MLService()
except Exception as e:
    print("[FAILED] Unexpected error initializing MLService:", e)
    ml_service = MLService()
