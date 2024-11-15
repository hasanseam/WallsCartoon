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

  // Callback function to update the liked wallpapers list
  void _updateLikedWallpapers() {
    setState(() {
      _loadLikedWallpapers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = screenWidth > MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.backgroundColor(context),
        toolbarHeight: isLandscape ? 65 : 80,
        leadingWidth: 45, // Consistent leading width
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.refresh, color: AppColors.primaryColor(context), size: 28,),
          onPressed: _loadLikedWallpapers,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.cleaning_services_outlined, color: AppColors.primaryColor(context), size: 28,),
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
                  fontSize: isLandscape ? 28 : 35,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor(context),
                ),
              ),
            ),
          ),
          Expanded(
            child: likedWallpapers.isEmpty
                ? buildCenteredImageWithText() // Show centered message if empty
                : GridView.builder(
              padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? 8.0 : 16.0, vertical: 8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth < 600
                    ? 2
                    : screenWidth < 900
                    ? 3
                    : 4, // Responsive columns
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
                          onLiked: _updateLikedWallpapers, // Pass the callback here
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: CachedNetworkImage(
                        imageUrl: likedWallpapers[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error, color: AppColors.primaryColor(context)),
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

  void _showCleanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Transparent to enable full-width effect
      builder: (BuildContext context) {
        final modalHeight = MediaQuery.of(context).size.height * 0.35;
        final buttonWidth = MediaQuery.of(context).size.width * 0.7;

        return FractionallySizedBox(
          widthFactor: 1.0, // Ensures full-width modal
          child: Container(
            height: modalHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16.0),
                Icon(
                  Icons.cleaning_services_outlined,
                  color: AppColors.cleaningIconColor(context),
                  size: 60.0,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Clear List',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.0),
                Text(
                  'You can clear all liked wallpapers in one click. \n This action cannot be undo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.descriptionColor(context),
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
                      style: TextStyle(color: AppColors.cleanListButtonTextColor(context), fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cleaningIconColor(context),
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                  ),
                ),
              ],
            ),
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
            height: 230.0,
          ),
          SizedBox(height: 30.0),
          Text(
            'No liked wallpapers yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor(context),
            ),
          ),
          SizedBox(height: 2.0),
          Text(
            'You don\'t have any liked wallpapers. Go to \n explore page to add some.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
