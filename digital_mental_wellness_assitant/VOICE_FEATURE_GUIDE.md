# Voice-Based Interaction Feature

## Overview

The Digital Mental Wellness Assistant now supports **voice-based interaction** in addition to text input. Users can speak their feelings, concerns, and thoughts instead of typing, making the experience more natural and accessible.

## Features

✨ **Key Capabilities:**
- 🎤 Voice input while keeping text input available
- 🎙️ Real-time speech recognition with live waveform feedback
- 📝 Transcribed text appears in the chat input field
- ⚡ Automatic sending of recognized speech (optional)
- 🌐 Multi-language support
- 🔇 Easy toggle between typing and speaking modes
- 🛡️ Privacy-first: speech processing can be done on-device (Flutter side)

---

## Technical Implementation

### Frontend (Flutter)

**New Components:**

1. **`services/voice_service.dart`** - Voice service manager
   - Handles speech recognition lifecycle
   - Manages callbacks for listening state, text recognition, and sound levels
   - Uses `speech_to_text` package for on-device recognition

2. **Updated `screens/chat_screen.dart`**
   - Added microphone button next to send button
   - Real-time listening indicator with sound level visualization
   - Voice input mode toggle
   - Text field auto-population with recognized speech

3. **New Dependencies in `pubspec.yaml`**
   - `speech_to_text: ^6.4.0` - Speech recognition library
   - `permission_handler: ^11.4.4` - Microphone permission management

### Backend (Python/Flask)

**New Route File:**
- `routes/voice_routes.py` - Voice processing endpoints

**New Endpoints:**
- `POST /api/voice/transcribe` - Convert audio file to text
- `POST /api/voice/predict-voice` - Process voice input with emotion/intent detection

**New Dependencies:**
- `SpeechRecognition` - Audio processing and transcription
- `pydub` - Audio format conversion

---

## How It Works

### Voice Input Flow

```
┌─────────────────────────────────────────┐
│  User taps microphone icon              │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Request microphone permission          │
│  (if not already granted)               │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Start listening (speech recognition)   │
│  Show mic icon + sound level indicator  │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Real-time transcription to text        │
│  Update text field with recognized text │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  User taps mic again or wait 3 seconds  │
│  (auto-stop after 30 seconds max)       │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Send transcribed text to backend       │
│  (same flow as text input)              │
└─────────────────────────────────────────┘
```

### Processing Steps

1. **Initialize Voice Service** - On app startup, voice service is ready
2. **Request Permission** - Ask user for microphone access (Android/iOS)
3. **Start Recognition** - Begin listening on user tap
4. **Real-time Transcription** - Speech converted to text in real-time
5. **Display Text** - Recognized text appears in input field
6. **Send Message** - User can send or continue typing
7. **Get Response** - Backend processes like normal chat message

---

## Usage Guide

### For End Users

**Making a voice message:**

1. Open the chat screen
2. Tap the **microphone icon** (🎤) in the input area
3. Speak clearly - your words appear in the text field
4. When done speaking, tap the mic icon again to stop
5. Tap **Send** to submit your message

**Switching back to typing:**

- Simply start typing in the text field - voice mode turns off
- Or manually tap the mic icon to stop listening

**Best Practices:**

- ✅ Speak clearly and naturally
- ✅ Use a quiet environment for better accuracy
- ✅ Allow 3 seconds of silence to end the phrase
- ✅ Maximum 30 seconds per recording
- ❌ Don't hold down the mic button - it's a toggle
- ❌ Don't speak over loud background noise

---

## Installation & Setup

### Frontend Setup

1. **Update pubspec.yaml** (already done)
   ```yaml
   speech_to_text: ^6.4.0
   permission_handler: ^11.4.4
   ```

2. **Install dependencies**
   ```bash
   cd frontend
   flutter pub get
   ```

3. **Configure Platform-Specific Permissions**

   **Android (`android/app/build.gradle`):**
   ```gradle
   minSdkVersion 21  // Required for speech_to_text
   ```

   **Android (`android/app/src/main/AndroidManifest.xml`):**
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```

   **iOS (`ios/Runner/Info.plist`):**
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>This app needs microphone access to process voice input for the wellness chat.</string>
   <key>NSSpeechRecognitionUsageDescription</key>
   <string>This app needs speech recognition to convert your voice to text.</string>
   ```

### Backend Setup (Optional)

For audio file upload processing:

```bash
pip install SpeechRecognition pydub
```

---

## API Endpoints

### POST `/api/voice/transcribe`

Convert audio file to text.

**Request:**
```
POST /api/voice/transcribe
Content-Type: multipart/form-data

Parameters:
  - audio: [audio file] (WAV, MP3, OGG, etc.)
  - language: "en-US" (optional)
```

