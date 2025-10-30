import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/wellness_tips_page.dart';

void main() {
  runApp(DigitalHealthApp());
}

class DigitalHealthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Digital Mental Wellness Assistant",
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ResponsiveLayout(
        child: CustomScrollView(
          slivers: [
            // Responsive App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.teal,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Digital Mental Wellness",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: _getResponsiveFontSize(context, 18),
                  ),
                ),
                centerTitle: true,
              ),
            ),
            
            // Main Content
            SliverPadding(
              padding: EdgeInsets.all(_getResponsivePadding(context)),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeroSection(context),
                  SizedBox(height: _getResponsiveSpacing(context, 30)),
                  _buildWelcomeText(context),
                  SizedBox(height: _getResponsiveSpacing(context, 40)),
                  _buildFeaturesGrid(context),
                  SizedBox(height: _getResponsiveSpacing(context, 40)),
                  _buildGetStartedSection(context),
                  SizedBox(height: _getResponsiveSpacing(context, 20)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth > 600;
    
    return Container(
      height: isTabletOrDesktop ? 250 : 180,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isTabletOrDesktop ? 20 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.shade300,
            Colors.teal.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: isTabletOrDesktop ? 60 : 45,
                  color: Colors.white,
                ),
                SizedBox(height: 15),
                Text(
                  "Your Mental Wellness Journey",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getResponsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Starts Here",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: _getResponsiveFontSize(context, 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      children: [
        Text(
          "Take Control of Your Mental Health",
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 0,
          ),
          child: Text(
            "Discover tools and resources designed to support your mental wellness journey. Track your mood, practice mindfulness, and connect with professional support when needed.",
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 16),
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    
    if (screenWidth > 900) {
      crossAxisCount = 4;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    }

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: screenWidth > 600 ? 1.1 : 1.0,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildFeatureCard(
          context,
          Icons.psychology,
          "Mood Tracker",
          "Track daily emotions and patterns",
          Colors.blue,
        ),
        _buildFeatureCard(
          context,
          Icons.self_improvement,
          "Mindfulness",
          "Guided meditation and breathing",
          Colors.purple,
        ),
        _buildFeatureCard(
          context,
          Icons.medical_services,
          "Professional Help",
          "Connect with mental health experts",
          Colors.green,
        ),
        _buildFeatureCard(
          context,
          Icons.favorite,
          "Wellness Tips",
          "Daily mental health insights",
          Colors.orange,
        ),
        if (screenWidth > 600) ...[
          _buildFeatureCard(
            context,
            Icons.group,
            "Community",
            "Connect with supportive peers",
            Colors.pink,
          ),
          _buildFeatureCard(
            context,
            Icons.analytics,
            "Progress",
            "View your wellness journey",
            Colors.indigo,
          ),
        ],
      ],
    );
  }

  Widget _buildGetStartedSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    
    return Container(
      padding: EdgeInsets.all(isWide ? 40 : 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Ready to Begin?",
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 22),
              fontWeight: FontWeight.bold,
              color: Colors.teal[800],
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Start your mental wellness journey today with personalized tools and professional guidance.",
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 16),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 25),
          SizedBox(
            width: isWide ? 250 : double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 3,
              ),
              onPressed: () {
                // Navigate to the wellness tips list page (which calls the backend)
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WellnessTipsPage()),
                );
              },
              child: Text(
                "Get Started",
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Feature Card Widget
  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth > 600;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Opening $title..."),
              backgroundColor: color,
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(isTabletOrDesktop ? 20 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isTabletOrDesktop ? 35 : 30,
                  color: color,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: _getResponsiveFontSize(context, 14),
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              if (isTabletOrDesktop) ...[
                SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 12),
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Responsive Helper Methods
  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return baseFontSize * 1.2;
    } else if (screenWidth > 600) {
      return baseFontSize * 1.1;
    }
    return baseFontSize;
  }

  double _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 40.0;
    } else if (screenWidth > 600) {
      return 30.0;
    }
    return 20.0;
  }

  double _getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return baseSpacing * 1.2;
    }
    return baseSpacing;
  }
}

// Responsive Layout Wrapper
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  
  const ResponsiveLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth > 1200) {
      // Desktop layout
      return Center(
        child: Container(
          width: 1200,
          child: child,
        ),
      );
    } else if (screenWidth > 600) {
      // Tablet layout
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: child,
      );
    } else {
      // Mobile layout
      return child;
    }
  }
}
