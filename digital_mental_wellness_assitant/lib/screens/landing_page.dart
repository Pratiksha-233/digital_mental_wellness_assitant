import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:lottie/lottie.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  final _homeKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _servicesKey = GlobalKey();

  late final AnimationController _floatCtrl;
  late final AnimationController _bgCtrl;
  late final AnimationController _titleCtrl;
  late final Animation<Offset> _floatAnim;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _titleOffset;
  late final Animation<double> _titleFade;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat(reverse: true);
    _floatAnim = Tween<Offset>(begin: const Offset(0, 0.02), end: const Offset(0, -0.02))
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _fadeIn = CurvedAnimation(parent: _floatCtrl, curve: const Interval(0.2, 1.0, curve: Curves.easeIn));

    _titleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _titleOffset = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut));
    _titleFade = CurvedAnimation(parent: _titleCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _floatCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  Widget _navButton(String label, VoidCallback onTap) {
    return TextButton(onPressed: onTap, child: Text(label, style: const TextStyle(color: Colors.white)));
  }

  Widget _ctaButton({required String text, required VoidCallback onPressed, bool primary = true}) {
    final style = primary
        ? ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14))
        : OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0F766E)), foregroundColor: const Color(0xFF0F766E), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14));
    return primary
        ? ElevatedButton(onPressed: onPressed, style: style, child: Text(text))
        : OutlinedButton(onPressed: onPressed, style: style, child: Text(text));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF2FBFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF115E59),
        elevation: 0,
        titleSpacing: 12,
        title: Row(children: [
          const Text('ManMitra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (isWide) ...[
            _navButton('Home', () => _scrollTo(_homeKey)),
            _navButton('About', () => _scrollTo(_aboutKey)),
            _navButton('Features', () => _scrollTo(_servicesKey)),
            _navButton('Contact', () {}),
          ],
        ]),
        actions: [
          if (!isWide)
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.menu),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (c) {
                    return SafeArea(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        ListTile(title: const Text('Home'), onTap: () { Navigator.pop(c); _scrollTo(_homeKey); }),
                        ListTile(title: const Text('About'), onTap: () { Navigator.pop(c); _scrollTo(_aboutKey); }),
                        ListTile(title: const Text('Features'), onTap: () { Navigator.pop(c); _scrollTo(_servicesKey); }),
                        const SizedBox(height: 8),
                      ]),
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Soft animated gradient background spanning the whole page
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (context, _) {
              final t = _bgCtrl.value;
              final c1a = const Color(0xFFCCFBF1); // teal-50
              final c1b = const Color(0xFFE0E7FF); // indigo-100
              final c2a = const Color(0xFFEFF6FF); // blue-50
              final c2b = const Color(0xFFFFF7ED); // orange-50
              final g1 = Color.lerp(c1a, c1b, t)!;
              final g2 = Color.lerp(c2a, c2b, 1 - t)!;
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
          // Floating background particles (interactive feel)
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (context, _) {
              return IgnorePointer(
                child: CustomPaint(
                  painter: _BubblesPainter(t: _bgCtrl.value),
                  size: Size.infinite,
                ),
              );
            },
          ),
          SingleChildScrollView(
            child: Column(
          children: [
            // Hero Section
            Container(
              key: _homeKey,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              color: const Color(0xFFF2FBFA),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isWide
                      ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          // Text side
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const SizedBox(height: 16),
                              SlideTransition(
                                position: _titleOffset,
                                child: FadeTransition(
                                  opacity: _titleFade,
                                  child: const Text(
                                    'Your Digital\nMental Wellness\nCompanion',
                                    style: TextStyle(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              FadeTransition(
                                opacity: _titleFade,
                                child: const Text(
                                  'Empowering you to manage mental health with ease',
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ),
                              const SizedBox(height: 22),
                              Wrap(spacing: 12, runSpacing: 12, children: [
                                _ctaButton(text: 'Login', onPressed: () => Navigator.pushNamed(context, '/login'), primary: true),
                                _ctaButton(text: 'Register', onPressed: () => Navigator.pushNamed(context, '/register'), primary: false),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/mood'),
                                  child: const Text('How are you feeling today?'),
                                ),
                              ]),
                            ]),
                          ),
                          const SizedBox(width: 28),
                          // Illustration
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Stack(
                                children: [
                                  // soft animated background bubbles
                                  AnimatedBuilder(
                                    animation: _bgCtrl,
                                    builder: (context, _) {
                                      final t = _bgCtrl.value;
                                      return Stack(children: [
                                        Positioned(
                                          left: 10 + 20 * (1 - t),
                                          top: 8 + 30 * t,
                                          child: _bubble(140, 0.07),
                                        ),
                                        Positioned(
                                          right: 0 + 18 * t,
                                          bottom: 16 + 24 * (1 - t),
                                          child: _bubble(200, 0.06),
                                        ),
                                      ]);
                                    },
                                  ),
                                  Center(
                                    child: SlideTransition(
                                      position: _floatAnim,
                                      child: Container(
                                        decoration: BoxDecoration(color: const Color(0xFFE6FFFB), borderRadius: BorderRadius.circular(20), boxShadow: [
                                          BoxShadow(color: const Color(0xFF99F6E4).withValues(alpha: 0.6), blurRadius: 16, offset: const Offset(0, 8)),
                                        ]),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: FadeTransition(
                                            opacity: _fadeIn,
                                            child: Lottie.network(
                                              // new illustration (calm mind/meditation)
                                              'https://assets10.lottiefiles.com/packages/lf20_49rdyysj.json',
                                              fit: BoxFit.contain,
                                              repeat: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ])
                      : Column(children: [
                          const SizedBox(height: 12),
                          SlideTransition(
                            position: _titleOffset,
                            child: FadeTransition(
                              opacity: _titleFade,
                              child: const Text('Your Digital\nMental Wellness\nCompanion',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.2, color: Color(0xFF0F766E))),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeTransition(
                            opacity: _titleFade,
                            child: const Text('Empowering you to manage mental health with ease',
                                textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black87)),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 240,
                            child: Stack(children: [
                              AnimatedBuilder(
                                animation: _bgCtrl,
                                builder: (context, _) {
                                  final t = _bgCtrl.value;
                                  return Stack(children: [
                                    Positioned(left: 8 + 20 * (1 - t), top: 0 + 18 * t, child: _bubble(110, 0.08)),
                                    Positioned(right: 10 + 12 * t, bottom: 6 + 20 * (1 - t), child: _bubble(150, 0.06)),
                                  ]);
                                },
                              ),
                              Center(
                                child: SlideTransition(
                                  position: _floatAnim,
                                  child: Container(
                                    height: 220,
                                    decoration: BoxDecoration(color: const Color(0xFFE6FFFB), borderRadius: BorderRadius.circular(20), boxShadow: [
                                      BoxShadow(color: const Color(0xFF99F6E4).withValues(alpha: 0.6), blurRadius: 16, offset: const Offset(0, 8)),
                                    ]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FadeTransition(
                                        opacity: _fadeIn,
                                        child: Lottie.network('https://assets10.lottiefiles.com/packages/lf20_49rdyysj.json', fit: BoxFit.contain, repeat: true),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 18),
                          Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 12, children: [
                            _ctaButton(text: 'Login', onPressed: () => Navigator.pushNamed(context, '/login'), primary: true),
                            _ctaButton(text: 'Register', onPressed: () => Navigator.pushNamed(context, '/register'), primary: false),
                            TextButton(onPressed: () => Navigator.pushNamed(context, '/mood'), child: const Text('How are you feeling today?')),
                          ]),
                          const SizedBox(height: 8),
                        ]),
                ),
              ),
            ),

            // About section (interactive)
            Container(
              key: _aboutKey,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('About', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F766E))),
                    const SizedBox(height: 8),
                    const Text('A gentle companion that blends mindfulness with modern tech.', style: TextStyle(fontSize: 16, color: Colors.black87)),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        AboutCard(
                          icon: Icons.favorite_outline,
                          title: 'Your Companion',
                          preview: 'Daily check‑ins and reflective prompts.',
                          details: 'Build a healthy habit with short, uplifting check‑ins designed to reduce stress and increase self‑awareness.',
                        ),
                        AboutCard(
                          icon: Icons.lock_outline,
                          title: 'Private & Secure',
                          preview: 'Your data stays yours.',
                          details: 'We store as little as possible and give you control. You can export or delete your data anytime.',
                        ),
                        AboutCard(
                          icon: Icons.science_outlined,
                          title: 'Science‑backed',
                          preview: 'CBT and mindfulness tools.',
                          details: 'Grounded in CBT and mindfulness techniques to nudge helpful thinking patterns and routines.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // small animated counters
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        AnimatedMetric(label: 'Daily check‑ins', target: 1200),
                        AnimatedMetric(label: 'Guided prompts', target: 48),
                        AnimatedMetric(label: 'Mood types', target: 5),
                      ],
                    ),
                  ]),
                ),
              ),
            ),

            // Services section
            Container(
              key: _servicesKey,
              color: const Color(0xFFF2FBFA),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Our Services', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
                    const SizedBox(height: 16),
                    Wrap(spacing: 16, runSpacing: 16, children: [
                      ServiceCard(icon: Icons.chat_bubble, title: 'Therapy', subtitle: 'Chatbot', onTap: () => Navigator.pushNamed(context, '/chat')),
                      ServiceCard(icon: Icons.monitor_heart, title: 'Stress', subtitle: 'Analyzer', onTap: () => Navigator.pushNamed(context, '/recommendations')),
                      ServiceCard(icon: Icons.emoji_emotions, title: 'Mood', subtitle: 'Tracker', onTap: () => Navigator.pushNamed(context, '/mood')),
                      ServiceCard(icon: Icons.spa_rounded, title: 'Self-care', subtitle: 'Tips', onTap: () => Navigator.pushNamed(context, '/selfcare')),
                    ]),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _ctaButton(text: 'Contact Us', onPressed: () {}),
                    ),
                  ]),
                ),
              ),
            ),

            // Chatbot section removed from front page; available at /chat

            // Removed inline Self‑care Tips section; now a dedicated screen at /selfcare

            // Footer
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(width: 8), Icon(Icons.facebook, color: Color(0xFF0F766E)), SizedBox(width: 14), Icon(Icons.call, color: Color(0xFF0F766E)), SizedBox(width: 14), Icon(Icons.link, color: Color(0xFF0F766E)),
              ]),
            )
          ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const ServiceCard({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 160),
        child: SizedBox(
          width: 250,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            elevation: _hover ? 8 : 2,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(color: const Color(0xFFE6FFFB), borderRadius: BorderRadius.circular(16), boxShadow: _hover ? [
                        BoxShadow(color: const Color(0xFF99F6E4).withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 6))
                      ] : null),
                      child: Icon(widget.icon, color: const Color(0xFF0F766E), size: 34),
                    ),
                    const SizedBox(height: 12),
                    Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(widget.subtitle, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helpers
Widget _bubble(double size, double opacity) {
  return Opacity(
    opacity: opacity,
    child: Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    ),
  );
}

