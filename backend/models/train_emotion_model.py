import pandas as pd
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
from sklearn.preprocessing import LabelEncoder
import os
import pickle

# Load dataset
df = pd.read_csv('models/emotion_dataset.csv')

# Encode labels
le = LabelEncoder()
df['label'] = le.fit_transform(df['emotion'])

# Save label encoder
os.makedirs("models", exist_ok=True)
with open("models/label_encoder.pkl", "wb") as f:
    pickle.dump(le, f)

# Tokenize text
tokenizer = Tokenizer(num_words=5000, oov_token="<OOV>")
tokenizer.fit_on_texts(df['text'])

# Save tokenizer
with open("models/tokenizer.pkl", "wb") as f:
    pickle.dump(tokenizer, f)

# Convert text → sequences
X = tokenizer.texts_to_sequences(df['text'])
X = pad_sequences(X, maxlen=50, padding='post')

y = df['label'].values

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Build model
model = tf.keras.Sequential([
    tf.keras.layers.Embedding(5000, 64, input_length=50),
    tf.keras.layers.LSTM(64),
    tf.keras.layers.Dense(32, activation='relu'),
    tf.keras.layers.Dense(len(le.classes_), activation='softmax')
])

model.compile(loss='sparse_categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

# Train
model.fit(X_train, y_train, epochs=10, validation_data=(X_test, y_test), verbose=2)

# Save model
model.save('models/sentiment_model.h5')

print("✅ Model trained and saved successfully!")
print("Classes:", le.classes_)
