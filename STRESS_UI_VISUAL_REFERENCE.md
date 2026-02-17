# 🎨 Stress Level System - Visual Reference

## Frontend Display - Visual Examples

### Screen 1: HOME SCREEN - Quick Indicator

```
┌──────────────────────────────────────────┐
│            Mental Wellness              │
├──────────────────────────────────────────┤
│                                          │
│ 🏠 Home  💭 Moods  📝 Journal  ⚙️      │
│                                          │
├──────────────────────────────────────────┤
│                                          │
│  TODAY'S HIGHLIGHTS                     │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ 😊 Mood: Happy                    │ │
│  │ 📊 Journaled: 2 entries            │ │
│  │ ⚡ Energy: 8/10                   │ │
│  └────────────────────────────────────┘ │
│                                          │
│  YOUR STRESS LEVEL  (NEW!)              │
│  ┌────────────────────────────────────┐ │
│  │ Your Stress Level         🟠      │ │
│  │                                   │ │
│  │  52.35 / 100                      │ │
│  │  [████████───────────────────]    │ │
│  │                                   │ │
│  │ 😊 Anxiety | ⚡ 4/10 | 📈 Trend  │ │
│  │              ↓ TAP FOR DETAILS      │
│  └────────────────────────────────────┘ │
│                                          │
│  RECOMMENDED ACTIONS                     │
│  🧘 Meditate today                       │
│  🏃 Try a quick workout                  │
│  💧 Stay hydrated                        │
│                                          │
└──────────────────────────────────────────┘
```

---

### Screen 2: STRESS ANALYZER - Full View

#### TAB 1: CURRENT (Default)

```
┌──────────────────────────────────────────┐
│ ← Stress Level Analysis               ≡ │
├──────────────────────────────────────────┤
│  [Current⚪] [History] [Stats]          │
├──────────────────────────────────────────┤
│                                          │
│          ╭─────────────╮                │
│          │             │                │
│          │   😟(emoji) │                │
│          │             │                │
│          │  52.35      │ ← Large        │
│          │ Stress      │   Gauge        │
│          │ Level       │                │
│          │             │                │
│          ├─────────────┤ (Animated      │
│          │ ███████───  │  Progress)     │
│          │ [52% filled]│                │
│          ╰─────────────╯                │
│                                          │
│      ┌─────────────────────────────┐   │
│      │      HIGH                   │   │
│      │    (Category Badge)         │   │
│      └─────────────────────────────┘   │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │ HIGH 🟠                          │  │
│  │                                  │  │
│  │ Primary Emotion: Anxiety         │  │
│  │ Energy Level: 4/10               │  │
│  │ Mood Trend: 📈 improving         │  │
│  └──────────────────────────────────┘  │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │ 📊 Contributing Factors          │  │
│  │                                  │  │
│  │ 1. Emotions          75.3%       │  │
│  │    [████████████────────]        │  │
│  │                                  │  │
│  │ 2. Mood              68.5%       │  │
│  │    [███████████─────────]        │  │
│  │                                  │  │
│  │ 3. Energy Levels     60.0%       │  │
│  │    [██████████────────────]      │  │
│  └──────────────────────────────────┘  │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │ 💡 Personalized Recommendations │  │
│  │                                  │  │
│  │ 1. Practice daily meditation or │  │
│  │    mindfulness (10-15 minutes).  │  │
│  │                                  │  │
│  │ 2. Engage in regular exercise to│  │
│  │    reduce stress hormones.       │  │
│  │                                  │  │
│  │ 3. Talk to someone you trust    │  │
│  │    about your feelings.          │  │
│  │                                  │  │
│  │ 4. Try breathing exercises:     │  │
│  │    inhale 4, exhale 6 counts.   │  │
│  └──────────────────────────────────┘  │
│                                          │
└──────────────────────────────────────────┘
```

---

#### TAB 2: HISTORY (30 Days)

