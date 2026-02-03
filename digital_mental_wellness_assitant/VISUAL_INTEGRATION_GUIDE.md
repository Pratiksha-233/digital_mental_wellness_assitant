# Visual Integration Guide - Realtime Emotion Detection UI

## Application Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Frontend                      │
│  ┌───────────────────────────────────────────────────┐  │
│  │  main.dart (Entry Point)                          │  │
│  │  • Initializes Firebase                           │  │
│  │  • Defines routes (including '/detection')        │  │
│  └───────────────────────────────────────────────────┘  │
│                      ↓                                    │
│  ┌───────────────────────────────────────────────────┐  │
│  │  home_screen.dart (After Login)                   │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │ AppBar                                      │ │  │
│  │  │ [←] Digital Wellness Home  [Detection]  [≡] │ │  │
│  │  │                            ↑Top-Right       │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │ Drawer (Sidebar)                            │ │  │
│  │  │ • Home                                      │ │  │
│  │  │ • Mood Tracker                              │ │  │
│  │  │ • Journal                                   │ │  │
│  │  │ • Meditate                                  │ │  │
│  │  │ • Realtime Detection  ←─ Added Menu Item   │ │  │
│  │  │ • Resources                                 │ │  │
│  │  │ • Edit Profile                              │ │  │
│  │  │ • Logout                                    │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  │  ┌─────────────────────────────────────────────┐ │  │
│  │  │ Body (Main Content)                         │ │  │
│  │  │ • Greeting & Progress Cards                 │ │  │
│  │  │ • Mood Checkins                             │ │  │
│  │  │ • Quick Links                               │ │  │
│  │  └─────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────┘  │
│                      ↓                                    │
│  ┌───────────────────────────────────────────────────┐  │
│  │  realtime_detection_screen.dart (New Screen)      │  │
│  │  • Emotion Detection UI                           │  │
│  │  • Text Input                                     │  │
│  │  • Results Display                                │  │
│  │  • History Tracking                               │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│             Realtime Detection Service                   │
│  • API Communication (HTTP)                             │
│  • Text Emotion Prediction                              │
│  • Image Emotion Prediction                             │
│  • Error Handling                                       │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                 Flask Backend API                        │
│  POST /api/detection/predict-emotion                    │
│  POST /api/detection/predict-image                      │
│  • ML Model Integration                                 │
│  • Face Detection (OpenCV)                              │
│  • Emotion Classification                               │
└─────────────────────────────────────────────────────────┘
```

---

## Home Screen with Menu Items Highlighted

```
┌─────────────────────────────────────────────────────────┐
│ ← │ Digital Wellness Home             │ [Detection] [≡] │  ← AppBar
│   │                                    ↑ Top-Right      │
│   │ This button navigates to           Button Added    │
│   │ Realtime Detection Screen                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Welcome back, User! ☀️                                │
│  Today is a beautiful day                              │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Your Progress                                   │  │
│  │ Mood Checkins: 5    Journal Entries: 3          │  │
│  │ Days Active: 12                                 │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Quick Links                                     │  │
│  │ [Mood] [Chat] [Stress] [Tips] [Meditation]     │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Affirmation of the Day                          │  │
│  │ "Small steps still move me forward"             │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
├─────────────────────────────────────────────────────────┤
│ Drawer Menu (Click ≡ to open)                          │
│ ┌──────────────────────────────┐                       │
│ │ Home                          │                       │
│ │ Mood Tracker                  │                       │
│ │ Journal                        │                       │
│ │ Meditate                       │                       │
│ │ Realtime Detection    ← ADDED │                       │
│ │ Resources                      │                       │
│ │ Edit Profile                   │                       │
│ │ Logout                         │                       │
│ └──────────────────────────────┘                       │
│                                                         │
│ "You're doing great. Take it one day at a time."      │
└─────────────────────────────────────────────────────────┘
```

---

## Realtime Detection Screen Layout

```
┌─────────────────────────────────────────────────────────┐
│ ← │ Realtime Emotion Detection          │ ⚙️            │  ← Back Button
├─────────────────────────────────────────────────────────┤
│                                                         │
│                    EMOTION RESULT CARD                 │
│  ┌───────────────────────────────────────────────────┐│
│  │                                                   ││
│  │                      😊                           ││
│  │                                                   ││
│  │                     HAPPY                         ││
│  │                                                   ││
│  │  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   ││
│  │  Confidence: 95.5%                               ││
│  │                                                   ││
│  └───────────────────────────────────────────────────┘│
│                                                         │
│                   INPUT SECTION                        │
│  ┌───────────────────────────────────────────────────┐│
│  │ Enter Text to Analyze                            ││
│  │                                                   ││
│  │ ┌────────────────────────────────────────────┐  ││
│  │ │ Type how you're feeling...                 │  ││
│  │ │ [multiline text input field]               │  ││
│  │ │                                            │  ││
│  │ │                                            │  ││
│  │ └────────────────────────────────────────────┘  ││
│  │                                                   ││
│  │ ┌────────────────────────────────────────────┐  ││
│  │ │   🧠  Detect Emotion                       │  ││
│  │ └────────────────────────────────────────────┘  ││
│  └───────────────────────────────────────────────────┘│
│                                                         │
│                   DETECTION HISTORY                    │
│  ┌───────────────────────────────────────────────────┐│
│  │ Recent Detections                                ││
│  │                                                   ││
│  │ ┌──────────────────────────────────────────────┐││
│  │ │ Text: "I'm so happy" → Emotion: happy      │││
│  │ └──────────────────────────────────────────────┘││
│  │                                                   ││
│  │ ┌──────────────────────────────────────────────┐││
│  │ │ Text: "Feeling neutral today" → Emotion:  │││
│  │ │ neutral                                     │││
│  │ └──────────────────────────────────────────────┘││
│  │                                                   ││
│  │ ┌──────────────────────────────────────────────┐││
│  │ │ Text: "A bit worried" → Emotion: fear     │││
│  │ └──────────────────────────────────────────────┘││
│  │                                                   ││
│  └───────────────────────────────────────────────────┘│
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## User Navigation Flow

