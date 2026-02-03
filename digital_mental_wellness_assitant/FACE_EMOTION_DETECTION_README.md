# Face Emotion Detection - Setup and Usage Guide

## Overview
This system uses computer vision and deep learning to detect emotions from facial expressions in real-time using a webcam or from uploaded images.

## Supported Emotions
The model can detect 7 different emotions:
- 😠 **Angry**
- 🤢 **Disgust**
- 😨 **Fear**
- 😊 **Happy**
- 😐 **Neutral**
- 😢 **Sad**
- 😲 **Surprise**

## Requirements

### Python Dependencies
```bash
pip install opencv-python
pip install tensorflow
pip install keras
pip install pillow
pip install numpy
pip install flask
```

### Model Files
Make sure these files exist in the project root:
- `emotiondetecter1.json` - Model architecture
- `emotiondetecter1.h5` - Model weights

## Features

### 1. Real-time Webcam Detection
Run face emotion detection directly from your webcam with live predictions.

**How to use:**
```bash
cd backend
python models/realtimedetection.py
```

**Controls:**
- Press `q` to quit the detection window

**What it does:**
- Opens your webcam
- Detects faces in real-time
- Draws a rectangle around each detected face
- Shows the predicted emotion and confidence score
- Updates predictions continuously

### 2. API Endpoints for Image-based Detection

#### Text Emotion Prediction (existing feature)
**Endpoint:** `POST /api/detection/predict-emotion`

**Request:**
```json
{
  "text": "I am feeling great today!"
}
```

**Response:**
```json
{
  "status": "success",
  "emotion": "Joy",
  "text": "I am feeling great today!"
}
```

#### Face Emotion Prediction (NEW)
**Endpoint:** `POST /api/detection/predict-image`

**Request:**
```json
{
  "image": "base64_encoded_image_data"
}
```

**Response:**
```json
{
  "status": "success",
  "emotion": "happy",
  "faces_detected": 1,
  "confidence": 0.95
}
```

## Testing

### Test the Face Detection System
Run the test script to verify everything is working:

```bash
cd backend
python test_face_detection.py
```

This will:
1. Check if the emotion model is loaded correctly
2. Verify the face detection cascade is working
3. Test webcam accessibility
4. Optionally start real-time detection

## How It Works

### 1. Face Detection
- Uses **Haar Cascade Classifier** to detect faces in images/video
- Focuses on frontal faces for best accuracy
- Can detect multiple faces in one frame

### 2. Emotion Prediction
- Extracts the detected face region
- Resizes to 48x48 pixels (model input size)
- Converts to grayscale
- Normalizes pixel values (0-1 range)
- Feeds into the CNN model
- Returns emotion label and confidence score

### 3. Model Architecture
The emotion detection model (`emotiondetecter1.h5`) is a Convolutional Neural Network (CNN) trained on facial expression datasets.

## Troubleshooting

### Model Not Loading
```
Error: Model not loaded
```
**Solution:** Ensure `emotiondetecter1.json` and `emotiondetecter1.h5` exist in the project root directory.

### Webcam Not Opening
```
Error: Could not open webcam
```
**Solutions:**
- Check if another application is using the webcam
- Verify webcam permissions
- Try changing camera index: `cv2.VideoCapture(1)` instead of `cv2.VideoCapture(0)`

### No Face Detected
```
emotion: "No face detected"
```
**Solutions:**
- Ensure good lighting
- Face the camera directly
- Move closer to the camera
- Remove obstructions (glasses, masks might affect detection)

### Low Confidence Scores
**Solutions:**
- Improve lighting conditions
- Ensure face is clearly visible
- Face the camera directly
- Maintain a neutral expression first, then show emotion

## API Integration Example

### Python Example
```python
import requests
import base64

# Read image file
with open("face_image.jpg", "rb") as image_file:
    encoded_image = base64.b64encode(image_file.read()).decode('utf-8')

# Send request
url = "http://localhost:5000/api/detection/predict-image"
payload = {"image": encoded_image}
response = requests.post(url, json=payload)

# Get result
result = response.json()
print(f"Emotion: {result['emotion']}")
print(f"Confidence: {result['confidence']:.2f}")
print(f"Faces detected: {result['faces_detected']}")
```

### JavaScript/Frontend Example
```javascript
// Capture from webcam or file input
const captureImage = async () => {
  const canvas = document.getElementById('canvas');
  const context = canvas.getContext('2d');
  const video = document.getElementById('video');
  
  // Draw video frame to canvas
  context.drawImage(video, 0, 0, canvas.width, canvas.height);
  
  // Get base64 image
  const imageData = canvas.toDataURL('image/jpeg');
  
  // Send to API
  const response = await fetch('/api/detection/predict-image', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ image: imageData })
  });
  
  const result = await response.json();
  console.log('Emotion:', result.emotion);
  console.log('Confidence:', result.confidence);
};
```

## Performance Tips

1. **Good Lighting:** Ensure the face is well-lit for better detection
2. **Face Size:** Keep face at a reasonable distance from camera
3. **Single Face:** For best results, have one face in frame at a time
4. **Clear Expression:** Make clear, distinguishable expressions
5. **Camera Quality:** Higher quality camera = better detection

## Files Modified/Created

### Modified Files:
1. `backend/models/realtimedetection.py` - Complete rewrite with proper face detection
2. `backend/routes/realtimedetection_routes.py` - Updated to use face emotion model
3. `backend/services/ml_service.py` - Added face emotion model support

### New Files:
1. `backend/test_face_detection.py` - Testing utility
2. `FACE_EMOTION_DETECTION_README.md` - This documentation

## Next Steps

1. **Run the test script** to verify everything works:
   ```bash
   python backend/test_face_detection.py
   ```

2. **Try real-time detection** from webcam:
   ```bash
   python backend/models/realtimedetection.py
   ```

3. **Test API endpoint** with your frontend or Postman

4. **Integrate with your Flutter app** using the API endpoints

## Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Verify all dependencies are installed
3. Ensure model files exist and are not corrupted
4. Check Python version compatibility (Python 3.7+)
5. Review error messages in console output

---

**Note:** The text-based emotion prediction is still available and working. This update adds face-based emotion detection as an additional feature.