// Painter for animated background bubbles
class _BubblesPainter extends CustomPainter {
  final double t;
  _BubblesPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    // define a few bubbles with deterministic positions
    final bubbles = [
      _BubbleSpec(0.15, Colors.white.withValues(alpha: 0.10), Offset(size.width * 0.2 + 40 * math.sin(t * math.pi * 2), size.height * 0.25)),
      _BubbleSpec(0.10, Colors.white.withValues(alpha: 0.08), Offset(size.width * 0.75 + 60 * math.cos(t * math.pi), size.height * 0.18 + 30 * math.sin(t * math.pi))),
      _BubbleSpec(0.20, Colors.white.withValues(alpha: 0.06), Offset(size.width * 0.6 + 50 * math.sin(t * math.pi * 1.5), size.height * 0.7)),
    ];
    for (final b in bubbles) {
      paint.color = b.color;
      canvas.drawCircle(b.center, size.shortestSide * b.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblesPainter oldDelegate) => oldDelegate.t != t;
}

class _BubbleSpec {
  final double radius; // relative radius
  final Color color;
  final Offset center;
  _BubbleSpec(this.radius, this.color, this.center);
}

// Interactive About card
class AboutCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String preview;
  final String details;
  const AboutCard({super.key, required this.icon, required this.title, required this.preview, required this.details});

