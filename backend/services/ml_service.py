import os
import numpy as np
import pickle
from keras.models import load_model
from keras.preprocessing.sequence import pad_sequences

emotion_labels = {
    0: "Sadness",
    1: "Joy",
    2: "Love",
    3: "Anger",
    4: "Fear",
    5: "Surprise"
}


class MLService:
    def __init__(self):
        base_path = os.path.dirname(__file__)
        model_path = os.path.join(base_path, "../models/sentiment_model.h5")
        tokenizer_path = os.path.join(base_path, "../models/tokenizer.pkl")
        encoder_path = os.path.join(base_path, "../models/label_encoder.pkl")

        print("🔄 Loading model and preprocessing files...")
        self.model = load_model(model_path)

        # Load tokenizer
        with open(tokenizer_path, "rb") as handle:
            self.tokenizer = pickle.load(handle)

        # Load label encoder
        with open(encoder_path, "rb") as handle:
            self.encoder = pickle.load(handle)

        print("✅ Model, tokenizer, and encoder loaded successfully!")

    def predict_emotion(self, text: str):
        # Convert text to padded sequence
        seq = self.tokenizer.texts_to_sequences([text])
        x = pad_sequences(seq, maxlen=50)

        # Predict
        preds = self.model.predict(x)
        label_index = np.argmax(preds, axis=1)[0]

        # Decode integer → emotion string
        emotion = self.encoder.inverse_transform([label_index])[0]
        emotion = int(np.argmax(preds))
        emotion = emotion_labels.get(emotion, "Unknown")
        return emotion
ml_service = MLService()