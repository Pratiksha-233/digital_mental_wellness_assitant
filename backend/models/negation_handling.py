import pickle
import numpy as np
from datasets import load_dataset
from sklearn.preprocessing import LabelEncoder
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Embedding, Bidirectional, LSTM, GlobalMaxPooling1D, Dense, Dropout
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences

dataset = load_dataset("emotion")
train_data = dataset["train"]

texts = train_data["text"]
labels = train_data["label"]

extra_texts = [
    "I am not happy",
    "I am not feeling good",
    "I am not okay today",
    "I don’t feel good",
    "I am sad and not excited",
    "I am not in a good mood",
    "I feel low",
    "I am very upset",
    "I am not enjoying anything",
    "I feel terrible",
]

extra_labels = [
    "sadness", "sadness", "sadness",
    "sadness", "sadness", "sadness",
    "sadness", "sadness", "sadness",
    "sadness"
]

texts = list(texts) + extra_texts
labels = list(labels) + extra_labels

label_encoder = LabelEncoder()
y = label_encoder.fit_transform(labels)

MAX_WORDS = 10000
MAX_LEN = 100

tokenizer = Tokenizer(num_words=MAX_WORDS, oov_token="<OOV>")
tokenizer.fit_on_texts(texts)

X = tokenizer.texts_to_sequences(texts)
X = pad_sequences(X, maxlen=MAX_LEN, padding="post")

model = Sequential([
    Embedding(input_dim=MAX_WORDS, output_dim=128, input_length=MAX_LEN),
    Bidirectional(LSTM(128, return_sequences=True)),
    GlobalMaxPooling1D(),
    Dense(64, activation="relu"),
    Dropout(0.2),
    Dense(len(label_encoder.classes_), activation="softmax")
])

model.compile(
    loss="sparse_categorical_crossentropy",
    optimizer="adam",
    metrics=["accuracy"]
)

model.fit(X, y, epochs=5, batch_size=64, validation_split=0.2)

model.save("models/sentiment_model.h5")

with open("models/tokenizer.pkl", "wb") as f:
    pickle.dump(tokenizer, f)

with open("models/label_encoder.pkl", "wb") as f:
    pickle.dump(label_encoder, f)

print("Training completed and model saved successfully with negation handling!")
