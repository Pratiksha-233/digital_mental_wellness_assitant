import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/enter_broadcaster.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/register_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/welcome_clean.dart';

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
            '/': (context) => const WelcomeClean(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const Placeholder(), // replace later
            '/journal': (context) => const Placeholder(),
            '/recommendations': (context) => const RecommendationScreen(),
          },
        ),
      ),
    );
  }
}
