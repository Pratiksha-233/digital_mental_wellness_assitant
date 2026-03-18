import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/enter_broadcaster.dart';
import 'login_screen.dart';
import '../widgets/app_section_card.dart';

enum _Hovered { none, btn1, btn2, btn3 }

class WelcomeClean extends StatefulWidget {
  const WelcomeClean({super.key});

  @override
  State<WelcomeClean> createState() => _WelcomeCleanState();
}

class _WelcomeCleanState extends State<WelcomeClean>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _floatController;
  late final AnimationController _bgController;

  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _floatAnim;


  late final Animation<Offset> _btn1Offset;
  late final Animation<double> _btn1Fade;
  late final Animation<Offset> _btn2Offset;
  late final Animation<double> _btn2Fade;
  late final Animation<Offset> _btn3Offset;
  late final Animation<double> _btn3Fade;

  _Hovered _hovered = _Hovered.none;
  late final StreamSubscription<void> _enterSub;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.45, 1.0, curve: Curves.easeIn),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _floatAnim = Tween<Offset>(begin: Offset.zero, end: const Offset(0, 0.03))
        .animate(
          CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
        );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);


    _btn1Offset = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
          ),
        );
    _btn1Fade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.55, 0.85, curve: Curves.easeIn),
    );

    _btn2Offset = Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.65, 0.85, curve: Curves.easeOut),
          ),
        );
    _btn2Fade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.65, 0.9, curve: Curves.easeIn),
    );

    _btn3Offset = Tween<Offset>(begin: const Offset(0, 0.26), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.75, 0.95, curve: Curves.easeOut),
          ),
        );
    _btn3Fade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );

    _mainController.forward();
    _floatController.repeat(reverse: true);

    _enterSub = EnterBroadcaster.instance.stream.listen((_) {
      if (!mounted) return;
      if (_hovered == _Hovered.btn1) {
        _handleLogin(context);
      } else if (_hovered == _Hovered.btn2) {
        _handleRegister(context);
      } else if (_hovered == _Hovered.btn3) {
        _handleExplore(context);
      } else {

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


  void _handleLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _handleRegister(BuildContext context) {
    Navigator.pushNamed(context, '/register');
  }

  void _handleExplore(BuildContext context) {
    Navigator.pushNamed(context, '/recommendations');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [

          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final t = _bgController.value;
              final a1 = cs.primaryContainer;
              final a2 = cs.secondaryContainer;
              final b1 = cs.tertiaryContainer;
              final b2 = cs.surfaceContainerHighest;
              final g1 = Color.lerp(a1, b1, t)!;
              final g2 = Color.lerp(a2, b2, t)!;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [g1, g2],
                  ),
                ),

              );
            },
          ),


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
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: cs.onSurface,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20 + (30 * (1 - t)),
                      bottom: 120 + (10 * t),
                      child: Opacity(
                        opacity: 0.05 + (0.03 * (1 - t)),
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: cs.onSurface,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final animationSize = (width * 0.5).clamp(120.0, 320.0);


                return Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: width.clamp(300.0, 1400.0),
                      ),
                      child: width >= 900
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40.0,
                                      vertical: 24.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [

                                        SlideTransition(
                                          position: _floatAnim,
                                          child: ScaleTransition(
                                            scale: _scaleAnim,
                                            child: Container(
                                              width: (width * 0.35).clamp(
                                                120.0,
                                                320.0,
                                              ),
                                              height: (width * 0.35).clamp(
                                                120.0,
                                                320.0,
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: cs
                                                    .surfaceContainerHighest
                                                    .withValues(alpha: 0.70),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: cs.outlineVariant
                                                      .withValues(alpha: 0.75),
                                                ),
                                              ),
                                              child: ClipOval(
                                                child: Center(
                                                  child: LayoutBuilder(
                                                    builder: (c, bc) {
                                                      return GestureDetector(
                                                        onTap: () =>
                                                            _mainController
                                                                .forward(
                                                                  from: 0,
                                                                ),
                                                        child: Lottie.network(
                                                          'https://assets7.lottiefiles.com/packages/lf20_jbrw3hcz.json',
                                                          fit: BoxFit.contain,
                                                          width:
                                                              bc.maxWidth *
                                                              0.85,
                                                          height:
                                                              bc.maxHeight *
                                                              0.85,
                                                          repeat: true,
                                                          frameBuilder:
                                                              (
                                                                context,
                                                                child,
                                                                composition,
                                                              ) {
                                                                if (composition ==
                                                                    null) {
                                                                  return const Center(
                                                                    child:
                                                                        CircularProgressIndicator(),
                                                                  );
                                                                }
                                                                return child;
                                                              },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 18),


                                        FadeTransition(
                                          opacity: _fadeAnim,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Digital Mental Wellness Assistant',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: (width * 0.04)
                                                      .clamp(20.0, 28.0),
                                                  fontWeight: FontWeight.bold,
                                                  color: cs.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Helping you reflect, recover and grow',
                                                style: TextStyle(
                                                  fontSize: (width * 0.02)
                                                      .clamp(12.0, 14.0),
                                                  color: cs.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 20),


                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 24.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SlideTransition(
                                                position: _btn1Offset,
                                                child: FadeTransition(
                                                  opacity: _btn1Fade,
                                                  child: MouseRegion(
                                                    onEnter: (_) => setState(
                                                      () => _hovered =
                                                          _Hovered.btn1,
                                                    ),
                                                    onExit: (_) => setState(
                                                      () => _hovered =
                                                          _hovered ==
                                                              _Hovered.btn1
                                                          ? _Hovered.none
                                                          : _hovered,
                                                    ),
                                                    child: AnimatedScale(
                                                      scale:
                                                          _hovered ==
                                                              _Hovered.btn1
                                                          ? 1.03
                                                          : 1.0,
                                                      duration: const Duration(
                                                        milliseconds: 160,
                                                      ),
                                                      child: ElevatedButton(
                                                        onPressed: () =>
                                                            _handleLogin(
                                                              context,
                                                            ),
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              minimumSize:
                                                                  const Size(
                                                                    220,
                                                                    48,
                                                                  ),
                                                              backgroundColor:
                                                                  cs.primary,
                                                              foregroundColor:
                                                                  cs.onPrimary,
                                                            ),
                                                        child: const Text(
                                                          'Login',
                                                        ),
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
                                                    onEnter: (_) => setState(
                                                      () => _hovered =
                                                          _Hovered.btn2,
                                                    ),
                                                    onExit: (_) => setState(
                                                      () => _hovered =
                                                          _hovered ==
                                                              _Hovered.btn2
                                                          ? _Hovered.none
                                                          : _hovered,
                                                    ),
                                                    child: AnimatedScale(
                                                      scale:
                                                          _hovered ==
                                                              _Hovered.btn2
                                                          ? 1.03
                                                          : 1.0,
                                                      duration: const Duration(
                                                        milliseconds: 160,
                                                      ),
                                                      child: OutlinedButton(
                                                        onPressed: () =>
                                                            _handleRegister(
                                                              context,
                                                            ),
                                                        style:
                                                            OutlinedButton.styleFrom(
                                                              minimumSize:
                                                                  const Size(
                                                                    220,
                                                                    48,
                                                                  ),
                                                              side: BorderSide(
                                                                color:
                                                                    cs.primary,
                                                              ),
                                                              foregroundColor:
                                                                  cs.primary,
                                                            ),
                                                        child: const Text(
                                                          'Register',
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
                                                    onEnter: (_) => setState(
                                                      () => _hovered =
                                                          _Hovered.btn3,
                                                    ),
                                                    onExit: (_) => setState(
                                                      () => _hovered =
                                                          _hovered ==
                                                              _Hovered.btn3
                                                          ? _Hovered.none
                                                          : _hovered,
                                                    ),
                                                    child: AnimatedScale(
                                                      scale:
                                                          _hovered ==
                                                              _Hovered.btn3
                                                          ? 1.02
                                                          : 1.0,
                                                      duration: const Duration(
                                                        milliseconds: 160,
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () =>
                                                            _handleExplore(
                                                              context,
                                                            ),
                                                        style:
                                                            TextButton.styleFrom(
                                                              minimumSize:
                                                                  const Size(
                                                                    220,
                                                                    48,
                                                                  ),
                                                              foregroundColor:
                                                                  cs.primary,
                                                            ),
                                                        child: const Text(
                                                          'Explore Recommendations',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),


                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: AppSectionCard(
                                      padding: const EdgeInsets.all(28.0),
                                      gradient:
                                          AppSectionCard.gradientFromScheme(
                                            cs,
                                            a: cs.surfaceContainerHighest,
                                            b: cs.surface,
                                            aAlpha: 0.78,
                                            bAlpha: 0.58,
                                          ),
                                      child: Center(
                                        child: AspectRatio(
                                          aspectRatio: 1.0,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color:
                                                    cs.surfaceContainerHighest,
                                                border: Border.all(
                                                  color: cs.outlineVariant,
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons
                                                      .self_improvement_rounded,
                                                  size: (width * 0.18).clamp(
                                                    120.0,
                                                    300.0,
                                                  ),
                                                  color: cs.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
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
                                      decoration: BoxDecoration(
                                        color: cs.surfaceContainerHighest
                                            .withValues(alpha: 0.70),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: cs.outlineVariant.withValues(
                                            alpha: 0.75,
                                          ),
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Center(
                                          child: LayoutBuilder(
                                            builder: (c, bc) {
                                              return GestureDetector(
                                                onTap: () => _mainController
                                                    .forward(from: 0),
                                                child: Lottie.network(
                                                  'https://assets7.lottiefiles.com/packages/lf20_jbrw3hcz.json',
                                                  fit: BoxFit.contain,
                                                  width: bc.maxWidth * 0.85,
                                                  height: bc.maxHeight * 0.85,
                                                  repeat: true,
                                                  frameBuilder:
                                                      (
                                                        context,
                                                        child,
                                                        composition,
                                                      ) {
                                                        if (composition ==
                                                            null) {
                                                          return const Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          );
                                                        }
                                                        return child;
                                                      },
                                                ),
                                              );
                                            },
                                          ),
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
                                      Text(
                                        'Digital Mental Wellness Assistant',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: (width * 0.05).clamp(
                                            18.0,
                                            22.0,
                                          ),
                                          fontWeight: FontWeight.bold,
                                          color: cs.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Helping you reflect, recover and grow',
                                        style: TextStyle(
                                          fontSize: (width * 0.03).clamp(
                                            12.0,
                                            14.0,
                                          ),
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SlideTransition(
                                        position: _btn1Offset,
                                        child: FadeTransition(
                                          opacity: _btn1Fade,
                                          child: MouseRegion(
                                            onEnter: (_) => setState(
                                              () => _hovered = _Hovered.btn1,
                                            ),
                                            onExit: (_) => setState(
                                              () => _hovered =
                                                  _hovered == _Hovered.btn1
                                                  ? _Hovered.none
                                                  : _hovered,
                                            ),
                                            child: AnimatedScale(
                                              scale: _hovered == _Hovered.btn1
                                                  ? 1.03
                                                  : 1.0,
                                              duration: const Duration(
                                                milliseconds: 160,
                                              ),
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _handleLogin(context),
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      const Size.fromHeight(48),
                                                  backgroundColor: cs.primary,
                                                  foregroundColor: cs.onPrimary,
                                                ),
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
                                            onEnter: (_) => setState(
                                              () => _hovered = _Hovered.btn2,
                                            ),
                                            onExit: (_) => setState(
                                              () => _hovered =
                                                  _hovered == _Hovered.btn2
                                                  ? _Hovered.none
                                                  : _hovered,
                                            ),
                                            child: MouseRegion(
                                              onEnter: (_) => setState(
                                                () => _hovered = _Hovered.btn2,
                                              ),
                                              onExit: (_) => setState(
                                                () => _hovered =
                                                    _hovered == _Hovered.btn2
                                                    ? _Hovered.none
                                                    : _hovered,
                                              ),
                                              child: AnimatedScale(
                                                scale: _hovered == _Hovered.btn2
                                                    ? 1.03
                                                    : 1.0,
                                                duration: const Duration(
                                                  milliseconds: 160,
                                                ),
                                                child: OutlinedButton(
                                                  onPressed: () =>
                                                      _handleRegister(context),
                                                  style: OutlinedButton.styleFrom(
                                                    minimumSize:
                                                        const Size.fromHeight(
                                                          48,
                                                        ),
                                                    side: BorderSide(
                                                      color: cs.primary,
                                                    ),
                                                    foregroundColor: cs.primary,
                                                  ),
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
                                            onEnter: (_) => setState(
                                              () => _hovered = _Hovered.btn3,
                                            ),
                                            onExit: (_) => setState(
                                              () => _hovered =
                                                  _hovered == _Hovered.btn3
                                                  ? _Hovered.none
                                                  : _hovered,
                                            ),
                                            child: MouseRegion(
                                              onEnter: (_) => setState(
                                                () => _hovered = _Hovered.btn3,
                                              ),
                                              onExit: (_) => setState(
                                                () => _hovered =
                                                    _hovered == _Hovered.btn3
                                                    ? _Hovered.none
                                                    : _hovered,
                                              ),
                                              child: AnimatedScale(
                                                scale: _hovered == _Hovered.btn3
                                                    ? 1.02
                                                    : 1.0,
                                                duration: const Duration(
                                                  milliseconds: 160,
                                                ),
                                                child: TextButton(
                                                  onPressed: () =>
                                                      _handleExplore(context),
                                                  style: TextButton.styleFrom(
                                                    minimumSize:
                                                        const Size.fromHeight(
                                                          48,
                                                        ),
                                                    foregroundColor: cs.primary,
                                                  ),
                                                  child: const Text(
                                                    'Explore Recommendations',
                                                  ),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
