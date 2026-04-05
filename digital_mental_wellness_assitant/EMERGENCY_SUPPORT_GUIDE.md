# 🆘 Emergency Support Feature

## Overview

An integrated emergency support system providing immediate access to crisis support helplines, emergency contacts, and coping strategies within the mental wellness app.

## Features

✨ **Key Capabilities:**
- 🚨 "Need Help Now?" button on home screen (prominent red button)
- 📞 Direct-dial emergency helplines (988, Crisis Text Line, etc.)
- 🌍 International helpline support (USA, UK, Australia, Malaysia, etc.)
- 💪 Quick coping strategies for crisis moments
- ✨ Inspirational reminders and affirmations
- 🛡️ Safety plan guidance
- 📚 Additional mental health resources
- 🔗 One-tap calling/texting to emergency services

---

## Components

### 1. Emergency Support Screen (`emergency_support_screen.dart`)
**Location:** `frontend/lib/screens/emergency_support_screen.dart`

**Main Sections:**
- **Crisis Alert Banner** - "You Are Not Alone" message
- **Emergency Helplines** - 8+ helpline contacts with direct-call capability
- **Quick Coping Strategies** - Navigable list of immediate crisis interventions
- **Inspirational Reminders** - Personalized affirmations based on time
- **Additional Resources** - Mental health information and support groups
- **Safety Plan Info** - Guidance for creating a personal safety plan

**Emergency Contacts Included:**
1. **National Suicide Prevention Lifeline** - 988 (USA, 24/7)
2. **Crisis Text Line** - Text HOME to 741741 (USA)
3. **1-800-273-8255** - Alternative USA hotline
4. **International Association** - Global resource finder
5. **Befrienders** - +60 3 7956 8144 (Malaysia)
6. **Samaritans** - 116 123 (UK)
7. **Lifeline Australia** - 13 11 14 (Australia)
8. **Emergency Services** - 911/112/999 (Global)

### 2. Home Screen Integration
**Button Placement:** Right on the main home screen, after the greeting card

**Button Features:**
- Red gradient background (alert color)
- Emergency icon (⚠️)
- "Need Help Now?" text with description
- Forward arrow indicating action
- Shadow effect for prominence
- One-tap navigation to emergency screen

### 3. Drawer Menu Integration
**Location:** Navigation drawer on home screen

**Menu Item:**
- "Need Help Now?" in red
- Emergency icon
- Placed prominently before settings

---

## User Flow

```
┌─────────────────────────────────────────┐
│  User in crisis on home screen          │
└──────────────┬──────────────────────────┘
               │
               ├─► Option 1: Tap red "Need Help Now?" button
               │
               └─► Option 2: Open drawer → "Need Help Now?"
                            │
                            ▼
                ┌─────────────────────────────────┐
                │  Emergency Support Screen       │
                ├─────────────────────────────────┤
                │ "You Are Not Alone" banner      │
                │                                 │
                │ 📞 Emergency Helplines:         │
                │    [Tap to call]                │
                │    [Tap to text]                │
                │                                 │
                │ 💪 Coping Strategies:           │
                │    [Browse/Navigate]            │
                │                                 │
                │ ✨ Reminders & Resources       │
                └─────────────────────────────────┘
                            │
                            ├─► Call/Text helpline
                            ├─► Read coping strategy
                            ├─► View resources
                            └─► Create safety plan
```

---

## Technical Details

### Dependencies
- `url_launcher: ^6.2.0` - For direct phone/text dialing
- Flutter built-in services for UI/UX

### API Endpoints (Optional)
The emergency feature is client-side only. No backend integration required.

If you want to log crisis support access:
- `POST /api/analytics/crisis-support-accessed`
- `POST /api/analytics/helpline-contacted`

### Permissions Required
- No new permissions needed (uses existing phone/messaging capabilities)
- On Android/iOS: Implicit permissions for tel:// and sms:// schemes

---

## Installation & Setup

