# Stress Level Calculation System

## Overview

The stress level calculation system analyzes customer wellness data to compute a comprehensive stress score (0-100 scale) with personalized recommendations.

## How Stress is Calculated

The system uses a **weighted multi-factor approach**:

```
Stress Level = 
  (Emotion Score × 35%) +
  (Mood Score × 25%) +
  (Energy Score × 15%) +
  (Activity Score × 15%) +
  (Trend Score × 10%)
```

### Factor Breakdown

#### 1. **Emotion Score (35% weight)**
- Analyzes emotions detected from:
  - Text-based emotion detection (journal entries)
  - Face emotion detection (real-time camera)
- Recent 7 days of data
- Each emotion mapped to stress weight:
  - 🔴 **High Stress**: Anger (85), Fear (90), Anxiety (88)
  - 🟡 **Moderate Stress**: Sadness (75), Disgust (70)
  - 🟢 **Low Stress**: Happy (15), Joy (10), Love (5)

#### 2. **Mood Score (25% weight)**
- From mood logging entries (user-selected)
- Examples:
  - 🔴 Overwhelmed (95), Anxious (90)
  - 🟡 Frustrated (70), Worried (80)
  - 🟢 Relaxed (5), Peaceful (10)

#### 3. **Energy Score (15% weight)**
- Inverted relationship: **Low energy = High stress**
- 0-10 scale from mood logs
- Formula: `(10 - avg_energy) × 10`
- Example: Energy 3 → Stress 70

#### 4. **Activity Score (15% weight)**
- Baseline: ~50 activities per week (7 per day)
- ✅ ≥50 activities: Low stress (20)
- 🟡 25-50 activities: Moderate stress (50)
- ❌ <25 activities: High stress (80)

#### 5. **Trend Score (10% weight)**
- Compares this week vs last week energy levels
- 📈 Improving: Stress 30
- ➡️ Stable: Stress 50
- 📉 Worsening: Stress 70

## Stress Categories

| Category | Range | Meaning |
|----------|-------|---------|
| 🟢 **LOW** | 0-25 | Healthy stress levels |
| 🟡 **MODERATE** | 25-50 | Manageable, take precautions |
| 🟠 **HIGH** | 50-75 | Concerning, intervention recommended |
| 🔴 **CRITICAL** | 75-100 | Urgent, seek professional help |

## API Endpoints

### 1. Calculate Current Stress Level

**Endpoint:** `GET /api/stress/calculate?user_id=123`

**Response:**
```json
{
  "status": "success",
  "data": {
    "stress_level": 52.35,
    "stress_category": "HIGH",
    "primary_emotion": "Anxiety",
    "energy_level": 4,
    "mood_pattern": "declining",
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
      "Talk to someone you trust about your feelings.",
      "Try breathing exercises: inhale for 4, exhale for 6 counts."
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

---

### 2. Get Stress History

**Endpoint:** `GET /api/stress/history?user_id=123&days=30&limit=100`

**Query Parameters:**
- `user_id` (required): User ID
- `days` (optional): Number of days (default: 30)
- `limit` (optional): Max records (default: 100)

**Response:**
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
      "mood_pattern": "declining",
      "timestamp": "2026-02-15T14:30:00"
    },
    ...
  ]
}
```

---

### 3. Get Stress Statistics

**Endpoint:** `GET /api/stress/stats?user_id=123&days=30`

**Query Parameters:**
- `user_id` (required): User ID
- `days` (optional): Analysis period (default: 30)

**Response:**
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

### 4. Get Personalized Recommendations

**Endpoint:** `GET /api/stress/recommendation?user_id=123`

**Response:**
```json
{
  "status": "success",
  "stress_level": 52.35,
  "stress_category": "HIGH",
  "primary_emotion": "Anxiety",
  "recommendations": [
    "Practice daily meditation or mindfulness (10-15 minutes).",
    "Engage in regular exercise to reduce stress hormones.",
    "Talk to someone you trust about your feelings.",
    "Deep breathing: inhale for 4, hold for 4, exhale for 6 counts."
  ]
}
```

