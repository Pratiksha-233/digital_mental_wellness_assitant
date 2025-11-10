import tensorflow as tf
import numpy as np
import pickle
from datasets import load_dataset
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
from sklearn.preprocessing import LabelEncoder
import os

# Create models folder
os.makedirs("models", exist_ok=True)

print("📥 Loading dataset...")
dataset = load_dataset("emotion")

# Combine data
texts = dataset["train"]["text"]
labels = dataset["train"]["label"]

# Tokenize
tokenizer = Tokenizer(num_words=10000, oov_token="<OOV>")
tokenizer.fit_on_texts(texts)
sequences = tokenizer.texts_to_sequences(texts)
padded = pad_sequences(sequences, maxlen=50, padding='post')

# Encode labels
label_encoder = LabelEncoder()
y = label_encoder.fit_transform(labels)

# Save tokenizer and label encoder
with open("models/tokenizer.pkl", "wb") as f:
    pickle.dump(tokenizer, f)
with open("models/label_encoder.pkl", "wb") as f:
    pickle.dump(label_encoder, f)

print("✅ Tokenizer & encoder saved")

# Build and train model
model = tf.keras.Sequential([
    tf.keras.layers.Embedding(input_dim=10000, output_dim=128, input_length=50),
    tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(128, return_sequences=True)),
    tf.keras.layers.GlobalMaxPooling1D(),
    tf.keras.layers.Dense(64, activation='relu'),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(len(set(y)), activation='softmax')
])

model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

print("🚀 Training model...")
history = model.fit(
    padded, np.array(y),
    epochs=10,  # ⬅️ Increased epochs
    batch_size=64,
    validation_split=0.2,
    verbose=2
)

# Save model
model.save("models/sentiment_model.h5")
print("✅ Model trained and saved successfully!")

# Evaluate
val_loss, val_acc = model.evaluate(padded[:2000], np.array(y[:2000]))
print(f"🎯 Final Validation Accuracy: {val_acc:.3f}")
print("Classes:", label_encoder.classes_)
