// first_time_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../color.dart';
import 'home.dart'; // Ensure this import points to your HomeScreen

class FirstTimeScreen extends StatefulWidget {
  // Renamed class
  @override
  _FirstTimeScreenState createState() => _FirstTimeScreenState();
}

class _FirstTimeScreenState extends State<FirstTimeScreen> {
  @override
  void initState() {
    _setFirstTimeFlag();
    super.initState();
    // Navigate to home screen after a delay
  }

  Future<void> _setFirstTimeFlag() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: Stack(
        children: [
          // Centered Content: App Icon, App Name, Short Description
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Centers the items vertically
              children: [
                // App Icon
                Image.asset(
                  'assets/liked_page_backdrop.png', // Path to your app icon
                  width: 210, // Adjust size as needed
                  height: 282,
                ),
                SizedBox(height: 0),

                // App Name
                Text(
                  'Wallpaper Cartoon',
                  style: TextStyle(
                    fontSize: 36,
                    color: AppColors.primaryColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),

                // Short Description
                Text(
                  'Browse and download amazing\nunique wallpapers',
                  style: TextStyle(
                    fontSize: 19,
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
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: () => {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ))
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 0.0), // Space between icon and text
                          Text(
                            'lets go!!',
                            style: TextStyle(
                              color: AppColors.buttonTextColor(context),
                              fontSize: 18,
                            ), // Set text color to #971C1C
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor(context), // Set button background color to #F9CC03
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
