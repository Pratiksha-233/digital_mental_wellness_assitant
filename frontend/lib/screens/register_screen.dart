import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/enter_broadcaster.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  late final StreamSubscription<void> _enterSub;
  late final AnimationController _bgController;
  late final AnimationController _formController;
  late final Animation<Offset> _formOffset;
  late final Animation<double> _formFade;
  bool _registerButtonPressed = false;
  late final AnimationController _lottiePulseController;
  late final Animation<double> _lottieScale;

  void _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await _authService.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

  if (!mounted) return;

    if (res['status'] == 'success') {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.removeCurrentMaterialBanner();
      messenger.showMaterialBanner(
        MaterialBanner(
          backgroundColor: Colors.green.shade50,
          leading: const Icon(Icons.check_circle, color: Colors.green),
          content: Text('Registered successfully: ${_nameController.text} (${_emailController.text})'),
          actions: [
            TextButton(
              onPressed: () => messenger.hideCurrentMaterialBanner(),
              child: const Text('DISMISS'),
            ),
          ],
        ),
      );
      // Navigate to login after short delay to let user read banner
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        messenger.hideCurrentMaterialBanner();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Registration failed')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // background animation (distinct palette, slightly slower)
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 11))..repeat(reverse: true);
    _formController = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
    _formOffset = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(parent: _formController, curve: Curves.easeOutBack));
  _formFade = CurvedAnimation(parent: _formController, curve: const Interval(0.0, 1.0, curve: Curves.easeIn));
    _formController.forward();

    // lottie pulse
    _lottiePulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    _lottieScale = Tween<double>(begin: 0.95, end: 1.03).animate(CurvedAnimation(parent: _lottiePulseController, curve: Curves.easeInOut));

    _enterSub = EnterBroadcaster.instance.stream.listen((_) {
      if (!mounted) return;
      _register();
    });
  }

  @override
  void dispose() {
    _enterSub.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _bgController.dispose();
    _formController.dispose();
    _lottiePulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final t = _bgController.value;
        final c1 = Color.lerp(Colors.purple.shade50, Colors.pink.shade50, t)!;
        final c2 = Color.lerp(Colors.white, Colors.pink.shade100, t)!;

        return Scaffold(
          appBar: AppBar(title: const Text('Register'), backgroundColor: Colors.pink),
          body: Container(
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [c1, c2])),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SlideTransition(
                position: _formOffset,
                child: FadeTransition(
                  opacity: _formFade,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      ScaleTransition(
                        scale: _lottieScale,
                        child: SizedBox(height: 120, child: Lottie.network('https://assets7.lottiefiles.com/packages/lf20_tfb3estd.json', fit: BoxFit.contain, repeat: true)),
                      ),
                      const SizedBox(height: 8),
                      const Text('Create a New Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pink)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _emailFocus.requestFocus(),
                        decoration: InputDecoration(labelText: 'Full Name', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        focusNode: _emailFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                        decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        focusNode: _passwordFocus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _register(),
                        decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        focusNode: _confirmPasswordFocus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _register(),
                        decoration: InputDecoration(labelText: 'Confirm Password', prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                      const SizedBox(height: 18),

                      _isLoading
                          ? const CircularProgressIndicator()
                          : GestureDetector(
                              onTapDown: (_) => setState(() => _registerButtonPressed = true),
                              onTapUp: (_) => setState(() => _registerButtonPressed = false),
                              onTapCancel: () => setState(() => _registerButtonPressed = false),
                              onTap: _register,
                              child: AnimatedScale(
                                scale: _registerButtonPressed ? 0.98 : 1.0,
                                duration: const Duration(milliseconds: 80),
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(color: Colors.pink, borderRadius: BorderRadius.circular(12)),
                                  child: const Center(child: Text('Register', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
                                ),
                              ),
                            ),

                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Already have an account? "), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('Login', style: TextStyle(color: Colors.pink)))])
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
