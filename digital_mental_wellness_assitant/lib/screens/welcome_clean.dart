import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/enter_broadcaster.dart';
import 'login_screen.dart';

enum _Hovered { none, btn1, btn2, btn3 }

class WelcomeClean extends StatefulWidget {
  const WelcomeClean({super.key});

  @override
  State<WelcomeClean> createState() => _WelcomeCleanState();
}

class _WelcomeCleanState extends State<WelcomeClean> with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _floatController;
  late final AnimationController _bgController;

  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _floatAnim;

  // button animations
  late final Animation<Offset> _btn1Offset;
  late final Animation<double> _btn1Fade;
  late final Animation<Offset> _btn2Offset;
  late final Animation<double> _btn2Fade;
  late final Animation<Offset> _btn3Offset;
  late final Animation<double> _btn3Fade;
  // hovered state and enter subscription
  _Hovered _hovered = _Hovered.none;
  late final StreamSubscription<void> _enterSub;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scaleAnim = CurvedAnimation(parent: _mainController, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _mainController, curve: const Interval(0.45, 1.0, curve: Curves.easeIn));

    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _floatAnim = Tween<Offset>(begin: Offset.zero, end: const Offset(0, 0.03)).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

  _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat(reverse: true);

    // staggered button animations using the same main controller
    _btn1Offset = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(CurvedAnimation(parent: _mainController, curve: const Interval(0.55, 0.75, curve: Curves.easeOut)));
    _btn1Fade = CurvedAnimation(parent: _mainController, curve: const Interval(0.55, 0.85, curve: Curves.easeIn));

    _btn2Offset = Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero).animate(CurvedAnimation(parent: _mainController, curve: const Interval(0.65, 0.85, curve: Curves.easeOut)));
    _btn2Fade = CurvedAnimation(parent: _mainController, curve: const Interval(0.65, 0.9, curve: Curves.easeIn));

    _btn3Offset = Tween<Offset>(begin: const Offset(0, 0.26), end: Offset.zero).animate(CurvedAnimation(parent: _mainController, curve: const Interval(0.75, 0.95, curve: Curves.easeOut)));
    _btn3Fade = CurvedAnimation(parent: _mainController, curve: const Interval(0.75, 1.0, curve: Curves.easeIn));

    _mainController.forward();
    _floatController.repeat(reverse: true);
    // subscribe to global Enter events
    _enterSub = EnterBroadcaster.instance.stream.listen((_) {
      if (!mounted) return;
      if (_hovered == _Hovered.btn1) {
        _handleLogin(context);
      } else if (_hovered == _Hovered.btn2) {
        _handleRegister(context);
      } else if (_hovered == _Hovered.btn3) {
        _handleExplore(context);
      } else {
        // default
        _handleLogin(context);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatController.dispose();
    _bgController.dispose();
    _enterSub.cancel();
    super.dispose();
  }

  // handlers used by keyboard/actions and buttons
  void _handleLogin(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _handleRegister(BuildContext context) {
    Navigator.pushNamed(context, '/register');
  }

  void _handleExplore(BuildContext context) {
    Navigator.pushNamed(context, '/recommendations');
  }

  @override
  Widget build(BuildContext context) {
    // Build the screen normally; Enter events are handled via EnterBroadcaster subscription.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // animated gradient background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final t = _bgController.value;
              final a1 = Colors.teal.shade200;
              // make the welcome background distinct (warm -> cool)
              final a2 = Colors.orange.shade100;
              final b1 = Colors.deepPurple.shade100;
              final b2 = Colors.pink.shade50;
              final g1 = Color.lerp(a1, b1, t)!;
              final g2 = Color.lerp(a2, b2, t)!;
              return Container(
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [g1, g2])),
                // small overlay will be painted by stack children below
              );
            },
          ),

          // decorative animated circles (subtle parallax)
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final t = _bgController.value;
              return IgnorePointer(
                child: Stack(
                  children: [
                    Positioned(
                      left: 40 + (20 * t),
                      top: 80 + (40 * (1 - t)),
                      child: Opacity(
                        opacity: 0.06 + (0.04 * t),
                        child: Container(width: 160, height: 160, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      ),
                    ),
                    Positioned(
                      right: 20 + (30 * (1 - t)),
                      bottom: 120 + (10 * t),
                      child: Opacity(
                        opacity: 0.05 + (0.03 * (1 - t)),
                        child: Container(width: 220, height: 220, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              final animationSize = (width * 0.5).clamp(120.0, 320.0);

              return Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SlideTransition(
                        position: _floatAnim,
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: Container(
                            width: animationSize,
                            height: animationSize,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.teal.shade100.withAlpha((0.6 * 255).round()), blurRadius: 12, offset: const Offset(0, 6))]),
                            child: ClipOval(
                              child: Center(
                                child: LayoutBuilder(builder: (c, bc) {
                                  return GestureDetector(
                                    onTap: () => _mainController.forward(from: 0),
                                    child: Lottie.network(
                                      'https://assets7.lottiefiles.com/packages/lf20_jbrw3hcz.json',
                                      fit: BoxFit.contain,
                                      width: bc.maxWidth * 0.85,
                                      height: bc.maxHeight * 0.85,
                                      repeat: true,
                                      frameBuilder: (context, child, composition) {
                                        if (composition == null) return const Center(child: CircularProgressIndicator());
                                        return child;
                                      },
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          children: [
                            Text('Digital Mental Wellness Assistant', textAlign: TextAlign.center, style: TextStyle(fontSize: (width * 0.05).clamp(18.0, 22.0), fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
                            const SizedBox(height: 8),
                            Text('Helping you reflect, recover and grow', style: TextStyle(fontSize: (width * 0.03).clamp(12.0, 14.0), color: Colors.black54)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SlideTransition(
                              position: _btn1Offset,
                              child: FadeTransition(
                                opacity: _btn1Fade,
                                    child: MouseRegion(
                                      onEnter: (_) => setState(() => _hovered = _Hovered.btn1),
                                      onExit: (_) => setState(() => _hovered = _hovered == _Hovered.btn1 ? _Hovered.none : _hovered),
                                      child: AnimatedScale(
                                        scale: _hovered == _Hovered.btn1 ? 1.03 : 1.0,
                                        duration: const Duration(milliseconds: 160),
                                        child: ElevatedButton(
                                          onPressed: () => _handleLogin(context),
                                          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48), backgroundColor: Colors.teal, foregroundColor: Colors.white),
                                          child: const Text('Login'),
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SlideTransition(
                              position: _btn2Offset,
                              child: FadeTransition(
                                opacity: _btn2Fade,
                                child: MouseRegion(
                                  onEnter: (_) => setState(() => _hovered = _Hovered.btn2),
                                  onExit: (_) => setState(() => _hovered = _hovered == _Hovered.btn2 ? _Hovered.none : _hovered),
                                  child: MouseRegion(
                                    onEnter: (_) => setState(() => _hovered = _Hovered.btn2),
                                    onExit: (_) => setState(() => _hovered = _hovered == _Hovered.btn2 ? _Hovered.none : _hovered),
                                    child: AnimatedScale(
                                      scale: _hovered == _Hovered.btn2 ? 1.03 : 1.0,
                                      duration: const Duration(milliseconds: 160),
                                      child: OutlinedButton(
                                        onPressed: () => _handleRegister(context),
                                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), side: const BorderSide(color: Colors.teal), foregroundColor: Colors.teal),
                                        child: const Text('Register'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SlideTransition(
                              position: _btn3Offset,
                              child: FadeTransition(
                                opacity: _btn3Fade,
                                child: MouseRegion(
                                  onEnter: (_) => setState(() => _hovered = _Hovered.btn3),
                                  onExit: (_) => setState(() => _hovered = _hovered == _Hovered.btn3 ? _Hovered.none : _hovered),
                                  child: MouseRegion(
                                    onEnter: (_) => setState(() => _hovered = _Hovered.btn3),
                                    onExit: (_) => setState(() => _hovered = _hovered == _Hovered.btn3 ? _Hovered.none : _hovered),
                                    child: AnimatedScale(
                                      scale: _hovered == _Hovered.btn3 ? 1.02 : 1.0,
                                      duration: const Duration(milliseconds: 160),
                                      child: TextButton(
                                        onPressed: () => _handleExplore(context),
                                        style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48), foregroundColor: Colors.teal.shade700),
                                        child: const Text('Explore Recommendations'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
