from services.ml_service import ml_service
from models.preprocess import preprocess_text
import numpy as np

texts = [
    "I am so happy today!",
    "I feel really sad and lonely.",
    "I am angry and frustrated.",
    "I am scared of what might happen.",
    "Wow, this is amazing!"
]

for t in texts:
    x = preprocess_text(t)
    preds = ml_service.model.predict(x)
    emotion_idx = np.argmax(preds, axis=1)[0]
    emotion = ml_service.label_encoder.inverse_transform([emotion_idx])[0]
    confidence = float(np.max(preds))
    print(f"{t}\n → {emotion} ({confidence:.2f})\n")
