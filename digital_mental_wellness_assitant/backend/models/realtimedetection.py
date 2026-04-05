import cv2
try:
    from keras.models import model_from_json
    KERAS_AVAILABLE = True
except ImportError:
    KERAS_AVAILABLE = False
    model_from_json = None
try:
    import numpy as np
except ImportError:
    np = None
import os
from pathlib import Path


project_root = Path(__file__).resolve().parent.parent.parent
model_json_path = project_root / "emotiondetecter1.json"
model_weights_path = project_root / "emotiondetecter1.h5"


if KERAS_AVAILABLE:
    try:
        print(f"Loading model from: {model_json_path}")
        with open(model_json_path, "r") as json_file:
            model_json = json_file.read()
        model = model_from_json(model_json)
        model.load_weights(str(model_weights_path))
        print("Emotion detection model loaded successfully")
    except Exception as e:
        print(f"Error loading model: {e}")
        model = None
else:
    model = None
    print("Keras not available, ML features disabled")



haar_candidates = [
    cv2.data.haarcascades + 'haarcascade_frontalface_alt2.xml',
    cv2.data.haarcascades + 'haarcascade_frontalface_default.xml',
]

face_cascade = None
for haar_file in haar_candidates:
    cascade = cv2.CascadeClassifier(haar_file)
    if cascade is not None and not cascade.empty():
        face_cascade = cascade
        break

if face_cascade is None:
    print("Error: Could not load Haar Cascade")

def extract_features(image):
    """Extract and preprocess features from face image"""
    if np is None:
        return None
    feature = np.array(image)
    feature = feature.reshape(1, 48, 48, 1)
    return feature / 255.0

def predict_emotion_from_face(face_image):
    """Predict emotion from a face image"""
    if np is None:
        return "NumPy not available", 0.0
    if model is None:
        return "Model not loaded", 0.0

    try:

        face_resized = cv2.resize(face_image, (48, 48))

        img_features = extract_features(face_resized)

        predictions = model.predict(img_features, verbose=0)
        emotion_idx = np.argmax(predictions[0])
        confidence = float(np.max(predictions[0]))

        labels = {0: 'angry', 1: 'disgust', 2: 'fear', 3: 'happy', 4: 'neutral', 5: 'sad', 6: 'surprise'}
        emotion = labels.get(emotion_idx, 'unknown')

        return emotion, confidence
    except Exception as e:
        print(f"Error in prediction: {e}")
        return "error", 0.0

def run_realtime_detection():
    """Run real-time face emotion detection from webcam"""
    if model is None:
        print("Model not loaded. Cannot start detection.")
        return

    webcam = cv2.VideoCapture(0)

    if not webcam.isOpened():
        print("Error: Could not open webcam")
        return

    print("Starting real-time emotion detection. Press 'q' to quit.")
    labels = {0: 'angry', 1: 'disgust', 2: 'fear', 3: 'happy', 4: 'neutral', 5: 'sad', 6: 'surprise'}

    while True:
        ret, frame = webcam.read()

        if not ret:
            print("Error: Failed to capture frame")
            break


        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)


        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5, minSize=(30, 30))


        for (x, y, w, h) in faces:

            face_roi = gray[y:y+h, x:x+w]


            emotion, confidence = predict_emotion_from_face(face_roi)


            cv2.rectangle(frame, (x, y), (x+w, y+h), (255, 0, 0), 2)


            label = f"{emotion}: {confidence:.2f}"
            cv2.putText(frame, label, (x, y-10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)


        cv2.imshow("Real-time Emotion Detection", frame)


        if cv2.waitKey(1) & 0xFF == ord('q'):
            break


    webcam.release()
    cv2.destroyAllWindows()
    print("Real-time detection stopped.")

if __name__ == "__main__":
    run_realtime_detection()