```
┌──────────────────────────────────────────┐
│ ← Stress Level Analysis               ≡ │
├──────────────────────────────────────────┤
│  [Current] [History⚪] [Stats]          │
├──────────────────────────────────────────┤
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ Last 30 Days                       │ │
│  │                                    │ │
│  │   ██    ░░  ░  ░░ ░░  ░░          │ │
│  │   ░░ ░░ ░░ ░░░ ░░ ░░░ ░░░        │ │
│  │   ░░░░ ░░ ░░░ ░░ ░░ ░░ ░          │ │
│  │   ░░░░ ░░ ░░░░░░░░░░░░░░          │ │
│  └────────────────────────────────────┘ │
│                                          │
│  RECENT RECORDS (Most Recent First)     │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ ┌──┐                                │ │
│  │ │52│  HIGH 🟠                      │ │
│  │ └──┘  Emotion: Anxiety            │ │
│  │        Feb 15, 2026, 2:30 PM      │ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ ┌──┐                                │ │
│  │ │48│  MODERATE 🟡                  │ │
│  │ └──┘  Emotion: Worry              │ │
│  │        Feb 14, 2026, 10:15 AM     │ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │ ┌──┐                                │ │
│  │ │35│  MODERATE 🟡                  │ │
│  │ └──┘  Emotion: Neutral            │ │
│  │        Feb 13, 2026, 5:45 PM      │ │
│  └────────────────────────────────────┘ │
│                                          │
│  [Load More...]                          │
│                                          │
└──────────────────────────────────────────┘
```

---

#### TAB 3: STATISTICS

```
┌──────────────────────────────────────────┐
│ ← Stress Level Analysis               ≡ │
├──────────────────────────────────────────┤
│  [Current] [History] [Stats⚪]          │
├──────────────────────────────────────────┤
│                                          │
│  KEY METRICS (Last 30 Days)             │
│                                          │
│  ┌──────────────┬──────────────┐       │
│  │  Average     │   Current    │       │
│  │  48.5 / 100  │  52.35 / 100 │       │
│  │  🟡          │  🟠          │       │
│  └──────────────┴──────────────┘       │
│                                          │
│  ┌──────────────┬──────────────┐       │
│  │   Minimum    │   Maximum    │       │
│  │  20.0 / 100  │  85.0 / 100  │       │
│  │  🟢          │  🔴          │       │
│  └──────────────┴──────────────┘       │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │ Overall Trend:   📈 Worsening    │  │
│  │ Total Records:   15              │  │
│  │ Analysis Period: 30 Days         │  │
│  └──────────────────────────────────┘  │
│                                          │
│  DISTRIBUTION                            │
│                                          │
│  LOW STRESS       3  [███...........]  │
│  25% of days     10% (days: 2, 8, 22) │
│                                          │
│  MODERATE         8  [████████......]  │
│  53% of days     27% (most common)    │
│                                          │
│  HIGH STRESS      3  [███...........]  │
│  20% of days     10% (days: 5, 15)   │
│                                          │
│  CRITICAL         1  [█.............]   │
│  7% of days      3%  (day: 12)       │
│                                          │
└──────────────────────────────────────────┘
```

---

## Color-Coded Stress Levels

```
STRESS LEVEL    COLOR        EMOJI    ACTION NEEDED
─────────────────────────────────────────────────
0 - 25          🟢 GREEN     😊       Continue current routine
(LOW)           #4CAF50

25 - 50         🟡 AMBER     😐       Monitor and take precautions
(MODERATE)      #FFC107

50 - 75         🟠 ORANGE    😟       Seek support, use coping strategies
(HIGH)          #FF9800

75 - 100        🔴 RED       😰       URGENT: Get professional help
(CRITICAL)      #F44336
```

---

## Animated Gauge Example

**Frame-by-frame animation as user opens app:**

```
Frame 1 (0ms):        Frame 5 (600ms):       Frame 10 (1000ms):
┌─────────┐           ┌─────────┐            ┌─────────┐
│    0%   │           │   26%   │            │   52%   │
│    ●    │           │  ●──    │            │ ───●──  │
└─────────┘           └─────────┘            └─────────┘

Frame 15 (1500ms):    FINAL (Stabilized):
┌─────────┐           ┌─────────┐
│   52%   │           │  52.35  │
│ ───●──  │           │ ───●──  │
└─────────┘           │ [Done]  │
                      └─────────┘
```

---

## Interactive Elements

### Widget Interactions:

```
HOME SCREEN WIDGET
└─ On Tap ──→ Navigate to StressAnalyzerScreenNew
   ├─ Tab to Current ──→ Show Gauge + Details
   ├─ Tab to History ──→ Show Chart + Records
   └─ Tab to Stats ──→ Show Numbers + Distribution

GAUGE
└─ Long Press ──→ Show tooltip with breakdown

RECOMMENDATION
└─ On Tap ──→ Expand full text or navigate to resource

RECORD IN HISTORY
└─ On Tap ──→ Show full details for that day
```

