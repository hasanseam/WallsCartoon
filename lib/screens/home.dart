import 'package:flutter/material.dart';
import '../color.dart';
import 'explore_screen.dart';
import 'liked_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      // Set background color from AppColors
      body: _currentIndex == 0 ? ExploreScreen() : LikedScreen(),
      bottomNavigationBar: NavigationBar(
        elevation: 20,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: AppColors.selectedButtonColor(context),
        // Set the background color of selected icon
        destinations: [
          NavigationDestination(
            icon: _currentIndex == 0
                ? Icon(Icons.web_stories_rounded, color: AppColors.primaryColor(
                context)) // Active icon with primary color
                : Icon(Icons.web_stories_outlined,
                color: AppColors.primaryColor(context)),
            // Inactive icon with secondary color
            label: 'Explore',
          ),
          NavigationDestination(
            icon: _currentIndex == 1
                ? Icon(Icons.favorite_rounded, color: AppColors.primaryColor(
                context)) // Active icon with primary color
                : Icon(Icons.favorite_border_rounded,
                color: AppColors.primaryColor(context)),
            // Inactive icon with secondary color
            label: 'Liked',
          ),
        ],
      ),
    );
  }
}
