import numpy as np
import pickle
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.sequence import pad_sequences

class MLService:
    def __init__(self):
        model_path = "models/sentiment_model.h5"
        tokenizer_path = "models/tokenizer.pkl"
        encoder_path = "models/label_encoder.pkl"

        print("🔄 Loading model and preprocessing files...")
        self.model = load_model(model_path)

        with open(tokenizer_path, "rb") as f:
            self.tokenizer = pickle.load(f)
        with open(encoder_path, "rb") as f:
            self.label_encoder = pickle.load(f)

        # ✅ Add this line here
        self.max_len = 100   # Use the same number you used in training

        # (Optional) Label map
        self.label_map = {
            0: "Sadness",
            1: "Joy",
            2: "Love",
            3: "Anger",
            4: "Fear",
            5: "Surprise"
        }

        print("✅ Model, tokenizer, and encoder loaded successfully!")

    def predict_emotion(self, text):
        seq = self.tokenizer.texts_to_sequences([text])
        padded = pad_sequences(seq, maxlen=self.max_len, padding='post')
        preds = self.model.predict(padded)
        label_index = int(np.argmax(preds))
        emotion = self.label_map.get(label_index, "Unknown")
        return emotion
ml_service = MLService()