---

## Notification/Alert Examples

### Alert 1: High Stress Detected

```
┌────────────────────────────────┐
│ 🟠 High Stress Detected        │
├────────────────────────────────┤
│                                │
│ Your stress level is HIGH       │
│ (52.35/100). Consider taking   │
│ some time to relax.            │
│                                │
│         [Dismiss] [View Details]
└────────────────────────────────┘
```

### Alert 2: Critical Stress

```
┌────────────────────────────────┐
│ 🔴 CRITICAL STRESS ALERT       │
├────────────────────────────────┤
│                                │
│ ⚠️ Your stress level is        │
│ CRITICAL (82/100).            │
│                                │
│ Please seek professional       │
│ support immediately.           │
│                                │
│    📞 1-800-HELP    [Resources]
└────────────────────────────────┘
```

---

## Responsive Design

### Mobile (Vertical Layout)
```
┌─────────────────┐
│ Header          │
├─────────────────┤
│ [Tabs]          │
├─────────────────┤
│ Gauge Content   │
│ (Takes full    │
│  width)        │
├─────────────────┤
│ Cards below     │
│ (Stacked)      │
└─────────────────┘
```

### Tablet (Horizontal Optimization)
```
┌──────────────────────────────────────┐
│ Header                               │
├──────────────────────────────────────┤
│ [Tabs]                               │
├───────────────────┬──────────────────┤
│ Gauge (Left)      │ Cards (Right)    │
│                   │ Stacked          │
│                   │                  │
│                   │                  │
└───────────────────┴──────────────────┘
```

---

## Data Flow Example

**User opens app:**

```
1. App loads HomeScreen
   ↓
2. QuickStressIndicator widget appears
   ↓ (User data: userId = 123)
3. Calls: GET /api/stress/calculate?user_id=123
   ↓
4. Backend queries database:
   - Last 7 days mood logs (energy levels)
   - Last 7 days journal entries (emotions)
   - Last 7 days chat history (detected emotions)
   - Activity logs (frequency)
   ↓
5. Calculates:
   Stress = (Emotion×35%) + (Mood×25%) 
          + (Energy×15%) + (Activity×15%) + (Trend×10%)
   Stress = (75.3×0.35) + (68.5×0.25) + (60.0×0.15) 
          + (45.0×0.15) + (70.0×0.10)
   Stress = 52.35 / 100
   ↓
6. Returns JSON response with:
   - stress_level: 52.35
   - stress_category: "HIGH"
   - primary_emotion: "Anxiety"
   - recommendations: [...]
   ↓
7. Flutter widget receives data
   ↓
8. Widget renders:
   - Color: Orange (#FF9800)
   - Emoji: 😟
   - Gauge animates to 52.35
   ↓
9. User sees: "Your Stress Level: 52.35 / 100 [HIGH]"
   ↓
10. User taps → Full StressAnalyzerScreenNew opens
```

---

## Performance Metrics

```
Component               Load Time    Animation Time   Memory
───────────────────────────────────────────────────────────
QuickStressIndicator    ~500ms       Instant         ~2MB
StressLevelGauge        N/A          1500ms (smooth) ~1MB
Full Screen             ~1000ms      Various         ~5MB
Chart (30 days)         ~800ms       Instant         ~3MB
```

---

## Accessibility Features

✅ **Color Blind Friendly:**
- Not relying on color alone (uses emoji + text)
- High contrast ratios

✅ **Large Touch Targets:**
- Minimum 48x48 dp for all buttons
- Cards have good spacing

✅ **Text Scaling:**
- All text supports system font size
- No fixed sizes below 12dp

✅ **Screen Reader Support:**
- Semantic labels for all widgets
- Descriptive button names

---

## Summary

Your stress level system displays:
- ✅ Real-time stress gauge with animations
- ✅ Color-coded categories with emoji
- ✅ Detailed breakdown of contributing factors
- ✅ Personalized recommendations
- ✅ Historical data visualization
- ✅ Statistical analysis
- ✅ Smooth user experience
- ✅ Mobile-optimized design
- ✅ Interactive and responsive
- ✅ Professionally styled

**Result: Beautiful, intuitive stress level displays for your users!** 🎉
