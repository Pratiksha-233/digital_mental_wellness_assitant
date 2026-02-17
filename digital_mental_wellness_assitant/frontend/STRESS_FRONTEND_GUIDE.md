# Frontend Stress Display Implementation Guide

## Overview

The stress level system displays customer stress levels with beautiful, intuitive UI components. Here's how it appears on the frontend.

---

## 📊 Visual Components

### 1. **Stress Level Gauge (Main Display)**

```
┌─────────────────────────────────┐
│                                 │
│         😟 (Emoji)             │
│                                 │
│          52.35                  │
│       Stress Level              │
│                                 │
│  [====●═════════════]           │
│      ↑ Animated gauge           │
│                                 │
│     ┌─────────────────┐         │
│     │     HIGH        │         │
│     │    (Category)   │         │
│     └─────────────────┘         │
│                                 │
└─────────────────────────────────┘
```

**Features:**
- Animated circular gauge (0-100)
- Color-coded by category:
  - 🟢 GREEN: LOW (0-25)
  - 🟡 YELLOW: MODERATE (25-50)
  - 🟠 ORANGE: HIGH (50-75)
  - 🔴 RED: CRITICAL (75-100)
- Emoji indicator changes per category
- Smooth animation when loading

**Code:**
```dart
StressLevelGauge(
  stressLevel: 52.35,
  stressCategory: 'HIGH',
)
```

---

### 2. **Stress Category Banner**

```
┌──────────────────────────────────────┐
│  HIGH              🟠                │
│                                      │
│  Primary Emotion: Anxiety            │
│  Energy Level: 4/10                  │
│  Mood Trend: 📈 improving            │
│                                      │
└──────────────────────────────────────┘
```

**Shows:**
- Current stress category
- Primary detected emotion
- Energy level (0-10 scale)
- Mood pattern trend (📈 improving, ➡️ stable, 📉 declining)

**Code:**
```dart
StressCategoryBanner(
  category: 'HIGH',
  emotion: 'Anxiety',
  energyLevel: 4,
  moodPattern: 'improving',
)
```

---

### 3. **Contributing Factors Card**

```
┌────────────────────────────────┐
│  📊 Contributing Factors       │
├────────────────────────────────┤
│  1. Emotions          75.3%    │
│     [████████████──────]       │
│                                │
│  2. Mood              68.5%    │
│     [███████████─────]         │
│                                │
│  3. Energy Levels     60.0%    │
│     [██████████───────]        │
│                                │
└────────────────────────────────┘
```

**Shows:**
- Top 3 contributing factors
- Individual contribution percentage
- Visual progress bar for each factor

**Code:**
```dart
ContributingFactorsCard(
  factors: stressData.contributingFactors,
)
```

---

### 4. **Recommendations Card**

```
┌──────────────────────────────────┐
│  💡 Personalized Recommendations│
├──────────────────────────────────┤
│  1. Practice daily meditation   │
│     (10-15 minutes).            │
│                                 │
│  2. Engage in regular exercise  │
│     to reduce stress hormones.  │
│                                 │
│  3. Talk to someone you trust   │
│     about your feelings.        │
│                                 │
└──────────────────────────────────┘
```

**Shows:**
- Numbered list of recommendations
- Contextual to stress category & emotion
- Text wrapping for longer recommendations

**Code:**
```dart
RecommendationsCard(
  recommendations: stressData.recommendations,
)
```

---

## 📱 Screen Layouts

### **Full Screen: Stress Analyzer**

```
┌───────────────────────────────────┐
│ ← Stress Level Analysis        ≡ │
├───────────────────────────────────┤
│  [Current] [History] [Stats]      │
├───────────────────────────────────┤
│                                   │
│    ╔════════════════╗             │
│    ║      52.35     ║ <- Gauge    │
│    ║  😟 Stress     ║             │
│    ║    Level       ║             │
│    ╚════════════════╝             │
│                                   │
│  ┌─────────────────────────────┐  │
│  │ HIGH 🟠                     │  │ <- Banner
│  │ Anxiety, Energy 4/10        │  │
│  │ Trend: 📈 improving         │  │
│  └─────────────────────────────┘  │
│                                   │
│  ┌─────────────────────────────┐  │
│  │ 📊 Contributing Factors     │  │ <- Factors
│  │ 1. Emotions      75.3%      │  │
│  │ [████████──────] ...        │  │
│  └─────────────────────────────┘  │
│                                   │
│  ┌─────────────────────────────┐  │
│  │ 💡 Recommendations         │  │ <- Recommendations
│  │ 1. Practice meditation...  │  │
│  │ 2. Engage in exercise...   │  │
│  │ 3. Talk to someone...      │  │
│  └─────────────────────────────┘  │
│                                   │
└───────────────────────────────────┘
```

### **Tab 1: Current (Default)**
Displays the animated gauge with all details

### **Tab 2: History (Last 30 Days)**

```
┌───────────────────────────────────┐
│ [Current] [History] [Stats]       │
├───────────────────────────────────┤
│                                   │
│  ┌──────────────────────────────┐ │
│  │ Last 30 Days                 │ │
│  │  ██                          │ │
│  │  ░░ █░    ░░  ░   ░░ ░░ ░░  │ │ <- Chart
│  │  ░░ █░ ░░ ░░ ░░░  ░░ ░░ ░░  │ │
│  │  ░░ ░░ ░░ ░░ ░░░  ░░ ░░ ░░  │ │
│  │  ░░░░ ░░ ░░ ░░░  ░░ ░░ ░░  │ │
│  └──────────────────────────────┘ │
│                                   │
│  📋 History Items (Most Recent)   │
│  ┌──────────────────────────────┐ │
│  │ 52 | HIGH                   │ │
│  │     Anxiety                 │ │
│  │     Feb 15, 2026            │ │
│  └──────────────────────────────┘ │
│  ┌──────────────────────────────┐ │
│  │ 48 | MODERATE               │ │
│  │     Worry                   │ │
│  │     Feb 14, 2026            │ │
│  └──────────────────────────────┘ │
│                                   │
└───────────────────────────────────┘
```