  @override
  State<AboutCard> createState() => _AboutCardState();
}

class _AboutCardState extends State<AboutCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withValues(alpha: 0.08),
            blurRadius: _expanded ? 18 : 8,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: _expanded ? const Color(0xFF0F766E) : Colors.transparent, width: 1.2),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FFFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: const Color(0xFF0F766E), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              ),
            ]),
            const SizedBox(height: 12),
            AnimatedCrossFade(
              firstChild: Text(widget.preview, style: const TextStyle(color: Colors.black87)),
              secondChild: Text(widget.details, style: const TextStyle(color: Colors.black87)),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 350),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(_expanded ? 'Tap to collapse' : 'Tap to expand', style: const TextStyle(fontSize: 12, color: Colors.black45)),
            )
          ],
        ),
      ),
    );
  }
}

// Animated metric counter widget
class AnimatedMetric extends StatefulWidget {
  final String label;
  final int target;
  const AnimatedMetric({super.key, required this.label, required this.target});

  @override
  State<AnimatedMetric> createState() => _AnimatedMetricState();
}

class _AnimatedMetricState extends State<AnimatedMetric> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final value = (widget.target * _anim.value).round();
              return Text('$value', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)));
            },
          ),
          const SizedBox(height: 4),
            Text(widget.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}

