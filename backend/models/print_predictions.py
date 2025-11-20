# models/print_predictions.py
import numpy as np
from models.preprocess import preprocess_text
import pickle
import os
from tensorflow.keras.models import load_model

BASE = os.path.dirname(__file__)
model = load_model(os.path.join(BASE, "sentiment_model.h5"))
with open(os.path.join(BASE, "tokenizer.pkl"), "rb") as f:
    tokenizer = pickle.load(f)
with open(os.path.join(BASE, "label_encoder.pkl"), "rb") as f:
    le = pickle.load(f)

def predict_with_topk(text, k=3):
    x = preprocess_text(text)        # returns padded shape (1, maxlen)
    preds = model.predict(x)[0]      # shape (num_classes,)
    # top-k
    top_idx = preds.argsort()[-k:][::-1]
    top = [(le.inverse_transform([i])[0], float(preds[i])) for i in top_idx]
    return preds, top

samples = [
    "I am so happy today!",
    "I feel really sad and lonely.",
    "I am angry and frustrated.",
    "I am scared of what might happen.",
    "Wow, this is amazing!"
]

for s in samples:
    probs, top = predict_with_topk(s, k=3)
    print("\nSentence:", s)
    print("Raw probs:", np.round(probs, 4))
    print("Top-3:", [(lab, f"{p:.3f}") for lab, p in top])
