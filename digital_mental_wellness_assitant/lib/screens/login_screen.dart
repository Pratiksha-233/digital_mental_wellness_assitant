import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/enter_broadcaster.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  late final AnimationController _bgController;
  late final AnimationController _formController;
  late final Animation<Offset> _formOffset;
  late final Animation<double> _formFade;
  late final AnimationController _lottiePulseController;
  late final Animation<double> _lottieScale;
  bool _loginButtonPressed = false;
  late final StreamSubscription<void> _enterSub;

  @override
  void initState() {
    super.initState();

  // background color animation (slower for a calmer feel)
  _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);

  // form entrance animation (longer + softer curve)
  _formController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  _formOffset = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic));
  _formFade = CurvedAnimation(parent: _formController, curve: const Interval(0.0, 1.0, curve: Curves.easeIn));
  _formController.forward();

  // small lottie pulse to make header feel alive
  _lottiePulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  _lottieScale = Tween<double>(begin: 0.98, end: 1.02).animate(CurvedAnimation(parent: _lottiePulseController, curve: Curves.easeInOut));

    _enterSub = EnterBroadcaster.instance.stream.listen((_) {
      if (!mounted) return;
      // trigger login when Enter is pressed anywhere
      _login();
    });
  }

  /// ---------------------------
  /// Email/Password Login
  /// ---------------------------
  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

  if (!mounted) return;

  if (res['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userId: res['user_id'], userName: (res['name'] ?? '').toString()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Login failed')),
      );
    }
  }

  @override
  void dispose() {
    _enterSub.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _lottiePulseController.dispose();
    _bgController.dispose();
    _formController.dispose();
    super.dispose();
  }

  /// ---------------------------
  /// Google Sign-In Function
  /// ---------------------------
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In successful!')),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    }
  }

  /// ---------------------------
  /// UI
  /// ---------------------------
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final t = _bgController.value;
        final c1 = Color.lerp(Colors.teal.shade50, Colors.blue.shade50, t)!;
        final c2 = Color.lerp(Colors.white, Colors.teal.shade100, t)!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
            backgroundColor: Colors.teal,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, c2]),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SlideTransition(
                position: _formOffset,
                child: FadeTransition(
                  opacity: _formFade,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      // small Lottie header with subtle pulse
                      ScaleTransition(
                        scale: _lottieScale,
                        child: SizedBox(
                          height: 120,
                          child: Lottie.network(
                            'https://assets10.lottiefiles.com/packages/lf20_jcikwtux.json',
                            fit: BoxFit.contain,
                            repeat: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        focusNode: _emailFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        focusNode: _passwordFocus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // login button with press-scale feedback
                      _isLoading
                          ? const CircularProgressIndicator()
                          : GestureDetector(
                              onTapDown: (_) => setState(() => _loginButtonPressed = true),
                              onTapUp: (_) => setState(() => _loginButtonPressed = false),
                              onTapCancel: () => setState(() => _loginButtonPressed = false),
                              onTap: _login,
                              child: AnimatedScale(
                                scale: _loginButtonPressed ? 0.98 : 1.0,
                                duration: const Duration(milliseconds: 80),
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(12)),
                                  child: const Center(
                                    child: Text('Login', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ),

                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: Image.asset('assets/google_logo.png', height: 20),
                        label: const Text('Continue with Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.grey)),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                            },
                            child: const Text('Register', style: TextStyle(color: Colors.teal)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
