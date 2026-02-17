# 🎯 Complete Stress Level System - Setup & Display Guide

## What You Now Have

A **complete stress level calculation & display system** that:
- ✅ Calculates stress from emotions, moods, energy, activity & trends
- ✅ Displays it with beautiful animated gauges on mobile
- ✅ Shows personalized recommendations
- ✅ Tracks history with charts
- ✅ Provides statistics and trend analysis

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                  FLUTTER FRONTEND                       │
├─────────────────────────────────────────────────────────┤
│  StressAnalyzerScreenNew          QuickStressIndicator  │
│  (Full Screen Analysis)           (Home Screen Widget)  │
│                                                         │
│  ↓                                                      │
│  StressLevelGauge | Banners | Cards | Charts          │
│  (Visual Components)                                    │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP Requests
                       ↓
┌─────────────────────────────────────────────────────────┐
│              PYTHON FLASK BACKEND                       │
├─────────────────────────────────────────────────────────┤
│  /api/stress/calculate     (Current stress level)      │
│  /api/stress/history       (Historical data)           │
│  /api/stress/stats         (Statistics & trends)       │
│  /api/stress/recommendation (Get recommendations)      │
│                            ↓                            │
│  StressCalculationService  →  5-Factor Algorithm      │
└──────────────────────────┬──────────────────────────────┘
                           │ Database Queries
                           ↓
┌─────────────────────────────────────────────────────────┐
│              MYSQL DATABASE                             │
├─────────────────────────────────────────────────────────┤
│  mental_wellness database                              │
│  - users (user data)                                   │
│  - mood_logs (mood tracking)                           │
│  - journal_entries (emotion from text)                 │
│  - chat_history (emotion from face)                    │
│  - activity_logs (activity tracking)                   │
│  - stress_logs (stress record storage)                 │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Files Created

### Backend Files
```
backend/
├── config.py                      (Updated with DB config)
├── .env                          (Database credentials)
├── app.py                        (Updated with stress routes)
├── services/
│   └── stress_service.py        (NEW: Stress calculation engine)
├── routes/
│   └── stress_routes.py         (NEW: 4 API endpoints)
├── check_db_connection.py        (DB test script)
├── init_db.py                    (DB initialization)
├── test_stress_calculation.py   (NEW: Test script)
└── STRESS_CALCULATION_GUIDE.md  (Backend documentation)
```

### Frontend Files
```
frontend/lib/
├── models/
│   └── stress_model.dart        (NEW: Data models)
├── widgets/
│   ├── stress_widgets.dart      (NEW: Display components)
│   └── home_stress_widgets.dart (NEW: Home screen widgets)
├── screens/
│   └── stress_analyzer_screen_new.dart  (NEW: Full screen)
├── services/
│   └── stress_api_service.dart  (NEW: API methods)
└── STRESS_FRONTEND_GUIDE.md     (Frontend documentation)
```

### Database
```
frontend/database/
└── mental_wellness.sql          (Updated with stress_logs table)
```

---

## 🚀 Quick Start

### **Step 1: Initialize Database**

```bash
cd backend
python -m backend.init_db
```

Or run directly in MySQL Workbench:
```sql
USE mental_wellness;
-- Copy contents from frontend/database/mental_wellness.sql
```

### **Step 2: Verify DB Connection**

```bash
cd backend
python test_stress_calculation.py
```

Expected output:
```
============================================================
🧠 STRESS LEVEL CALCULATION TEST
============================================================
✅ Database connection successful
✅ Found 2 users
✅ Stress Calculation Results:
   📊 Stress Level: 52.35/100
   📍 Category: HIGH
```

### **Step 3: Start Backend**

```bash
cd backend
python -m flask run --host 0.0.0.0 --port 5000
```

You should see:
```
 * Running on http://0.0.0.0:5000
 * API endpoints ready
```

### **Step 4: Update Frontend Config**

In `frontend/lib/services/api_service.dart`:
```dart
class ApiService {
  static const String baseUrl = 'http://localhost:5000';
  
  // Add these methods:
  Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('API Error: $e');
    }
    return null;
  }

  Future<StressData> getStressLevel({required int userId}) async {
    final response = await get('/api/stress/calculate?user_id=$userId');
    if (response == null) throw Exception('Failed to fetch stress');
    return StressData.fromJson(response['data']);
  }
  
  // ... other stress methods
}
```

### **Step 5: Add to Flutter Navigation**

In your main app or home screen:

```dart
import 'package:your_app/screens/stress_analyzer_screen_new.dart';
import 'package:your_app/widgets/home_stress_widgets.dart';

// Add to home screen
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ListView(
      children: [
        // Existing widgets...
        
        // Add stress indicator
        QuickStressIndicator(
          userId: widget.userId,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => StressAnalyzerScreenNew(userId: widget.userId),
            ));
          },
        ),
        
        // More widgets...
      ],
    ),
  );
}
```

### **Step 6: Run Flutter App**

```bash
cd frontend
flutter pub get
flutter run
```

---

## 🎨 What Users See

### **On Home Screen**
```
┌────────────────────────────────┐
│ Your Stress Level         🟠   │
│                                │
│  52.35 / 100                   │
│  [████████───────────────]     │
│                                │
│ 😊 Anxiety│ ⚡ 4/10│ 📈 Trend │
└────────────────────────────────┘
```

### **On Tap - Full Stress Analysis Screen**

