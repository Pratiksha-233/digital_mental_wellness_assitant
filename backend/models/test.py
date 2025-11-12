from services.ml_service import MLService
import numpy as np
# Map numeric labels to emotion names
label_map = {
    0: "sadness",
    1: "joy",
    2: "neutral",
    3: "anger",
    4: "fear",
    5: "surprise"
}

emoji_map = {
    "joy": "😊",
    "sadness": "😢",
    "anger": "😠",
    "fear": "😨",
    "neutral": "😐",
    "surprise": "😲"
}

ml = MLService()

print("\n🎯 **Emotion Prediction Test Results**")
print("--------------------------------------------------")

texts = [
    "I am so happy today!",
    "I feel really sad and lonely.",
    "I am angry and frustrated.",
    "I am scared of what might happen.",
    "Wow, today is very nice day!"
]

for text in texts:
    emotion = ml.predict_emotion(text)
    print(f"Raw prediction output for '{text}': {emotion}")  # 👈 debug line

    if isinstance(emotion, (int, float, np.integer)):
        emotion = label_map.get(int(emotion), "unknown")

    emoji = emoji_map.get(emotion.lower(), "😐")
    print(f"{text}\n → {emotion.capitalize()} {emoji}\n")
