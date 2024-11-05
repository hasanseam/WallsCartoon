import 'package:download_wallpaper/screens/photo_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../color.dart';

class LikedScreen extends StatefulWidget {
  @override
  _LikedScreenState createState() => _LikedScreenState();
}

class _LikedScreenState extends State<LikedScreen> {
  List<String> likedWallpapers = [];

  @override
  void initState() {
    super.initState();
    _loadLikedWallpapers();
  }

  // Method to load liked wallpapers from SharedPreferences
  Future<void> _loadLikedWallpapers() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      likedWallpapers = prefs.getStringList('likedWallpapers') ?? [];
    });
  }

  // Method to clear liked wallpapers
  Future<void> _clearLikedWallpapers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('likedWallpapers');
    setState(() {
      likedWallpapers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = screenWidth > MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        toolbarHeight: isLandscape ? 65 : 80,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.refresh, color: AppColors.primaryColor),
          onPressed: _loadLikedWallpapers,
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/mop_icon.png',
              color: AppColors.primaryColor,
              height: 30,
              width: 30,
            ),
            onPressed: () {
              _showCleanModal(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Liked',
                style: TextStyle(
                  fontSize: isLandscape ? 28 : 41,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: likedWallpapers.isEmpty
                ? buildCenteredImageWithText() // Show centered message if empty
                : GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: isLandscape ? 8.0 : 16.0, vertical: 8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth < 600 ? 2 : screenWidth < 900 ? 3 : 4, // Responsive columns
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: isLandscape ? 2 / 2.5 : 2 / 3.5,
              ),
              itemCount: likedWallpapers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoDetailScreen(
                          imageUrl: likedWallpapers[index],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: likedWallpapers[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error, color: AppColors.primaryColor),
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

  // Method to show the modal bottom sheet
  void _showCleanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        final modalHeight = MediaQuery.of(context).size.height * 0.35;
        final buttonWidth = MediaQuery.of(context).size.width * 0.7;

        return Container(
          height: modalHeight,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/clear_icon_modal.png',
                height: 60,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16.0),
              Text(
                'Clear List',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.0),
              Text(
                'You can clear all liked wallpapers in one click. This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () {
                    _clearLikedWallpapers(); // Clear list and update state
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Clear the List',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Fallback UI when there are no liked wallpapers
  Widget buildCenteredImageWithText() {
    return Container(
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/liked_page_backdrop.png',
            fit: BoxFit.cover,
            height: 120.0,
          ),
          SizedBox(height: 10.0),
          Text(
            'No liked wallpapers yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'You don\'t have any liked wallpapers. Go to the explore page to add some.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
