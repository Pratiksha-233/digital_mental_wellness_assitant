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
  final bool _registerButtonPressed = false;
  late final AnimationController _lottiePulseController;
  late final Animation<double> _lottieScale;
  
  bool _showPassword = false;
  bool _showConfirmPassword = false;

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
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1), // Light teal background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: 450, // Fixed width for card look
            padding: const EdgeInsets.all(40.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 // Illustration
                 SizedBox(
                    height: 150,
                    child: Lottie.network(
                      'https://assets7.lottiefiles.com/packages/lf20_tfb3estd.json', // Keeping existing Lottie
                      fit: BoxFit.contain,
                    ),
                 ),
                 const SizedBox(height: 24),
                 const Text(
                   'Create Account',
                   style: TextStyle(
                     fontSize: 28,
                     fontWeight: FontWeight.bold,
                     color: Color(0xFF009688),
                   ),
                 ),
                 const SizedBox(height: 8),
                 const Text(
                   'Join us to start your wellness journey',
                   style: TextStyle(
                     fontSize: 14,
                     color: Colors.grey,
                   ),
                 ),
                 const SizedBox(height: 32),
                 
                 // Name Field
                 TextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _emailFocus.requestFocus(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      hintText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                 ),
                 const SizedBox(height: 16),
                 
                 // Email Field
                 TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocus,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      hintText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                 ),
                 const SizedBox(height: 16),
                 
                 // Password Field
                 TextField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    focusNode: _passwordFocus,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.teal),
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                       contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                 ),
                 const SizedBox(height: 16),

                 // Confirm Password Field
                 TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    focusNode: _confirmPasswordFocus,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _register(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      hintText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.teal),
                      suffixIcon: IconButton(
                        icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                        onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                       contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                 ),
                 const SizedBox(height: 32),

                 // Sign Up Button
                 SizedBox(
                   width: double.infinity,
                   height: 50,
                   child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688), // Teal to match login
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            'Sign Up', 
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                   ),
                 ),

                 const SizedBox(height: 24),
                 
                 // Login Link
                 Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ", 
                        style: TextStyle(color: Colors.grey)
                      ),
                      GestureDetector(
                        onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF009688),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
