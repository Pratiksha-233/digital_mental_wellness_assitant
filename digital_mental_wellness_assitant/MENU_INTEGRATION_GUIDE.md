# Menu Integration Guide - Realtime Emotion Detection

## Where to Find the Feature

### 1. Top-Right Corner (AppBar Button) ⭐ PRIMARY
**Location**: Home Screen AppBar
**Button**: "Detection" with psychology icon
**How to Access**:
- After successful login
- Click the "Detection" button in the top-right corner
- Alternative button icon: `Icons.psychology_rounded`

**Code Location**: `frontend/lib/screens/home_screen.dart` (lines 234-263)

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

### 2. Sidebar Menu (Left Drawer)
**Location**: Home Screen Drawer
**Menu Item**: "Realtime Detection"
**Position**: Between "Meditate" and "Resources" options
**Icon**: `Icons.psychology`

**Code Location**: `frontend/lib/screens/home_screen.dart` (lines 191-194)

```dart
ListTile(
  leading: const Icon(Icons.psychology),
  title: const Text('Realtime Detection'),
  onTap: () => Navigator.pushNamed(context, '/detection')),
```

---

## Navigation Flow

```
Login Screen
    ↓
Home Screen
    ├─→ Top-Right "Detection" Button → Realtime Detection Screen
    └─→ Sidebar Menu → "Realtime Detection" → Realtime Detection Screen
```

---

## UI Components Reference

### AppBar Button Properties
- **Text**: "Detection"
- **Icon**: `Icons.psychology_rounded`
- **Position**: Top-right corner
- **Background**: White with 24% opacity
- **Border Radius**: 20px circular pill shape
- **Tooltip**: "Realtime Emotion Detection"

### Sidebar Menu Item Properties
- **Title**: "Realtime Detection"
- **Icon**: `Icons.psychology`
- **Icon Color**: Inherits from theme
- **Position**: After "Meditate", before "Resources"

---

## Accessing the Feature

### Method 1: Top-Right Button (Recommended)
1. Login to app
2. See home screen
3. Look at top-right corner of AppBar
4. Click "Detection" button
5. Realtime Detection Screen opens

### Method 2: Sidebar Menu
1. Login to app
2. See home screen
3. Click hamburger menu (top-left)
4. Click "Realtime Detection" from list
5. Realtime Detection Screen opens

---

## Screen Flow

```
Landing Page
    ↓
Login/Register
    ↓
Home Screen (AppBar with Detection button + Sidebar with Detection menu)
    ↓
    ├─→ [Top-Right Button] → Realtime Detection Screen
    └─→ [Sidebar Menu] → Realtime Detection Screen
```

---

## Realtime Detection Screen Layout

```
┌─────────────────────────────────────────┐
│ ← | Realtime Emotion Detection    | ⚙️  │  ← AppBar with back button
├─────────────────────────────────────────┤
│                                         │
│          [Emotion Result Card]          │
│          😊 Happy                       │
│          ▓▓▓▓▓▓░░░░ 95.5%              │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Enter Text to Analyze               ││
│  │ [Text input field]                  ││
│  │ [Detect Emotion Button]             ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Recent Detections                   ││
│  │ • Text: "..." → Emotion: happy      ││
│  │ • Text: "..." → Emotion: neutral    ││
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

---

## Route Configuration

**Route Path**: `/detection`

**Dart Navigation**:
```dart
// Via Navigator.pushNamed
Navigator.pushNamed(context, '/detection');

// Via direct instantiation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const RealtimeDetectionScreen()
  )
);
```

**Main Route Definition** (`frontend/lib/main.dart`):
```dart
'/detection': (c) => const RealtimeDetectionScreen(),
```

---

## Quick Access Reference

| Feature | Location | Button | Icon |
|---------|----------|--------|------|
| Realtime Detection | AppBar (Top-Right) | "Detection" | `psychology_rounded` |
| Realtime Detection | Sidebar Menu | "Realtime Detection" | `psychology` |

---

## User Journey

```
1. User opens app → Lands on landing page
2. User logs in → Goes to home screen
3. User sees AppBar with "Detection" button in top-right
4. User can also open sidebar and see "Realtime Detection" menu item
5. User clicks either button/menu to access detection feature
6. Emotion detection screen opens
7. User enters text
8. User clicks "Detect Emotion"
9. Results displayed with emoji, confidence, and history
```

---

## Styling Details

### AppBar Button
- **Font Size**: 12px
- **Icon Size**: 20px
- **Padding**: 12px horizontal, 8px vertical
- **Border Radius**: 20px
- **Background Color**: White with 24% opacity (Colors.white24)
- **Text Color**: White (default)

### Sidebar Menu Item
- **Font Size**: 16px (default)
- **Icon Size**: 24px (default)
- **Spacing**: Standard list tile spacing
- **Hover Effect**: Ripple effect (default)

---

**Menu Integration Complete!** ✅

Users can now easily access the realtime emotion detection feature from two convenient locations in the application.