```
START
  │
  ├─→ Login/Register
  │        │
  │        ↓
  └─→ Home Screen (After Login)
         │
         ├─ Option 1: Click "Detection" Button in Top-Right
         │           │
         │           ↓
         │   Realtime Detection Screen
         │           │
         │           ├─ Enter Text
         │           ├─ Click "Detect Emotion"
         │           ├─ View Results
         │           ├─ See Detection History
         │           │
         │           ↓
         │   [Back to Home]
         │
         └─ Option 2: Click Menu (≡) → "Realtime Detection"
                      │
                      ↓
             Realtime Detection Screen
                      │
                      ├─ Enter Text
                      ├─ Click "Detect Emotion"
                      ├─ View Results
                      ├─ See Detection History
                      │
                      ↓
               [Back to Home]
```

---

## API Communication Flow

```
┌──────────────────────────┐
│  Realtime Detection      │
│  Screen                  │
└──────────────────────────┘
           │
           │ User enters text
           │
           ↓
┌──────────────────────────────┐
│  RealtimeDetectionService    │
│  (API Client)                │
│  predictEmotion(text)        │
└──────────────────────────────┘
           │
           │ HTTP POST
           │ /api/detection/predict-emotion
           │
           ↓
┌──────────────────────────────────────┐
│  Flask Backend                       │
│  @detection_bp.route(...)            │
│  def predict_emotion()               │
│                                      │
│  ├─ Parse JSON                       │
│  ├─ Load ML Model                    │
│  ├─ Predict Emotion                  │
│  └─ Return JSON Response             │
└──────────────────────────────────────┘
           │
           │ Response JSON
           │
           ↓
┌──────────────────────────────────────┐
│  Realtime Detection Screen           │
│  Display Results                     │
│  • Emotion Label                     │
│  • Emoji                             │
│  • Confidence %                      │
│  • Add to History                    │
└──────────────────────────────────────┘
```

---

## Emotion Color Palette

```
HAPPY/JOY           SADNESS            ANGRY/ANGER
┌───────┐          ┌───────┐          ┌───────┐
│ 😊    │          │ 😢    │          │ 😠    │
│ AMBER │          │ BLUE  │          │ RED   │
└───────┘          └───────┘          └───────┘

FEAR               SURPRISE           DISGUST
┌───────┐          ┌───────┐          ┌───────┐
│ 😨    │          │ 😮    │          │ 🤢    │
│ PURPLE│          │ ORANGE│          │ GREEN │
└───────┘          └───────┘          └───────┘

NEUTRAL            LOVE
┌───────┐          ┌───────┐
│ 😐    │          │ 😍    │
│ GREY  │          │ PINK  │
└───────┘          └───────┘
```

---

## File Integration Diagram

```
main.dart
  │
  ├─ imports realtime_detection_screen.dart
  │
  └─ routes: {
       '/detection': RealtimeDetectionScreen()
     }

home_screen.dart
  │
  ├─ AppBar with Detection Button
  │  └─ onTap: Navigator.pushNamed(context, '/detection')
  │
  └─ Drawer Menu
     └─ ListTile "Realtime Detection"
        └─ onTap: Navigator.pushNamed(context, '/detection')

realtime_detection_screen.dart
  │
  └─ uses realtime_detection_service.dart
     │
     └─ RealtimeDetectionService.predictEmotion(text)
        └─ POST /api/detection/predict-emotion
           (Backend: realtimedetection_routes.py)
```

---

## Button Styling Details

### AppBar Detection Button
```
┌─────────────────────────────────┐
│ 🧠  Detection                   │
└─────────────────────────────────┘
  │
  ├─ Background: White (24% opacity)
  ├─ Border Radius: 20px
  ├─ Icon: psychology_rounded
  ├─ Font Size: 12px
  ├─ Icon Size: 20px
  ├─ Horizontal Padding: 12px
  └─ Vertical Padding: 8px
```

### Sidebar Menu Item
```
🧠  Realtime Detection
  │
  ├─ Icon: psychology
  ├─ Title Font: 16px
  ├─ Position: Between Meditate and Resources
  └─ Action: Navigate to /detection route
```

---

## Responsive Design

```
Mobile                  Tablet               Desktop
┌─────────┐        ┌──────────────┐    ┌──────────────────┐
│ ← │ Home│[≡]     │ ← │ Home    │[≡]  │ ← │ Home   │[≡] D│
├─────────┤        ├──────────────┤    ├──────────────────┤
│         │        │              │    │                  │
│ Content │        │   Content    │    │     Content      │
│         │        │              │    │                  │
└─────────┘        └──────────────┘    └──────────────────┘

All versions include:
- Detection button in top-right corner
- Realtime Detection menu item in sidebar
- Full responsive emotion detection UI
```

---

**Visual Integration Complete!** ✅

All menu items and UI elements are strategically placed for optimal user experience and accessibility.