## Database Schema

### stress_logs Table
```sql
CREATE TABLE stress_logs (
    stress_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    stress_level FLOAT CHECK (stress_level >= 0 AND stress_level <= 100),
    stress_category VARCHAR(50),
    primary_emotion VARCHAR(50),
    energy_level INT,
    mood_pattern TEXT,
    activity_frequency INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_timestamp (timestamp),
    INDEX idx_stress_level (stress_level)
);
```

## Data Requirements

For accurate stress calculation, the system needs:

✅ **At least one entry** from each category in the last 7 days:
- Mood log (with energy level)
- Journal entry or chat history (for emotion detection)
- Activity log (for activity frequency)

⚠️ **If data is missing:**
- Calculation uses reasonable defaults (50 = neutral)
- More data = more accurate results

## Implementation Example (Frontend)

### Flutter/Dart Call

```dart
// Get stress level
final response = await http.get(
  Uri.parse('$backendUrl/api/stress/calculate?user_id=$userId'),
  headers: {'Content-Type': 'application/json'},
);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body)['data'];
  
  // Display results
  print('Stress Level: ${data['stress_level']}/100');
  print('Category: ${data['stress_category']}');
  print('Recommendations:');
  for (var rec in data['recommendations']) {
    print('• $rec');
  }
}

// Get history (for charts/graphs)
final historyResponse = await http.get(
  Uri.parse('$backendUrl/api/stress/history?user_id=$userId&days=30'),
);

if (historyResponse.statusCode == 200) {
  final history = jsonDecode(historyResponse.body)['data'];
  // Use for history visualization
}
```

## Testing

Run the test script to verify installation:

```bash
cd backend
python test_stress_calculation.py
```

Expected output:
```
============================================================
🧠 STRESS LEVEL CALCULATION TEST
============================================================

1️⃣ Testing database connection...
✅ Database connection successful

2️⃣ Checking for test users...
✅ Found 2 users:
   - User ID 1: John Doe (john@example.com)
   - User ID 2: Jane Smith (jane@example.com)

3️⃣ Calculating stress level for User ID 1...

✅ Stress Calculation Results:
   📊 Stress Level: 52.35/100
   📍 Category: HIGH
   ...
```

## Best Practices

### For Accurate Results:
1. **Encourage regular mood logging** (≥3 per week)
2. **Promote activity tracking** (target: 50+ per week)
3. **Enable emotion detection features** (journal + camera)
4. **Build historical data** (7+ days before meaningful trends)

### For Users:
1. **Check stress level regularly** (daily or weekly)
2. **Follow personalized recommendations**
3. **Track activities and moods consistently**
4. **Note improvements over time**

## Customization

### Adjust Emotion Weights
Edit `stress_service.py`:
```python
EMOTION_STRESS_WEIGHTS = {
    'anger': 85,      # ← Adjust these values
    'fear': 90,
    'anxiety': 88,
    ...
}
```

### Change Calculation Weights
In `calculate_stress_level()`:
```python
stress_level = (
    emotion_score * 0.35 +      # ← Change these percentages
    mood_score * 0.25 +
    energy_score * 0.15 +
    activity_score * 0.15 +
    trend_score * 0.10
)
```

### Add Custom Factors
1. Create new metric function
2. Add to overall calculation
3. Update weight percentages

## Troubleshooting

### Issue: All users show stress = 50
**Cause:** No historical data
**Solution:** Add mood logs, journal entries, and activities

### Issue: Stress never changes
**Cause:** Cached calculations or old timestamps
**Solution:** Check database timestamps, run `test_stress_calculation.py`

### Issue: Database errors
**Cause:** Missing stress_logs table
**Solution:** Run `python -m backend.init_db` to initialize schema

## Next Steps

1. ✅ Integrate into frontend dashboard
2. ✅ Add stress visualizations (charts/graphs)
3. ✅ Create stress trend alerts
4. ✅ Send notifications for critical stress levels
5. ✅ Add stress management resources database
6. ✅ Generate wellness reports

---

**For questions or issues:** Check logs in `backend/` or contact support.
