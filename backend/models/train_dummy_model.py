import tensorflow as tf
import numpy as np
import os

os.makedirs('models', exist_ok=True)

# Create dummy training data (texts -> encoded numbers)
X = np.random.randint(0, 1000, (100, 50))
y = np.random.randint(0, 5, (100,))

# Build a small model
model = tf.keras.Sequential([
    tf.keras.layers.Embedding(input_dim=1000, output_dim=16, input_length=50),
    tf.keras.layers.GlobalAveragePooling1D(),
    tf.keras.layers.Dense(16, activation='relu'),
    tf.keras.layers.Dense(5, activation='softmax')
])

model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
model.fit(X, y, epochs=3, verbose=1)

# Save it to models folder
model.save('models/sentiment_model.h5')
print('✅ Dummy sentiment_model.h5 created successfully!')
