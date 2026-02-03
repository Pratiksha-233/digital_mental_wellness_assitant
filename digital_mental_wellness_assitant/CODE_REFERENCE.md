# Code Reference Guide - Realtime Emotion Detection

## 🔗 Key Code Snippets

### 1. Backend API Endpoint (Flask)

**File**: `backend/routes/realtimedetection_routes.py`

```python
@detection_bp.route('/predict-emotion', methods=['POST'])
def predict_emotion():
    """
    Predict emotion from text input
    Expects: {"text": "user text here"}
    Returns: {"emotion": "emotion_label"}
    """
    try:
        data = request.get_json()
        text = data.get('text', '').strip()
        
        if not text:
            return jsonify({'status': 'error', 'message': 'Text cannot be empty'}), 400
        
        emotion = ml_service.predict_emotion(text)
        
        return jsonify({
            'status': 'success',
            'emotion': emotion,
            'text': text
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500
```

### 2. Frontend Service

**File**: `frontend/lib/services/realtime_detection_service.dart`

```dart
class RealtimeDetectionService {
  static const String _baseUrl = 'http://127.0.0.1:5000/api/detection';

  static Future<Map<String, dynamic>> predictEmotion(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict-emotion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to predict emotion');
      }
    } catch (e) {
      throw Exception('Error predicting emotion: $e');
    }
  }
}
```

### 3. Detection Screen Widget

**File**: `frontend/lib/screens/realtime_detection_screen.dart`

```dart
class RealtimeDetectionScreen extends StatefulWidget {
  const RealtimeDetectionScreen({super.key});

  @override
  State<RealtimeDetectionScreen> createState() => _RealtimeDetectionScreenState();
}

class _RealtimeDetectionScreenState extends State<RealtimeDetectionScreen> {
  final TextEditingController _textController = TextEditingController();
  String _detectedEmotion = '';
  bool _isLoading = false;

  Future<void> _detectEmotionFromText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'Please enter some text');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await RealtimeDetectionService.predictEmotion(text);
      setState(() {
        _detectedEmotion = result['emotion'] ?? 'Unknown';
        _isLoading = false;
        _detectionHistory.insert(0, 'Text: "$text" → Emotion: $_detectedEmotion');
        _textController.clear();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }
}
```

### 4. Route Registration

**File**: `frontend/lib/main.dart`

```dart
routes: {
  '/detection': (c) => const RealtimeDetectionScreen(),
  // ... other routes
}
```

### 5. AppBar Button

**File**: `frontend/lib/screens/home_screen.dart`

```dart
appBar: AppBar(
  title: const Text('Digital Wellness Home'),
  actions: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/detection'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.psychology_rounded, size: 20),
                SizedBox(width: 4),
                Text('Detection', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    ),
  ],
),
```

### 6. Sidebar Menu Item

**File**: `frontend/lib/screens/home_screen.dart`

```dart
ListTile(
  leading: const Icon(Icons.psychology),
  title: const Text('Realtime Detection'),
  onTap: () => Navigator.pushNamed(context, '/detection')),
```

### 7. Emotion Color Mapping

**File**: `frontend/lib/screens/realtime_detection_screen.dart`

```dart
Color _getEmotionColor(String emotion) {
  switch (emotion.toLowerCase()) {
    case 'happy':
    case 'joy':
      return Colors.amber;
    case 'sad':
    case 'sadness':
      return Colors.blue;
    case 'angry':
    case 'anger':
      return Colors.red;
    case 'fear':
      return Colors.purple;
    case 'surprise':
      return Colors.orange;
    case 'disgust':
      return Colors.green;
    case 'neutral':
      return Colors.grey;
    case 'love':
      return Colors.pink;
    default:
      return Colors.teal;
  }
}
```

### 8. Backend Registration

**File**: `backend/app.py`

```python
from .routes.realtimedetection_routes import detection_bp

# ... after creating Flask app ...

# register blueprints
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(mood_bp, url_prefix='/api/mood')
app.register_blueprint(rec_bp, url_prefix='/api/recommend')
app.register_blueprint(chat_bp, url_prefix='/api/chat')
app.register_blueprint(detection_bp, url_prefix='/api/detection')
```

---

## 🔌 API Contract

### Request Format
```json
POST /api/detection/predict-emotion
Content-Type: application/json

{
  "text": "I'm feeling great today!"
}
```

### Success Response
```json
{
  "status": "success",
  "emotion": "joy",
  "text": "I'm feeling great today!"
}
```

