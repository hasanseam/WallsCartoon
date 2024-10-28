// splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'home.dart'; // Ensure this import points to your HomeScreen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to home screen after a delay
    Timer(Duration(seconds: 3), () {  // Adjusted delay to 3 seconds for typical splash timing
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBF3EF), // Background color of the splash screen
      body: Stack(
        children: [
          // Centered Content: App Icon, App Name, Short Description
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Centers the items vertically
              children: [
                // App Icon
                Image.asset(
                  'assets/app_icon.png', // Path to your app icon
                  width: 162, // Adjust size as needed
                  height: 182,
                ),
                SizedBox(height: 0),

                // App Name
                Text(
                  'Wallscartoon',
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),

                // Short Description
                Text(
                  'Browse and download amazing unique wallpapers',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Positioned Bottom Image ("Let's Go" Button)
          Positioned(
            bottom: 50, // Adjust this to move the button up or down
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding for alignment
              child: Image.asset(
                'assets/lets_go_button.png', // Path to your bottom image
                width: 188, // Adjust size as needed
                height: 56,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
