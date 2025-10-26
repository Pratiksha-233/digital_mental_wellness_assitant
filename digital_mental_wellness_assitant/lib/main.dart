import 'package:flutter/material.dart';

void main() {
  runApp(DigitalHealthApp());
}

class DigitalHealthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Digital Health & Wellness",
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Digital Health & Wellness"),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Banner Image / Illustration
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://img.freepik.com/free-vector/healthcare-concept-illustration_114360-1679.jpg",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 25),

              // Welcome Text
              Text(
                "Welcome to Digital Health & Wellness",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Your personal companion for fitness, mental health, and medical tracking.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Feature Buttons (Cards)
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildFeatureCard(Icons.favorite, "Health Tips"),
                  _buildFeatureCard(Icons.directions_run, "Fitness Tracker"),
                  _buildFeatureCard(Icons.medical_services, "Doctor Connect"),
                  _buildFeatureCard(Icons.self_improvement, "Mental Wellness"),
                ],
              ),
              SizedBox(height: 30),

              // Get Started Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // TODO: Navigate to next page
                },
                child: Text(
                  "Get Started",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Card Widget
  Widget _buildFeatureCard(IconData icon, String title) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // TODO: Add navigation
        },
        borderRadius: BorderRadius.circular(15),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.teal),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