// Minimal embedded chatbot for landing page
class ChatbotEmbed extends StatefulWidget {
  const ChatbotEmbed({super.key});

  @override
  State<ChatbotEmbed> createState() => _ChatbotEmbedState();
}

class _ChatbotEmbedState extends State<ChatbotEmbed> {
  final List<_Msg> _messages = [
    const _Msg(text: 'Hi! I\'m here to listen. How are you feeling today?', isUser: false),
  ];
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add(_Msg(text: text, isUser: true));
      _controller.clear();
      _sending = true;
    });

    // Simple local response for demo; can be replaced with backend call
    await Future.delayed(const Duration(milliseconds: 600));
    final reply = _makeLocalReply(text);
    setState(() {
      _messages.add(_Msg(text: reply, isUser: false));
      _sending = false;
    });
  }

  String _makeLocalReply(String user) {
    final u = user.toLowerCase();
    if (u.contains('stress') || u.contains('anx')) {
      return 'Thanks for sharing. Try box breathing: inhale 4s, hold 4s, exhale 4s, hold 4s — 4 rounds. Want another tip?';
    }
    if (u.contains('sleep') || u.contains('tired')) {
      return 'Sleep can be tough. Try dimming lights and no screens 30 mins before bed. Would you like a wind‑down routine?';
    }
    if (u.contains('sad') || u.contains('down')) {
      return 'I\'m with you. It may help to write one thing that went okay today, however small. I can share a journaling prompt.';
    }
    return 'I hear you. Can you tell me a bit more about what\'s on your mind? I can also suggest quick self‑care tips.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Therapy Chatbot', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
        const SizedBox(height: 12),
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
            child: Column(children: [
              // messages area
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(colors: [Colors.teal.shade50, Colors.white]),
                ),
                child: ListView.builder(
                  itemCount: _messages.length,
                  reverse: false,
                  itemBuilder: (context, i) {
                    final m = _messages[i];
                    return Align(
                      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        constraints: const BoxConstraints(maxWidth: 700),
                        decoration: BoxDecoration(
                          color: m.isUser ? const Color(0xFF0F766E) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black12.withValues(alpha: 0.07), blurRadius: 6, offset: const Offset(0, 3))],
                          border: m.isUser ? null : Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(m.text, style: TextStyle(color: m.isUser ? Colors.white : Colors.black87)),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(hintText: 'Type a message…', border: OutlineInputBorder(borderSide: BorderSide.none)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send),
                    label: Text(_sending ? 'Sending…' : 'Send'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white),
                  )
                ]),
              )
            ]),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/chat'),
          icon: const Icon(Icons.open_in_new),
          label: const Text('Open full chat'),
        ),
      ],
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  const _Msg({required this.text, required this.isUser});
}

// (Self‑care tips moved to dedicated SelfCareTipsScreen)
