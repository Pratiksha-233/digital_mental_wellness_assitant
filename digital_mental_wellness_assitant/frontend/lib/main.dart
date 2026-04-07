import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/enter_broadcaster.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/register_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/stress_analyzer_screen.dart';
import 'screens/stress_analyzer_screen_new.dart';
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/self_care_tips_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/week_view_screen.dart';
import 'screens/resources_screen.dart';
import 'screens/meditate_screen.dart';
import 'screens/realtime_detection_screen.dart';
import 'screens/help_support_screen.dart';
import 'services/profile_service.dart';
import 'services/backend_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'theme/brand_theme.dart';
import 'package:camera/camera.dart';

class _GlobalEnterIntent extends Intent {
  const _GlobalEnterIntent();
}

String? _initialStoredDisplayName;
int? _initialStoredUserId;
List<CameraDescription> _initialCameras = const [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackendConfig.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }
  } catch (_) {}

  try {
    _initialStoredDisplayName = await ProfileService.getDisplayName();
  } catch (_) {}
  try {
    _initialStoredUserId = await ProfileService.getUserId();
  } catch (_) {}

  if (!kIsWeb) {
    try {
      _initialCameras = await availableCameras().timeout(
        const Duration(seconds: 35),
      );
    } catch (_) {
      _initialCameras = const [];
    }
  } else {
    _initialCameras = const [];
  }
  runApp(const MentalWellnessApp());
}

class MentalWellnessApp extends StatelessWidget {
  const MentalWellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.enter): const _GlobalEnterIntent(),
        LogicalKeySet(LogicalKeyboardKey.numpadEnter):
            const _GlobalEnterIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _GlobalEnterIntent: CallbackAction<_GlobalEnterIntent>(
            onInvoke: (intent) {
              EnterBroadcaster.instance.emitEnter();
              return null;
            },
          ),
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Digital Mental Wellness Assistant',
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          themeMode: ThemeMode.system,
          home: const _RootRouter(),

          routes: {
            '/login': (c) => const LoginScreen(),
            '/register': (c) => const RegisterScreen(),
            '/mood': (c) => const MoodTrackerScreen(),
            '/chat': (c) => const ChatScreen(),
            '/selfcare': (c) => const SelfCareTipsScreen(),
            '/recommendations': (c) => const RecommendationScreen(),

            '/stress': (c) =>
                StressAnalyzerScreenNew(userId: _initialStoredUserId ?? 1),
            '/stress-old': (c) => const StressAnalyzerScreen(),
            '/profile': (c) => const ProfileScreen(),
            '/week': (c) => const WeekViewScreen(),
            '/resources': (c) => const ResourcesScreen(),
            '/meditation': (c) => const MeditateScreen(),
            '/detection': (c) =>
                RealtimeDetectionScreen(initialCameras: _initialCameras),
            '/help': (c) => const HelpSupportScreen(),
            '/home': (c) {
              final user = FirebaseAuth.instance.currentUser;
              return HomeScreen(
                userId: _initialStoredUserId ?? 0,
                userName:
                    _initialStoredDisplayName ??
                    user?.displayName ??
                    (user?.email?.split('@').first ?? 'User'),
              );
            },
          },
        ),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (user != null) {
          return HomeScreen(
            userId: _initialStoredUserId ?? 0,
            userName:
                _initialStoredDisplayName ??
                user.displayName ??
                (user.email?.split('@').first ?? 'User'),
          );
        }

        if (_initialStoredUserId != null) {
          return HomeScreen(
            userId: _initialStoredUserId!,
            userName: _initialStoredDisplayName ?? 'User',
          );
        }

        return const LandingPage();
      },
    );
  }
}