**Tab 1: Current**
- Large animated stress gauge (0-100)
- Category indicator (LOW/MODERATE/HIGH/CRITICAL)
- Contributing factors breakdown
- Personalized recommendations

**Tab 2: History** 
- 30-day stress data
- Simple line chart
- Historical records with dates

**Tab 3: Statistics**
- Average, min, max stress
- Trend indicator
- Category distribution

---

## 📊 Sample API Responses

### **GET /api/stress/calculate?user_id=123**

**Request:**
```
GET http://localhost:5000/api/stress/calculate?user_id=123
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "stress_level": 52.35,
    "stress_category": "HIGH",
    "primary_emotion": "Anxiety",
    "energy_level": 4,
    "mood_pattern": "improving",
    "contributing_factors": [
      {
        "factor": "Emotions",
        "contribution": 75.3
      },
      {
        "factor": "Mood",
        "contribution": 68.5
      },
      {
        "factor": "Energy Levels",
        "contribution": 60.0
      }
    ],
    "recommendations": [
      "Practice daily meditation or mindfulness (10-15 minutes).",
      "Engage in regular exercise to reduce stress hormones.",
      "Talk to someone you trust about your feelings."
    ],
    "component_scores": {
      "emotion_score": 75.3,
      "mood_score": 68.5,
      "energy_score": 60.0,
      "activity_score": 45.0,
      "trend_score": 70.0
    }
  }
}
```

### **GET /api/stress/history?user_id=123&days=30**

```json
{
  "status": "success",
  "count": 15,
  "data": [
    {
      "stress_id": 45,
      "user_id": 123,
      "stress_level": 52.35,
      "stress_category": "HIGH",
      "primary_emotion": "Anxiety",
      "energy_level": 4,
      "mood_pattern": "improving",
      "timestamp": "2026-02-15T14:30:00"
    },
    // ... more records
  ]
}
```

### **GET /api/stress/stats?user_id=123**

```json
{
  "status": "success",
  "average_stress": 48.5,
  "min_stress": 20.0,
  "max_stress": 85.0,
  "current_stress": 52.35,
  "trend": "worsening",
  "period_days": 30,
  "total_records": 15,
  "low_count": 3,
  "moderate_count": 8,
  "high_count": 3,
  "critical_count": 1
}
```

---

## ✅ Testing Checklist

- [ ] Backend database initialized with schema
- [ ] API endpoints respond with test user
- [ ] Frontend imports models and services
- [ ] Home screen displays QuickStressIndicator
- [ ] Can navigate to full StressAnalyzerScreenNew
- [ ] Gauge animates when loading
- [ ] Tabs switch between Current/History/Stats
- [ ] Recommendations display correctly
- [ ] Colors match stress levels properly
- [ ] No console errors or warnings

---

## 🔍 Debugging

### **API not responding**
```bash
# Check if backend is running
curl http://localhost:5000/api/mood/logs?user_id=1

# If error, check logs:
cd backend
python -m flask run --debug
```

### **No stress data appearing**
- Verify user has mood logs (need at least 1 entry)
- Check journal entries for emotion detection
- Run test script: `python test_stress_calculation.py`

### **Database errors**
```bash
cd backend
python -m backend.check_db_connection
```

### **Flutter compilation errors**
```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

---

## 🎯 Next Enhancements

1. **Notifications**
   - Push alert when stress goes HIGH
   - Daily stress summary

2. **Exports**
   - PDF stress reports
   - CSV history export

3. **Integrations**
   - Connect to wearables (heart rate)
   - Weather impact on stress
   - Calendar events correlation

4. **Advanced Analytics**
   - Machine learning stress prediction
   - Peer comparison (anonymized)
   - Stress triggers identification

5. **Real-time**
   - WebSocket updates
   - Live stress tracking during activities

---

## 📚 Documentation Files

- **Backend:** `backend/STRESS_CALCULATION_GUIDE.md`
- **Frontend:** `frontend/STRESS_FRONTEND_GUIDE.md`
- **Database:** `frontend/database/mental_wellness.sql`

---

## 🎓 Key Concepts

**5-Factor Algorithm:**
```
Stress = (35% Emotions) + (25% Mood) + (15% Energy) 
       + (15% Activity) + (10% Trends)
```

**Stress Categories:**
- 🟢 LOW (0-25): Healthy, maintain routine
- 🟡 MODERATE (25-50): Take precautions
- 🟠 HIGH (50-75): Seek support
- 🔴 CRITICAL (75-100): Emergency support

**Data Sources:**
- Emotion detection from text (journal)
- Emotion detection from face (camera)
- Mood logs from user input
- Energy levels from mood tracking
- Activity tracking from user actions
- Historical trends from database

---

## 🚀 Deploy to Production

### Backend (Python):
```bash
# Use Gunicorn instead of Flask dev server
gunicorn -w 4 -b 0.0.0.0:5000 backend.app:app
```

### Frontend (Flutter):
```bash
# Build APK for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for Web
flutter build web --release
```

---

## ✨ You're All Set!

Your digital mental wellness assistant now has a **complete, production-ready stress level system** with:

✅ Backend calculation engine
✅ Frontend visualization
✅ Database persistence
✅ Historical tracking
✅ Analytics & statistics
✅ Personalized recommendations

**Start the system:**
```bash
# Terminal 1: Backend
cd backend && python -m flask run --host 0.0.0.0

# Terminal 2: Frontend
cd frontend && flutter run
```

Happy coding! 🎉
