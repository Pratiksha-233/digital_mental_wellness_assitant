import 'package:flutter/material.dart';
import 'dart:math' as math;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageStateFixed();
}

class _LandingPageStateFixed extends State<LandingPage> with TickerProviderStateMixin {
  final _homeKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _contactKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _bgController;
  late final AnimationController _floatCtrl;
  late final Animation<Offset> _floatAnim;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
			duration: const Duration(seconds: 20),
			vsync: this,
		)..repeat(reverse: true);
    
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat(reverse: true);
    _floatAnim = Tween<Offset>(begin: const Offset(0, 0.02), end: const Offset(0, -0.02))
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _fadeIn = CurvedAnimation(parent: _floatCtrl, curve: const Interval(0.2, 1.0, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _bgController.dispose();
    _floatCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 800),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildNavBar(context, isDesktop),
      drawer: !isDesktop ? _buildDrawer(context) : null,
      extendBodyBehindAppBar: true, 
      body: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return CustomPaint(
                  painter: AtomicBackgroundPainter(_bgController.value),
                );
              },
            ),
          ),
          
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(height: isDesktop ? 80 : 60), // Spacing for extendBodyBehindAppBar
                _buildHeroSection(context, isDesktop),
                _buildFeaturesSection(context, isDesktop),
                _buildAboutSection(context, isDesktop),
                _buildTestimonialsSection(context, isDesktop),
                _buildContactSection(context, isDesktop),
                _buildFooter(context, isDesktop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildNavBar(BuildContext context, bool isDesktop) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.9), // Glassmorphism effect
      elevation: 0,
      scrolledUnderElevation: 4,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 80,
      title: Row(
        children: [
          const SizedBox(width: 8),
          Hero(
            tag: 'logo',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.spa_rounded, color: Color(0xFF009688), size: 28),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'MindWell',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w800,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
          if (isDesktop) ...[
            const Spacer(),
            _navButton('Home', () => _scrollTo(_homeKey)),
            _navButton('Features', () => _scrollTo(_featuresKey)),
            _navButton('About', () => _scrollTo(_aboutKey)),
            _navButton('Contact', () => _scrollTo(_contactKey)),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009688),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('Login', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF009688),
                side: const BorderSide(color: Color(0xFF009688), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 20),
          ],
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF009688), Color(0xFF4DB6AC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.spa_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'MindWell',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Home'), onTap: () { Navigator.pop(context); _scrollTo(_homeKey); }),
          ListTile(leading: const Icon(Icons.grid_view_outlined), title: const Text('Features'), onTap: () { Navigator.pop(context); _scrollTo(_featuresKey); }),
          ListTile(leading: const Icon(Icons.info_outline), title: const Text('About'), onTap: () { Navigator.pop(context); _scrollTo(_aboutKey); }),
          ListTile(leading: const Icon(Icons.contact_mail_outlined), title: const Text('Contact'), onTap: () { Navigator.pop(context); _scrollTo(_contactKey); }),
          const Divider(),
          ListTile(leading: const Icon(Icons.login), title: const Text('Login'), onTap: () => Navigator.pushNamed(context, '/login')),
          ListTile(leading: const Icon(Icons.person_add_outlined), title: const Text('Sign Up'), onTap: () => Navigator.pushNamed(context, '/register')),
        ],
      ),
    );
  }

  Widget _navButton(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF374151),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        child: Text(text),
      ),
    );
  }

  // --- Sections ---

  Widget _buildTrustAvatar(String url) {
    return Align(
      widthFactor: 0.8,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(url),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Container(
      key: _homeKey,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: isDesktop ? 100 : 40,
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 60,
            runSpacing: 60,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFB2DFDB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star_rounded, color: Color(0xFF009688), size: 18),
                          SizedBox(width: 8),
                          Text(
                            '#1 Mental Wellness Companion',
                            style: TextStyle(
                              color: Color(0xFF00796B),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Find Peace & Balance\nin Your Daily Life',
                      textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 64 : 42,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        color: const Color(0xFF111827),
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your personal assistant for mood tracking, meditation, and mental wellness resources. Powered by AI to help you feel your best.',
                      textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF4B5563),
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Buttons removed
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              // Hero Image at Right Side
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1493836512294-502baa1986e2?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                      fit: BoxFit.cover,
                      semanticLabel: 'Mental Wellness & Technology',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDemoVideo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 800,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1544367563-12123d8959bd?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withValues(alpha: 0.4),
                      colorBlendMode: BlendMode.darken,
                    ),
                   ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 60),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "MindWell Demo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDesktop) {
    return Container(
      key: _featuresKey,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 100),
      child: Column(
        children: [
          const Text(
            'Features',
            style: TextStyle(
              color: Color(0xFF009688),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 14
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Discover Our Tools',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 80),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard(
                icon: Icons.mood_rounded,
                title: 'Mood Tracking',
                description: 'Log your daily emotions and get personalized insights to improve your mental health.',
                color: const Color(0xFFE0F2F1),
                iconColor: const Color(0xFF009688),
              ),
              _buildFeatureCard(
                icon: Icons.self_improvement,
                title: 'Meditation',
                description: 'Guided sessions tailored to your needs, from quick stress relief to deep sleep.',
                color: const Color(0xFFF1F8E9),
                iconColor: const Color(0xFF7CB342),
              ),
              _buildFeatureCard(
                icon: Icons.library_books_outlined,
                title: 'Resources',
                description: 'Curated articles and tips for better sleep, anxiety relief, and self-care.',
                color: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF8E24AA),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
  }) {
    return HoverableCard(
      child: Container(
        width: 280,
        height: 320,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6B7280),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, bool isDesktop) {
    return Stack(
      key: _aboutKey,
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return CustomPaint(
                painter: AtomicBackgroundPainter(_bgController.value, backgroundColor: const Color(0xFFFAFAFA)),
              );
            },
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 100),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                children: [
                  Expanded(
                    flex: isDesktop ? 1 : 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text('Our Mission', style: TextStyle(color: Color(0xFFEF6C00), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'About MindWell',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'MindWell was born from a simple mission: to make mental wellness accessible to everyone. We believe that taking care of your mind should be as routine as brushing your teeth.',
                          style: TextStyle(fontSize: 18, color: Color(0xFF4B5563), height: 1.7),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Our team of psychologists and developers work together to bring you scientifically-backed tools in a friendly, easy-to-use package.',
                          style: TextStyle(fontSize: 18, color: Color(0xFF4B5563), height: 1.7),
                        ),
                        const SizedBox(height: 32),
                        TextButton.icon(
                          onPressed: () {}, 
                          icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF009688)), 
                          label: const Text('Learn more about us', style: TextStyle(color: Color(0xFF009688), fontSize: 16, fontWeight: FontWeight.bold))
                        )
                      ],
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 80),
                    Expanded(
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, left: 20),
                             child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Container(color: const Color(0xFFB2DFDB), height: 400),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
                              height: 400,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialsSection(BuildContext context, bool isDesktop) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) => CustomPaint(
              painter: AtomicBackgroundPainter(_bgController.value, backgroundColor: const Color(0xFFF0FDFA)),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 100),
          child: Column(
            children: [
              const Text(
                'Loved by Thousands',
                style: TextStyle(
                  color: Color(0xFF009688),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 14
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'What Our Users Say',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 80),
              Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  _buildTestimonialCard(
                    text: "MindWell has completely transformed how I manage my daily stress. The AI companion is surprisingly empathetic!",
                    author: "Sarah Jenkins",
                    role: "Product Designer",
                    stars: 5,
                    avatarColor: const Color(0xFFFFE0B2),
                    avatarText: "S",
                  ),
                  _buildTestimonialCard(
                    text: "The meditation library is extensive and high quality. I use it every night before sleep.",
                    author: "Michael Chen",
                    role: "Developer",
                    stars: 5,
                    avatarColor: const Color(0xFFBBDEFB),
                    avatarText: "M",
                  ),
                  _buildTestimonialCard(
                    text: "I love the mood tracking features. Seeing my patterns helped me understand my triggers better.",
                    author: "Emma Wilson",
                    role: "Student",
                    stars: 5,
                    avatarColor: const Color(0xFFF3E5F5),
                    avatarText: "E",
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialCard({
    required String text,
    required String author,
    required String role,
    required int stars,
    required Color avatarColor,
    required String avatarText,
  }) {
    return HoverableCard(
      child: Container(
        width: 350,
        height: 380,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF009688).withValues(alpha: 0.05),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.format_quote_rounded, size: 48, color: Color(0xFFE0F2F1)),
            const SizedBox(height: 24),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF374151),
                height: 1.6,
                fontWeight: FontWeight.w500
              ),
            ),
            const Spacer(),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: avatarColor,
                  radius: 24,
                  child: Text(
                    avatarText,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                        fontSize: 16
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 20,
                      color: const Color(0xFFFFB300),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, bool isDesktop) {
    return Container(
      key: _contactKey,
      width: double.infinity,
      // No background color specified, so it remains transparent allowing the global animation to show through.
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 100),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            'Get in Touch',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "We'd love to hear from you. Our team is always here to chat.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _buildContactCard(
                icon: Icons.email_outlined,
                title: 'Email',
                content: 'support@mindwell.com',
                subContent: 'We reply within 24 hours',
                color: const Color(0xFFE0F2F1),
                accent: const Color(0xFF009688),
              ),
              _buildContactCard(
                icon: Icons.phone_outlined,
                title: 'Phone',
                content: '+1 (555) 123-4567',
                subContent: 'Mon-Fri from 8am to 5pm',
                color: const Color(0xFFE3F2FD),
                accent: const Color(0xFF1976D2),
              ),
              _buildContactCard(
                icon: Icons.location_on_outlined,
                title: 'Office',
                content: '123 Wellness Street',
                subContent: 'San Francisco, CA 94105',
                color: const Color(0xFFF3E5F5),
                accent: const Color(0xFF7B1FA2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required String subContent,
    required Color color,
    required Color accent,
  }) {
    return HoverableCard(
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subContent,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF111827), // Darker footer
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 80),
      child: Column(
        children: [
          Wrap(
            spacing: 80,
            runSpacing: 40,
            alignment: isDesktop ? WrapAlignment.spaceBetween : WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              SizedBox(
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.spa_rounded, color: Color(0xFF2DD4BF), size: 32),
                        SizedBox(width: 12),
                        Text(
                          'MindWell',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Empowering you to take control of your mental wellness with AI-driven insights and professional support.',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        height: 1.6,
                        fontSize: 16
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: _socialIconButtons(),
                    ),
                  ],
                ),
              ),
              _buildFooterColumn('Product', ['Features', 'Pricing', 'Testimonials', 'FAQ']),
              _buildFooterColumn('Company', ['About Us', 'Careers', 'Blog', 'Contact']),
              _buildFooterColumn('Legal', ['Privacy Policy', 'Terms of Service', 'Cookie Policy', 'Security']),
            ],
          ),
          const SizedBox(height: 80),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 30),
          Flex(
            direction: isDesktop ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '© 2025 MindWell. All rights reserved.',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
              SizedBox(height: 10),
              Text(
                'Made with ❤️ for mental health',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<String> links) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          ...links.map((link) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  link,
                  style: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  List<Widget> _socialIconButtons() {
    return [
      Icons.facebook,
      Icons.code,
      Icons.email,
    ].map((icon) => Padding(
      padding: const EdgeInsets.only(right: 16),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white, size: 22),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          padding: const EdgeInsets.all(12),
        ),
      ),
    )).toList();
  }
}

