import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/enter_broadcaster.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/register_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/stress_analyzer_screen.dart';
import 'screens/welcome_clean.dart';
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/self_care_tips_screen.dart';

class _GlobalEnterIntent extends Intent {
  const _GlobalEnterIntent();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MentalWellnessApp());
}

class MentalWellnessApp extends StatelessWidget {
  const MentalWellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Global Enter mapping: emit an Enter event to any interested screens/widgets.

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.enter): const _GlobalEnterIntent(),
        LogicalKeySet(LogicalKeyboardKey.numpadEnter): const _GlobalEnterIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _GlobalEnterIntent: CallbackAction<_GlobalEnterIntent>(onInvoke: (intent) {
            EnterBroadcaster.instance.emitEnter();
            return null;
          }),
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Digital Mental Wellness Assistant',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            // Use the new LandingPage as the front page
            '/': (context) => const LandingPage(),
            '/welcome': (context) => const WelcomeClean(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const Placeholder(), // replace later
            '/journal': (context) => const Placeholder(),
            '/mood': (context) => const MoodTrackerScreen(),
            '/chat': (context) => const ChatScreen(),
            '/selfcare': (context) => const SelfCareTipsScreen(),
            '/recommendations': (context) => const RecommendationScreen(),
            '/stress': (context) => const StressAnalyzerScreen(),
          },
        ),
      ),
    );
  }
}
