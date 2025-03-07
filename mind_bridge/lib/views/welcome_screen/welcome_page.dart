import 'package:flutter/material.dart';
import 'login_page.dart'; // Import your LoginPage
import 'signup_page.dart'; // Import your SignupPage

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF5F5F5), // Light background color
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // App Logo/Icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Color(0xFF5B3618), // Brown background
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.psychology_alt, // Mental health related icon
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Welcome Text
              Text(
                'Welcome to Mind Bridge',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B3618), // Brown color for heading
                ),
                textAlign: TextAlign.center,
              ),

              // Mental Health UI Kit text
              Text(
                'Your Mental Health Companion!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B3618), // Brown color for heading
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12),

              // Description text
              Text(
                '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              // Image from assets folder
              Container(
                width: 350, // Adjust the width as needed
                height: 350, // Adjust the height as needed
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100), // Optional: Add rounded corners
                ),
                child: Image.asset(
                  'assets/imgbg2.png', // Path to your image
                  fit: BoxFit.cover, // Adjust the image fit
                ),
              ),

              SizedBox(height: 50),

              // Get Started Button (Navigates to SignupPage)
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xFF5B3618), // Brown background
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the SignupPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()), // Use SignupPage
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Already have an account? Sign In (Navigates to LoginPage)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the LoginPage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
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
    );
  }
}