"""
Test script for face emotion detection
Run this to test if the face emotion detection is working properly
"""
import sys
from pathlib import Path

# Add models directory to path
models_path = Path(__file__).resolve().parent / 'models'
sys.path.insert(0, str(models_path))

try:
    from models.realtimedetection import model, face_cascade, predict_emotion_from_face, run_realtime_detection
    import cv2
    
    print("=" * 50)
    print("Face Emotion Detection Test")
    print("=" * 50)
    
    # Check if model is loaded
    if model is None:
        print("❌ ERROR: Emotion detection model not loaded!")
        print("Please check if emotiondetecter1.json and emotiondetecter1.h5 exist")
        sys.exit(1)
    else:
        print("✓ Emotion detection model loaded successfully")
    
    # Check if face cascade is loaded
    if face_cascade.empty():
        print("❌ ERROR: Haar Cascade not loaded!")
        sys.exit(1)
    else:
        print("✓ Haar Cascade loaded successfully")
    
    # Check webcam
    webcam = cv2.VideoCapture(0)
    if not webcam.isOpened():
        print("⚠ WARNING: Could not open webcam")
        print("Face detection from webcam will not work")
    else:
        print("✓ Webcam accessible")
        webcam.release()
    
    print("\n" + "=" * 50)
    print("All checks passed! ✓")
    print("=" * 50)
    
    # Ask user if they want to start real-time detection
    print("\nOptions:")
    print("1. Start real-time face emotion detection (press 'q' to quit)")
    print("2. Exit")
    
    choice = input("\nEnter your choice (1 or 2): ").strip()
    
    if choice == "1":
        print("\nStarting real-time detection...")
        print("Press 'q' to quit the detection window")
        run_realtime_detection()
    else:
        print("Exiting...")
        
except Exception as e:
    print(f"❌ ERROR: {e}")
    import traceback
    traceback.print_exc()
