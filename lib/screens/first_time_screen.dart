// first_time_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart'; // Ensure this import points to your HomeScreen

class FirstTimeScreen extends StatefulWidget {  // Renamed class
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
                  'Wallpaper Cartoon',
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
            child: Padding(padding: const EdgeInsets.symmetric(horizontal:80),
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
                           Image.asset(
                             'assets/stars_icon.png', // Set your download icon image here
                             height: 24.0, // Set height of the icon
                             width: 24.0, // Set width of the icon
                           ),
                           SizedBox(width: 16.0), // Space between icon and text
                           Text(
                             'lets go!!',
                             style: TextStyle(
                               color: Color(0xFF971C1C),
                               fontSize: 18,
                             ), // Set text color to #971C1C
                           ),
                         ],
                       ),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Color(0xFFF9CC03), // Set button background color to #F9CC03
                         padding: EdgeInsets.symmetric(vertical: 16.0),
                       ),
                     ),
                   ),
                 ),
            )

          ),
        ],
      ),
    );
  }
}
