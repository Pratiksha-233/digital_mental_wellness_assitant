import tensorflow as tf
import numpy as np
import pickle
from models.preprocess import preprocess_text

MODEL_PATH = 'models/sentiment_model.h5'
LABEL_PATH = 'models/label_encoder.pkl'

class MLService:
    def __init__(self):
        try:
            self.model = tf.keras.models.load_model(MODEL_PATH)
            with open(LABEL_PATH, "rb") as f:
                self.label_encoder = pickle.load(f)
            print("✅ Sentiment model & label encoder loaded successfully.")
        except Exception as e:
            print("❌ Could not load model:", e)
            self.model = None
            self.label_encoder = None

    def predict_emotion(self, text):
        x = preprocess_text(text)
        if x is None or self.model is None:
            return 'Neutral'
        try:
            preds = self.model.predict(np.array([x]))
            idx = np.argmax(preds, axis=1)[0]
            emotion = self.label_encoder.inverse_transform([idx])[0]
            return emotion
        except Exception as e:
            print("Prediction error:", e)
            return 'Neutral'

ml_service = MLService()