### 1. Add Dependency

The dependency is already added to `pubspec.yaml`:
```yaml
url_launcher: ^6.2.0
```

### 2. Install Packages

```bash
cd frontend
flutter pub get
```

### 3. Platform-Specific Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<!-- Already supported by default -->
<!-- No additional config needed -->
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tel</string>
  <string>sms</string>
</array>
```

### 4. Verify on Device

Test on actual device (not emulator for phone calls):
```bash
flutter run
```

Then:
1. Navigate to home screen
2. Look for red "Need Help Now?" button
3. Tap it
4. Verify emergency contacts are displayed
5. Test tapping a phone number (should trigger native dialer)

---

## Android Configuration Details

For phone calling to work properly on Android:

**`android/app/build.gradle`:**
```gradle
android {
    // Minimum API 21 supports tel: and sms: schemes
    minSdkVersion 21
}
```

**`AndroidManifest.xml`** (add if needed):
```xml
<uses-permission android:name="android.permission.CALL_PHONE" />
```

---

## iOS Configuration Details

**`ios/Runner/Info.plist`:**
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs local network access to connect emergency services.</string>

<key>NSBonjourServiceTypes</key>
<array>
  <string>_services._tcp</string>
</array>
```

---

## API Reference

### Emergency Contact Structure

```dart
class EmergencyContact {
  final String name;              // "National Suicide Prevention Lifeline"
  final String number;            // "988" or "+60 3 7956 8144"
  final String description;       // "Call or text 988 (available 24/7)"
  final String region;            // "United States", "Malaysia", etc.
  final IconData icon;            // Icons.phone, Icons.message, etc.
  final String type;              // 'phone', 'text', 'web', 'emergency'
}
```

### Launch Contact

```dart
EmergencyContact contact = emergencyContacts[0];

// Launch phone/text/web based on type
await contact.launch();
```

### Coping Strategies

10 built-in quick coping strategies:
1. Deep breathing techniques
2. Movement and exercise
3. Hydration reminders
4. Reaching out
5. Journaling
6. Music/sounds
7. Bathing/self-care
8. Nature connection
9. Social media distance
10. 5-4-3-2-1 grounding exercise

### Inspirational Reminders

8 rotating affirmations based on date/time:
- "Your feelings are temporary..."
- "You matter. Your life has value."
- "It's okay to not be okay..."
- "Crisis support is available 24/7..."
- "Asking for help is a sign of strength..."
- And more...

---

## Customization Guide

### Adding More Emergency Contacts

Edit `emergency_support_screen.dart`:

```dart
static const List<EmergencyContact> emergencyContacts = [
  // ... existing contacts ...
  
  // Add new contact:
  EmergencyContact(
    name: 'Your Helpline Name',
    number: '+1-XXX-XXX-XXXX',
    description: 'Description of service',
    region: 'Your Region',
    icon: Icons.phone,
    type: 'phone', // or 'text', 'web', 'emergency'
  ),
];
```

### Customizing Colors

In `emergency_support_screen.dart`, change color scheme:

```dart
// Change the alert banner color
backgroundColor: cs.errorContainer, // or any other color

// Change helpline card colors
cardColor: cs.primary.withValues(alpha: 0.15),
```

### Modifying Coping Strategies

```dart
static const List<String> copingStrategies = [
  '🧘 Your custom strategy here',
  // ... more strategies ...
];
```

### Changing Affirmations

```dart
static const List<String> reminders = [
  'Your custom reminder here',
  // ... more reminders ...
];
```

---

## Testing

### Manual Testing Checklist

- [ ] Home screen displays red "Need Help Now?" button
- [ ] Button is tappable and responsive
- [ ] Clicking button opens emergency support screen
- [ ] Emergency screen displays all sections properly
- [ ] "Need Help Now?" appears in drawer menu
- [ ] Drawer item is tappable
- [ ] Coping strategies can be navigated with Previous/Next
- [ ] Helpline numbers are displayed correctly
- [ ] Tapping a phone number number launches native dialer (on device)
- [ ] Tapping crisis text line option works (on device)
- [ ] All text is readable and properly formatted
- [ ] Screen works in both light and dark modes
- [ ] Screen is responsive on different device sizes
- [ ] Safety plan information is clear and actionable

