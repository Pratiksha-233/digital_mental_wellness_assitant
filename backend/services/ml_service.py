import numpy as np
import pickle
import os
from pathlib import Path
try:
    from tensorflow.keras.models import load_model
    from tensorflow.keras.preprocessing.sequence import pad_sequences
    _TF_AVAILABLE = True
except Exception:
    _TF_AVAILABLE = False


class MLService:
    def __init__(self):
        self.model = None
        self.tokenizer = None
        self.label_encoder = None
        self.max_len = 100
        self.label_map = {
            0: "Sadness",
            1: "Joy",
            2: "Love",
            3: "Anger",
            4: "Fear",
            5: "Surprise"
        }

        cwd = Path(os.getcwd())
        svc_dir = Path(__file__).resolve().parent
        project_backend = svc_dir.parent
        # prefer the canonical backend/models directory where trained outputs belong
        candidates = [
            project_backend / 'models' / 'sentiment_model.h5',
            project_backend / 'models' / 'models' / 'sentiment_model.h5',
            cwd / 'models' / 'sentiment_model.h5',
        ]

        tokenizer_path = project_backend / 'models' / 'tokenizer.pkl'
        encoder_path = project_backend / 'models' / 'label_encoder.pkl'

        if not _TF_AVAILABLE:
            print("⚠️ TensorFlow/Keras not available. ML features will be disabled.")
            return

        print(f"🔄 Looking for model in {len(candidates)} candidate locations...")
        found = False
        last_exc = None
        for p in candidates:
            try:
                p = p.resolve()
            except Exception:
                # ignore resolution errors and use as-is
                p = Path(p)

            if not p.exists():
                print(f"⏭️ Candidate not found: {p}")
                continue

            try:
                size = p.stat().st_size
            except Exception:
                size = 0

            if size < 100:
                print(f"⚠️ Candidate file exists but is suspiciously small ({size} bytes): {p}")
                # still try to load, but warn

            try:
                print(f"🔁 Attempting to load model from: {p}")
                # try HDF5 / SavedModel automatically
                self.model = load_model(str(p), compile=False)
                print(f"✅ Loaded model from: {p}")
                found = True
                break
            except Exception as e:
                print(f"❌ Failed loading from {p}: {e}")
                last_exc = e
                # continue to next candidate

        # load tokenizer and encoder if model loaded
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
                    print(f"⚠️ Tokenizer not found in candidates: {candidates_tok}")

                for ep in candidates_enc:
                    if ep.exists():
                        with open(ep, 'rb') as f:
                            self.label_encoder = pickle.load(f)
                        break
                else:
                    print(f"⚠️ Label encoder not found in candidates: {candidates_enc}")

                print("✅ Model and preprocessing loaded.")
            except Exception as e:
                print("❌ Error loading tokenizer/encoder:", e)
        else:
            print("❌ Could not load any model candidate.")
            if last_exc is not None:
                print("Last error:", last_exc)
            print("Hint: run the training script to (re)create a compatible model, or place a valid Keras .h5 or SavedModel under backend/models/")

    def predict_emotion(self, text):
        if not self.model or not self.tokenizer:
            # Fallback: simple rule-based or neutral prediction
            print("⚠️ ML model not loaded; returning fallback emotion 'Neutral'")
            return 'Neutral'

        try:
            seq = self.tokenizer.texts_to_sequences([text])
            padded = pad_sequences(seq, maxlen=self.max_len, padding='post')
            preds = self.model.predict(padded)
            label_index = int(np.argmax(preds))
            emotion = self.label_map.get(label_index, "Unknown")
            return emotion
        except Exception as e:
            print("❌ Error during emotion prediction:", e)
            return 'Unknown'

try:
    ml_service = MLService()
except Exception as e:
    print("❌ Unexpected error initializing MLService:", e)
    ml_service = MLService()