### Error Response
```json
{
  "status": "error",
  "message": "Text cannot be empty"
}
```

---

## 📊 State Management

```dart
// In _RealtimeDetectionScreenState
String _detectedEmotion = '';
double _confidence = 0.0;
bool _isLoading = false;
String _errorMessage = '';
List<String> _detectionHistory = [];

// Update state
setState(() {
  _detectedEmotion = 'happy';
  _confidence = 0.95;
  _isLoading = false;
  _detectionHistory.insert(0, 'New entry');
});
```

---

## 🎨 Widget Tree Structure

```
Scaffold
├── AppBar
│   └── actions: [Detection Button]
├── Drawer
│   └── Column
│       └── ListTile "Realtime Detection"
└── Body
    └── SingleChildScrollView
        └── Column
            ├── Card (Emotion Result)
            │   └── Column
            │       ├── Emoji (Text: 😊)
            │       ├── Emotion Label
            │       └── Confidence Bar
            ├── Card (Input Section)
            │   └── Column
            │       ├── TextField
            │       └── ElevatedButton
            └── Card (History)
                └── ListView
```

---

## 🔄 Navigation Flow Code

```dart
// Via AppBar button
onTap: () => Navigator.pushNamed(context, '/detection')

// Via Sidebar menu
onTap: () => Navigator.pushNamed(context, '/detection')

// Direct instantiation (alternative)
onTap: () => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const RealtimeDetectionScreen()
  )
)

// Go back
onTap: () => Navigator.pop(context)
```

---

## 🛠️ Important Dependencies

### Backend
```python
flask
flask-cors
tensorflow
keras
opencv-python
pillow
```

### Frontend
```yaml
http: ^1.5.0
firebase_core: ^3.15.2
firebase_auth: ^5.7.0
flutter:
  sdk: flutter
```

---

## 🔐 Error Handling Patterns

### Backend Pattern
```python
try:
    # Do something
    emotion = ml_service.predict_emotion(text)
    return jsonify({'status': 'success', 'emotion': emotion}), 200
except Exception as e:
    return jsonify({'status': 'error', 'message': str(e)}), 500
```

### Frontend Pattern
```dart
try {
  final result = await RealtimeDetectionService.predictEmotion(text);
  setState(() {
    _detectedEmotion = result['emotion'];
    _isLoading = false;
  });
} catch (e) {
  setState(() {
    _isLoading = false;
    _errorMessage = 'Error: ${e.toString()}';
  });
}
```

---

## 🧪 Testing Commands

### Test Backend API
```bash
# PowerShell
curl -X POST http://127.0.0.1:5000/api/detection/predict-emotion `
  -H "Content-Type: application/json" `
  -d '{\"text\": \"I am happy\"}'
```

### Flutter Hot Reload
```
Press 'r' - Hot reload (fast)
Press 'R' - Full restart
Press 'h' - Show commands
Press 'q' - Quit
```

---

## 📈 Performance Metrics

```
Backend Response Time: 1-2 seconds
ML Model Load Time: 5-10 seconds
Frontend Load Time: 2-3 seconds
API Timeout: 10 seconds
History Limit: 10 items
```

---

## 🎯 Key Functions

### Backend
```python
ml_service.predict_emotion(text)  # Returns emotion label
```

### Frontend
```dart
RealtimeDetectionService.predictEmotion(text)  // Returns Map
RealtimeDetectionService.predictImageEmotion(base64)  // Returns Map
```

---

## 📝 Logging/Debugging

### Backend
```python
print("Model loaded successfully")  # Logs to console
print(f"Predicting emotion for: {text}")
```

### Frontend
```dart
print('Emotion detected: $_detectedEmotion');  // Logs to console
debugPrint('Loading state: $_isLoading');
```

---

## 🚀 Deployment Notes

1. Change `_baseUrl` in service for production
2. Add authentication headers if needed
3. Implement rate limiting in backend
4. Add logging/monitoring
5. Use environment variables for URLs
6. Add data validation on backend
7. Implement CORS properly
8. Use HTTPS in production

---

## 📚 File Cross-References

| Feature | File | Function |
|---------|------|----------|
| API Endpoint | realtimedetection_routes.py | predict_emotion() |
| Service | realtime_detection_service.dart | predictEmotion() |
| Screen | realtime_detection_screen.dart | build() |
| AppBar | home_screen.dart | build() |
| Menu | home_screen.dart | build() |
| Routes | main.dart | routes {} |

---

This code reference guide provides all the essential code snippets and patterns used in the realtime emotion detection integration.