### **Tab 3: Statistics**

```
┌───────────────────────────────────┐
│ [Current] [History] [Stats]       │
├───────────────────────────────────┤
│  ┌──────────┬──────────┐          │
│  │ Average  │ Current  │          │
│  │ 48.5/100 │ 52.35/100│          │ <- Stats Grid
│  └──────────┴──────────┘          │
│  ┌──────────┬──────────┐          │
│  │   Min    │   Max    │          │
│  │ 20.0/100 │ 85.0/100 │          │
│  └──────────┴──────────┘          │
│                                   │
│  Overall Trend: 📈 Worsening      │
│                                   │
│  Distribution (Last 30 Days)      │
│  LOW:       3 [███............]   │
│  MODERATE:  8 [████████........]  │
│  HIGH:      3 [███............]   │
│  CRITICAL:  1 [█..............]   │
│                                   │
└───────────────────────────────────┘
```

---

## 🏠 Home Screen Integration

### **Quick Stress Indicator Widget**

```
┌──────────────────────────────────┐
│ Your Stress Level         🟠     │
│                                  │
│  52.35 / 100                     │
│  [████████───────────────]        │
│                                  │
│  😊 Anxiety│ ⚡ 4/10 │📈 Trend  │
│                                  │
└──────────────────────────────────┘
```

**Place on home screen:** Add to existing home screen above or below mood tracker

**Code to add in HomeScreen:**
```dart
// In home screen, add this widget
QuickStressIndicator(
  userId: widget.userId,
  onTap: () {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => StressAnalyzerScreenNew(userId: widget.userId),
    ));
  },
)
```

---

## ⚠️ Alert Banners

### **High Stress Alert**

```
┌────────────────────────────────────┐
│ ⚠️ High Stress Detected            │
│ Your stress level is HIGH. Consider│
│ taking some time to relax.         │
│                                    │
│       [Dismiss]  [View Details]    │
└────────────────────────────────────┘
```

**Code:**
```dart
StressAlertBanner(
  category: 'HIGH',
  message: 'Your stress level is HIGH. Consider taking some time to relax.',
  onViewDetails: () => Navigator.push(context, ...),
)
```

### **Critical Stress Alert**

```
┌────────────────────────────────────┐
│ 🔴 CRITICAL: Urgent Stress        │
│ Please seek professional support.  │
│ Resources available below.         │
│                                    │
│       [Dismiss]  [Get Help]        │
└────────────────────────────────────┘
```

---

## 🎨 Color Scheme

| Category | Color | RGB | Usage |
|----------|-------|-----|-------|
| LOW | Green | #4CAF50 | 0-25 |
| MODERATE | Amber | #FFC107 | 25-50 |
| HIGH | Orange | #FF9800 | 50-75 |
| CRITICAL | Red | #F44336 | 75-100 |
| Neutral | Blue | #2196F3 | Components |

---

## 📦 Files Created

1. **Models:**
   - `lib/models/stress_model.dart` - Data models

2. **Widgets:**
   - `lib/widgets/stress_widgets.dart` - Main display widgets
   - `lib/widgets/home_stress_widgets.dart` - Home screen widgets

3. **Screens:**
   - `lib/screens/stress_analyzer_screen_new.dart` - Full screen

4. **Services:**
   - `lib/services/stress_api_service.dart` - API integration

---

## 🔧 Integration Steps

### **Step 1: Import Models**
```dart
import 'package:your_app/models/stress_model.dart';
```

### **Step 2: Create API Service**
Add stress methods to your existing `ApiService`:
```dart
class ApiService {
  Future<Map<String, dynamic>?> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<StressData> getStressLevel({required int userId}) async {
    final response = await get('/api/stress/calculate?user_id=$userId');
    if (response == null) throw Exception('Failed to fetch stress');
    return StressData.fromJson(response['data']);
  }
}
```

### **Step 3: Add to Navigation**
In your main navigation or menu:
```dart
ListTile(
  leading: const Icon(Icons.show_chart),
  title: const Text('Stress Analysis'),
  onTap: () => Navigator.push(context, MaterialPageRoute(
    builder: (_) => StressAnalyzerScreenNew(userId: userId),
  )),
)
```

### **Step 4: Add to Home Screen**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Column(
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
    ),
  );
}
```

---

## 🎯 Key Features

✅ **Animated Gauge** - Smooth progress animation
✅ **Color Coding** - Visual category indicators
✅ **Tabbed Interface** - Switch between Current/History/Stats
✅ **Responsive** - Works on all screen sizes
✅ **Real-time Data** - Fetches from backend
✅ **Charts** - Simple bar charts for history
✅ **Alerts** - High/critical stress warnings
✅ **Recommendations** - Personalized actions
✅ **Mobile Optimized** - Touch-friendly interactions

---

## 🚀 Next Steps

1. ✅ Update `pubspec.yaml` with `http` and `intl` packages
2. ✅ Configure backend URL in API service
3. ✅ Test with sample user data
4. ✅ Customize colors to match your theme
5. ✅ Add push notifications for high stress alerts
6. ✅ Create stress reports (PDF export)
7. ✅ Add stress comparison with user groups

---

## 📞 Support

For issues or questions:
- Check backend logs: `backend/STRESS_CALCULATION_GUIDE.md`
- Verify API endpoints are running: `http://localhost:5000/api/stress/calculate?user_id=1`
- Check Flutter null safety compatibility with all models