// --- Animation & UX Widgets ---

class HoverableCard extends StatefulWidget {
  final Widget child;
  const HoverableCard({super.key, required this.child});
  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovering ? -10.0 : 0.0),
        child: widget.child,
      ),
    );
  }
}

// Custom Painter for subtle animated background
class AtomicBackgroundPainter extends CustomPainter {
  final double value;
  final Color? backgroundColor;
  
  AtomicBackgroundPainter(this.value, {this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Background
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    if (backgroundColor != null) {
      canvas.drawRect(rect, Paint()..color = backgroundColor!);
    } else {
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFF9FAFB),
          const Color(0xFFF0FDFA).withValues(alpha: 0.5),
          const Color(0xFFF9FAFB),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    }

    // Animated Orbs
    // Orb 1
    paint.color = const Color(0xFFB2DFDB).withValues(alpha: 0.15);
    canvas.drawCircle(
      Offset(
        size.width * 0.8 + 50 * math.cos(value * 2 * math.pi), 
        size.height * 0.2 + 30 * math.sin(value * 2 * math.pi)
      ),
      200, 
      paint
    );
    
    // Orb 2
    paint.color = const Color(0xFFE1BEE7).withValues(alpha: 0.1);
    canvas.drawCircle(
      Offset(
        size.width * 0.2 + 60 * math.sin(value * 2 * math.pi), 
        size.height * 0.6 + 40 * math.cos(value * 2 * math.pi)
      ),
      250, 
      paint
    );
  }

  @override
  bool shouldRepaint(covariant AtomicBackgroundPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