**Response:**
```json
{
  "status": "success",
  "text": "I'm feeling stressed about the deadline",
  "language": "en-US",
  "confidence": 0.95
}
```

### POST `/api/voice/predict-voice`

Process voice input with emotion/intent detection.

**Request:**
```
POST /api/voice/predict-voice
Content-Type: multipart/form-data

Parameters:
  - audio: [audio file]
  - user_id: 123 (optional)
  - language: "en-US" (optional)
```

**Response:**
```json
{
  "status": "success",
  "text": "I'm feeling stressed about the deadline",
  "emotion": "anxiety",
  "sentiment": "negative",
  "intent": "stress",
  "confidence": 0.92,
  "is_crisis": false
}
```

---

## Platform-Specific Notes

### Android

- **Minimum API Level:** 21 (Android 5.0)
- **Permission Handling:** Handled automatically by `permission_handler`
- **Speech Engine:** Uses Google Cloud Speech API (requires internet)
- **Offline Support:** Limited - requires Google Play Services

### iOS

- **Minimum iOS Version:** 14.0
- **Speech Framework:** Uses native Apple Speech Recognition
- **Permissions:** User must grant microphone + speech recognition permissions
- **Offline Support:** Some recognition available offline with Apple's ML models

### Web

- Note: Speech recognition via `speech_to_text` may have limited browser support
- Best experience on Chrome, Edge, Safari 14.1+

---

## Error Handling

The voice service handles common errors:

| Error | Cause | Solution |
|-------|-------|----------|
| **Voice recognition not available** | Device doesn't support speech-to-text | Use text input instead |
| **Microphone permission denied** | User rejected permission request | Grant permission in device settings |
| **Could not understand audio** | Low quality or too much background noise | Speak clearly in a quiet environment |
| **Speech service error** | Network or API issues | Check internet connection, retry |
| **Listening timeout** | Exceeded 30 seconds | Shorter phrases work better |

---

## Troubleshooting

### Microphone not working?

1. Check device permissions:
   - Android: Settings → Apps → Digital Wellness Assistant → Permissions → Microphone
   - iOS: Settings → Digital Wellness Assistant → Microphone

2. Restart the app

3. Restart your device

### Text not appearing?

1. Ensure microphone is not muted (hardware mute switch)
2. Try in a quieter environment
3. Speak more clearly
4. Ensure app has internet connection

### Slow transcription?

- Network latency affects real-time recognition
- Move closer to Wi-Fi if using cellular
- Some devices process slower - this is normal

---

## Future Enhancements

🚀 **Planned improvements:**

- [ ] Offline speech recognition
- [ ] Multiple language support with language auto-detection
- [ ] Voice tone/emotion analysis from audio
- [ ] Sound visualization waveform
- [ ] Playback of recorded audio
- [ ] Voice profile creation (personalized voice shortcuts)
- [ ] Sentiment analysis from speech patterns
- [ ] Accent/dialect adaptation

---

## Security & Privacy

**Data Handling:**

- ✅ Speech processing on-device when possible (Flutter)
- ✅ Transcribed text sent like regular chat messages
- ✅ Audio files not stored unless explicitly saved
- ✅ Microphone only accessed when user activates voice mode

**Best Practices:**

- User controls when microphone is active
- Permission system ensures explicit user consent
- Network requests follow same security as text chat
- HTTPS recommended for production deployment

---

## Code Examples

### Basic Usage in Flutter

```dart
final voiceService = VoiceService();

// Initialize
await voiceService.initialize();

// Set up callbacks
voiceService.onTextRecognized = (text) {
  setState(() {
    _controller.text = text;
  });
};

voiceService.onError = (error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error)),
  );
};

// Start listening
await voiceService.startListening();

// Stop listening
await voiceService.stopListening();
```

### Using Backend Voice Endpoint

```dart
final response = await http.post(
  Uri.parse('$apiBaseUrl/voice/transcribe'),
  headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  body: <String, String>{'audio': audioData},
);
```

---

## Support & Resources

- 📚 [speech_to_text Documentation](https://pub.dev/packages/speech_to_text)
- 🔐 [permission_handler Documentation](https://pub.dev/packages/permission_handler)
- 🎤 [Flutter Speech Recognition Guide](https://flutter.dev/docs)
- 🐍 [SpeechRecognition Python Library](https://pypi.org/project/SpeechRecognition/)

---

## Version History

### v1.0.0 (Current)

✅ Voice input with real-time transcription  
✅ Text input preserved alongside voice  
✅ Sound level visualization  
✅ Microphone permission handling  
✅ Backend voice processing endpoints (optional)  
✅ Multi-platform support (Android, iOS, partial Web)  

---

**Enjoy speaking with your wellness companion! 🎙️**
