# Quick Start Guide - Realtime Emotion Detection

## 🚀 Quick Setup (5 minutes)

### Step 1: Start Backend
```powershell
cd C:\Users\Lenovo\Desktop\project\digital_mental_wellness_assitant
python -m backend.app
```
**Expected Output:**
```
[SUCCESS] Loaded model from: ...sentiment_model.h5
[SUCCESS] Model and preprocessing loaded.
Running on http://127.0.0.1:5000
```

### Step 2: Start Frontend
```powershell
cd C:\Users\Lenovo\Desktop\project\digital_mental_wellness_assitant\frontend
flutter run -d chrome
```
**Expected Output:**
- Chrome browser opens automatically
- Flutter app loads

### Step 3: Login
1. Click "Login" or "Register"
2. Use your credentials
3. You're now on the Home Screen

### Step 4: Access Detection Feature
**Option A - Top-Right Button (Fastest)**
- Look at the AppBar (top of screen)
- Click the "🧠 Detection" button
- Realtime Detection Screen opens instantly

**Option B - Sidebar Menu**
- Click the hamburger menu (≡) at top-left
- Scroll to "Realtime Detection"
- Click it
- Realtime Detection Screen opens

### Step 5: Test Emotion Detection
1. Type text: "I'm feeling great today!"
2. Click "Detect Emotion" button
3. See result: 😊 Happy
4. Repeat with different emotions

---

## 📝 Example Test Inputs

```
Positive Emotions:
✓ "I'm so happy and excited!"        → Joy/Happy
✓ "I love this moment"               → Love
✓ "Feeling amazing and blessed"      → Happy

Negative Emotions:
✓ "I feel sad and alone"             → Sadness
✓ "This makes me angry"              → Anger
✓ "I'm scared and worried"           → Fear
✓ "That disgusts me"                 → Disgust

Neutral:
✓ "Just a normal day"                → Neutral
✓ "It is what it is"                 → Neutral
```

---

## 🎯 Key Features

### Detection Result Card
```
😊          ← Emoji representation
Happy       ← Emotion label
████████░░  ← Confidence bar
95.5%       ← Confidence percentage
```

### Detection History
Shows your last 10 detections:
```
Text: "I'm so happy" → Emotion: happy
Text: "Feeling neutral" → Emotion: neutral
Text: "A bit worried" → Emotion: fear
```

### Error Handling
- **Empty text**: "Please enter some text"
- **No connection**: "Error: Connection refused"
- **Backend down**: "Error: Failed to connect"

---

## 🔧 API Testing (Advanced)

### Test via Command Line
```bash
# Open PowerShell
curl -X POST http://127.0.0.1:5000/api/detection/predict-emotion `
  -H "Content-Type: application/json" `
  -d '{\"text\": \"I am very happy\"}'

# Expected Response:
# {"status": "success", "emotion": "joy", "text": "I am very happy"}
```

---

## 📱 Menu Locations

### Top-Right Corner (Primary)
```
Digital Wellness Home    [🧠 Detection] [≡]
                          ↑ Click here
```

### Sidebar Menu
```
≡ Menu
├─ Home
├─ Mood Tracker
├─ Journal
├─ Meditate
├─ 🧠 Realtime Detection  ← Click here
├─ Resources
├─ Edit Profile
└─ Logout
```

---

## 🐛 Troubleshooting

### "Failed to connect to backend"
**Solution:**
1. Check backend is running
2. Ensure port 5000 is not blocked
3. Restart backend: `python -m backend.app`

### "Invalid JSON response"
**Solution:**
1. Backend might be crashing
2. Check backend terminal for errors
3. Restart Flutter: Press `r` in Flutter terminal

### "Detection button not visible"
**Solution:**
1. Make sure you're logged in
2. You should be on Home Screen
3. Check top-right of AppBar

### "Type errors in console"
**Solution:**
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter run -d chrome`

---

## 💡 Tips & Tricks

1. **Faster Access**: Use the Detection button in top-right corner
2. **See History**: Scroll down to see recent detections
3. **Clear Results**: Type new text to replace old results
4. **Multiple Emotions**: Test the same text multiple times to see consistency

---

## 🌈 Emotion Colors

| Emotion | Color | Emoji |
|---------|-------|-------|
| Happy | 🟨 Amber | 😊 |
| Sad | 🔵 Blue | 😢 |
| Angry | 🔴 Red | 😠 |
| Fear | 🟣 Purple | 😨 |
| Surprise | 🟠 Orange | 😮 |
| Disgust | 🟢 Green | 🤢 |
| Neutral | ⚫ Grey | 😐 |
| Love | 🩷 Pink | 😍 |

---

## 📊 Response Times

- **Average**: 1-2 seconds
- **Max**: 10 seconds (timeout)
- **ML Model Load**: 5-10 seconds on app startup

---

## ✨ Features Overview

✅ Text-based emotion detection
✅ Real-time analysis
✅ Beautiful UI with emojis
✅ Confidence scoring
✅ Detection history
✅ Color-coded results
✅ Error handling
✅ Two menu access points

---

## 🎓 How It Works

```
You → Type Text
      ↓
   Sends to Backend
      ↓
 ML Model Analyzes
      ↓
Backend Returns Emotion
      ↓
   Show Result
      ↓
Display Emoji + Confidence
      ↓
   Add to History
```

---

## 📚 Documentation Files

- **REALTIME_DETECTION_README.md** - Complete feature guide
- **INTEGRATION_SUMMARY.md** - Architecture and setup
- **MENU_INTEGRATION_GUIDE.md** - Menu locations and flow
- **VISUAL_INTEGRATION_GUIDE.md** - UI diagrams and layouts
- **IMPLEMENTATION_CHECKLIST.md** - Complete checklist

---

## 🚦 Status Lights

**Backend Status**
- 🟢 Running: `[SUCCESS] Model and preprocessing loaded`
- 🔴 Down: Connection refused error
- 🟡 Loading: Startup in progress

**Frontend Status**
- 🟢 Connected: "Detection" button visible
- 🔴 Disconnected: API errors in console
- 🟡 Loading: Waiting for response

---

## 🎉 You're All Set!

You now have a fully functional Realtime Emotion Detection feature integrated into your Digital Mental Wellness Assistant!

### Next Steps:
1. Test the feature with various emotions
2. Monitor backend logs for any issues
3. Share with users
4. Gather feedback
5. Plan enhancements

---

**Ready to detect emotions!** 🚀
