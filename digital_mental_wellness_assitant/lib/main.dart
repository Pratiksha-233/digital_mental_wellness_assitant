import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/enter_broadcaster.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/register_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/stress_analyzer_screen.dart';
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/self_care_tips_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/week_view_screen.dart';
import 'screens/resources_screen.dart';
import 'services/profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class _GlobalEnterIntent extends Intent {
  const _GlobalEnterIntent();
}

String? _initialStoredDisplayName; // loaded before runApp

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ensure auth persistence on web so refresh keeps the session
  try {
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }
  } catch (_) {}
  // Preload stored profile name so first frame can use it (especially for web refresh where async delay is noticeable)
  try {
    _initialStoredDisplayName = await ProfileService.getDisplayName();
  } catch (_) {}
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
          home: const _RootRouter(),
          // Restore named routes so Navigator.pushNamed works from landing page & other screens
          routes: {
            '/login': (c) => const LoginScreen(),
            '/register': (c) => const RegisterScreen(),
            '/mood': (c) => const MoodTrackerScreen(),
            '/chat': (c) => const ChatScreen(),
            '/selfcare': (c) => const SelfCareTipsScreen(),
            '/recommendations': (c) => const RecommendationScreen(),
            '/stress': (c) => const StressAnalyzerScreen(),
            '/profile': (c) => const ProfileScreen(),
            '/week': (c) => const WeekViewScreen(),
            '/resources': (c) => const ResourcesScreen(),
            '/home': (c) {
              final user = FirebaseAuth.instance.currentUser;
              return HomeScreen(
                userId: 0,
                userName: _initialStoredDisplayName ?? user?.displayName ?? (user?.email?.split('@').first ?? 'User'),
              );
            }
          },
        ),
      ),
    );
  }
}

// Root router decides which initial screen to show based on auth state.
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (user == null) {
          return const LandingPage();
        }
        // If user already signed in, go directly to Home with preloaded name.
        return HomeScreen(userId: 0, userName: _initialStoredDisplayName ?? user.displayName ?? (user.email?.split('@').first ?? 'User'));
      },
    );
  }
}
