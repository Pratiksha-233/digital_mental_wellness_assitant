# Realtime Emotion Detection Integration

## Overview
The Realtime Emotion Detection feature has been successfully integrated into the Digital Mental Wellness Assistant application. This feature allows users to detect emotions from text input and can be extended to support image-based emotion detection.

## Features Added

### Backend (Python Flask)
- **New Route**: `/api/detection/predict-emotion` - Text-based emotion detection
- **New Route**: `/api/detection/predict-image` - Image-based emotion detection (future enhancement)
- **File**: `backend/routes/realtimedetection_routes.py`

### Frontend (Flutter)
- **New Screen**: Realtime Detection Screen
- **New Service**: Realtime Detection Service for API communication
- **Menu Integration**: Added to the sidebar and AppBar (top-right)
- **File**: `frontend/lib/screens/realtime_detection_screen.dart`
- **Service File**: `frontend/lib/services/realtime_detection_service.dart`

## How to Use

### For End Users
1. **Login** to the application
2. **Navigate to Detection**:
   - Via the sidebar menu: Click "Realtime Detection"
   - Or via the AppBar button: Click the "Detection" button in the top-right corner
3. **Enter Text**: Type your thoughts or feelings in the text field
4. **Analyze**: Click "Detect Emotion" button
5. **View Results**: The detected emotion is displayed with:
   - Emoji representation
   - Emotion label
   - Confidence percentage
   - Detection history

## API Endpoints

### Text Emotion Detection
```
POST /api/detection/predict-emotion
Content-Type: application/json

Request Body:
{
  "text": "I'm feeling great today!"
}

Response:
{
  "status": "success",
  "emotion": "happy",
  "text": "I'm feeling great today!"
}
```

### Image Emotion Detection (Base64)
```
POST /api/detection/predict-image
Content-Type: application/json

Request Body:
{
  "image": "base64_encoded_image_data"
}

Response:
{
  "status": "success",
  "emotion": "happy",
  "faces_detected": 1,
  "confidence": 0.92
}
```

## UI Components

### Detection Screen Features
- **Emotion Display Card**: Shows detected emotion with emoji and confidence bar
- **Text Input Section**: Multi-line text field for emotion analysis
- **Detection History**: Displays recent detections (up to 10)
- **Loading Indicator**: Shows while API request is in progress
- **Error Handling**: Displays error messages if something goes wrong

### Color Coding
- Happy/Joy → Amber
- Sad/Sadness → Blue
- Angry/Anger → Red
- Fear → Purple
- Surprise → Orange
- Disgust → Green
- Neutral → Grey
- Love → Pink

## Files Modified/Created

### Backend
- `backend/routes/realtimedetection_routes.py` (NEW)
- `backend/app.py` (MODIFIED - added detection blueprint)

### Frontend
- `frontend/lib/screens/realtime_detection_screen.dart` (NEW)
- `frontend/lib/services/realtime_detection_service.dart` (NEW)
- `frontend/lib/main.dart` (MODIFIED - added import and route)
- `frontend/lib/screens/home_screen.dart` (MODIFIED - added menu item and AppBar button)

## Running the Application

### Backend
```bash
cd C:\Users\Lenovo\Desktop\project\digital_mental_wellness_assitant
python -m backend.app
```

Backend runs on: `http://127.0.0.1:5000`

### Frontend
```bash
cd C:\Users\Lenovo\Desktop\project\digital_mental_wellness_assitant\frontend
flutter run -d chrome
```

Frontend runs on: Browser-based Flutter Web

## Future Enhancements

1. **Real-time Camera Capture**: Integrate device camera for live emotion detection
2. **Emotion Trends**: Track emotion patterns over time
3. **Recommendations**: Suggest wellness activities based on detected emotions
4. **Export Data**: Allow users to download their detection history
5. **Voice Emotion Detection**: Add speech-to-text emotion analysis

## Error Handling

The application handles various error scenarios:
- Invalid text input (empty text)
- Network connectivity issues
- Backend unavailability
- ML model loading failures
- Invalid image formats

All errors are displayed to the user with appropriate messages.

## Dependencies

### Backend
- `flask` - Web framework
- `flask-cors` - CORS support
- `tensorflow` - ML model loading
- `keras` - Model inference
- `opencv-python` - Image processing
- `pillow` - Image handling

### Frontend
- `flutter` - UI framework
- `http` - HTTP requests
- `firebase_auth` - Authentication

## Testing

You can test the emotion detection API directly using curl:

```bash
# Test text emotion detection
curl -X POST http://127.0.0.1:5000/api/detection/predict-emotion \
  -H "Content-Type: application/json" \
  -d '{"text": "I am very happy today"}'
```

## Notes

- The app uses the sentiment_model.h5 loaded from backend/models/
- Image detection requires face detection using Haar Cascades
- All network requests have a 10-second timeout
- Detection history is stored in memory (not persistent across sessions)

---

**Integration Complete!** The realtime emotion detection feature is fully integrated and ready to use.
