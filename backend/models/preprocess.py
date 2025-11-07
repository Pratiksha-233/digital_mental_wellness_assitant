import pickle
from tensorflow.keras.preprocessing.sequence import pad_sequences

with open("models/tokenizer.pkl", "rb") as f:
    tokenizer = pickle.load(f)

def preprocess_text(text):
    # Basic clean-up (must match training)
    text = text.lower()
    seq = tokenizer.texts_to_sequences([text])
    padded = pad_sequences(seq, maxlen=50, padding='post')
    return padded[0]
