import tensorflow as tf
import numpy as np
import pickle
from models.preprocess import preprocess_text

class MLService:
    def __init__(self):
        # Load model and encoder
        self.model = tf.keras.models.load_model('models/sentiment_model.h5')
        with open("models/label_encoder.pkl", "rb") as f:
            self.label_encoder = pickle.load(f)
        print("✅ Model & encoder loaded")

    def predict_emotion(self, text):
        x = preprocess_text(text)
        preds = self.model.predict(x)
        idx = np.argmax(preds, axis=1)[0]
        emotion = self.label_encoder.inverse_transform([idx])[0]
        confidence = float(np.max(preds))
        if confidence < 0.3:
            return "Neutral"
        return emotion

# Create a global instance
ml_service = MLService()