### Automated Testing (Optional)

```dart
testWidgets('Emergency screen displays correctly', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: EmergencySupportScreen(),
  ));
  
  expect(find.text('Need Help Now?'), findsOneWidget);
  expect(find.text('You Are Not Alone'), findsOneWidget);
  expect(find.byIcon(Icons.emergency), findsWidgets);
});
```

---

## Troubleshooting

### Phone calling not working

**Problem:** Tapping phone number doesn't open dialer
- **Solution:** Test on actual device (not emulator)
- **Solution:** Verify `tel:` scheme is allowed in OS settings
- **Solution:** Check AndroidManifest.xml for CALL_PHONE permission

### Text messaging not working

**Problem:** Crisis Text Line button doesn't work
- **Solution:** Ensure `sms://` scheme is supported (all modern Android/iOS)
- **Solution:** Test on actual device with SMS capability

### Numbers not formatted correctly

**Problem:** Phone numbers display oddly
- **Solution:** Use international format: +[country][area][number]
- **Solution:** Test across different locales

### Colors not matching design

**Problem:** Colors look different in different themes
- **Solution:** Use `ColorScheme` colors (cs.error, cs.primary, etc.)
- **Solution:** Test in both light and dark mode

---

## Performance Notes

- No network requests (unless external resource clicked)
- Minimal memory footprint
- Fast navigation to emergency screen
- Lazy loading of resources

---

## Security & Privacy

✅ **Security Considerations:**
- No personal data collected during emergency flow
- No analytics tracking of crisis events (privacy-first)
- Direct connection to verified helplines
- No intermediary processing of emergency calls

✅ **Privacy Best Practices:**
- Option to log crisis support access can be disabled
- All data stays local to device
- No user identification required
- Respects user's emergency needs

---

## Future Enhancements

🚀 **Planned Features:**
- [ ] Geolocation to find nearest crisis center
- [ ] Emergency contact list (friends/family)
- [ ] Hospital location finder
- [ ] AI chatbot for immediate triage
- [ ] Integration with local emergency services
- [ ] Multi-language support for international helplines
- [ ] Offline access to helpline numbers
- [ ] SOS button integration (device hardware)
- [ ] Location sharing with trusted contacts
- [ ] Meditation/grounding exercise playback

---

## Accessibility

The emergency support feature is designed with accessibility in mind:

✅ **Features:**
- High contrast colors for visibility
- Large tap targets (minimum 48x48 dp)
- Semantic labeling for screen readers
- Clear, simple language
- Large readable fonts
- Icon + text combination for clarity

---

## Support & Resources

- 📚 [url_launcher Documentation](https://pub.dev/packages/url_launcher)
- 🔗 [National Suicide Prevention Lifeline](https://suicidepreventionlifeline.org)
- 🆘 [Crisis Text Line](https://www.crisistextline.org)
- 🌍 [International Association for Suicide Prevention](https://www.iasp.info)

---

## Version History

### v1.0.0 (Current)

✅ Home screen emergency button (red alert style)  
✅ Emergency support dedicated screen  
✅ 8+ international helplines with direct dialing  
✅ Quick coping strategies (10 options)  
✅ Inspirational reminders & affirmations  
✅ Safety plan guidance  
✅ Drawer menu integration  
✅ Dark/light mode support  
✅ Fully responsive design  

---

## Contact Information

For questions or to add/update helpline numbers:
- Create an issue in the project repository
- Suggest new helplines with contact information
- Share user feedback and feature requests

---

**Remember: If you or someone you know is in crisis, please reach out to a helpline immediately. You are not alone. 💙**
