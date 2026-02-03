import pickle
from tensorflow.keras.preprocessing.sequence import pad_sequences

with open("models/tokenizer.pkl", "rb") as f:
    tokenizer = pickle.load(f)

def preprocess_text(text):
    text = text.lower().strip()
    seq = tokenizer.texts_to_sequences([text])
    padded = pad_sequences(seq, maxlen=100, padding='post')
    return padded  # keep 2D shape (1, 50)
