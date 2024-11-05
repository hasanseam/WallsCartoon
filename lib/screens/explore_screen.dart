import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:share_plus/share_plus.dart';
import '../color.dart';
import 'photo_detail_screen.dart';
// Import your AppColors file

/// ExploreScreen is the main screen that displays wallpapers.
class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

/// State class for ExploreScreen which manages the wallpaper fetching and display logic.
class _ExploreScreenState extends State<ExploreScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _wallpapers = [];
  bool _loading = false;
  int _page = 0;
  final int _limit = 5; // Reduced number of wallpapers to fetch per batch.
  bool _loadingMore = false; // Prevent multiple loading triggers.

  // State variable to track selected button
  String _selectedButton = 'New'; // Default selected button

  @override
  void initState() {
    super.initState();
    _fetchInitialWallpapers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchMoreWallpapers();
      }
    });
  }

  /// Fetches the initial set of wallpapers.
  Future<void> _fetchInitialWallpapers() async {
    _page = 0; // Reset to page 0 for initial fetch.
    await _fetchWallpapers(); // Fetch first batch and cache in memory.
  }

  /// Fetches more wallpapers when user scrolls to the bottom.
  Future<void> _fetchMoreWallpapers() async {
    if (_loadingMore) return; // Prevent multiple fetches.
    _loadingMore = true;
    try {
      await _fetchWallpapers(); // Fetch more wallpapers.
    } catch (e) {
      print("Error fetching more wallpapers: $e");
    } finally {
      _loadingMore = false; // Reset loading state.
    }
  }

  /// Fetches wallpapers from Firebase Storage.
  Future<void> _fetchWallpapers() async {
    if (_loading) return; // Prevent multiple fetches.
    setState(() {
      _loading = true;
    });

    try {
      final ListResult result = await _storage.ref('wallpapers/').listAll();

      // Sort the wallpaper items based on their names in descending order.
      List<Reference> sortedItems = result.items.toList()
        ..sort((a, b) => int.parse(b.name.split('.')[0]).compareTo(int.parse(a.name.split('.')[0])));

      List<Future<Map<String, dynamic>>> fetchFutures = [];
      int start = _page * _limit;
      int end = start + _limit;

      // Fetch limited wallpapers.
      for (var i = start; i < end && i < sortedItems.length; i++) {
        fetchFutures.add(_getWallpaperData(sortedItems[i]));
      }

      // Use Future.wait to fetch all wallpapers in parallel.
      List<Map<String, dynamic>> newWallpapers = await Future.wait(fetchFutures);

      // Update wallpapers and increment page.
      setState(() {
        _wallpapers.addAll(newWallpapers);
        _page++; // Increment page after adding.
        _loading = false;
      });
    } catch (e) {
      print("Error fetching wallpapers: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  /// Fetches individual wallpaper data.
  Future<Map<String, dynamic>> _getWallpaperData(Reference ref) async {
    final String url = await ref.getDownloadURL();
    final FullMetadata metadata = await ref.getMetadata();
    return {
      'url': url,
      'updatedTime': metadata.updated,
      'name': ref.name,
    };
  }



  /// Method to refresh wallpapers.
  Future<void> _refreshWallpapers() async {
    setState(() {
      _wallpapers.clear(); // Clear the current list of wallpapers.
      _page = 0; // Reset page number.
    });
    await _fetchWallpapers(); // Fetch wallpapers again.
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = screenWidth > MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Updated to use AppColors
      appBar: AppBar(
        forceMaterialTransparency: true,
        toolbarHeight: isLandscape ? 65 : 80, // Adjust height for alignment
        leadingWidth: 65, // Consistent leading width
        backgroundColor: AppColors.backgroundColor, // Updated to use AppColors
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.refresh, color: AppColors.primaryColor), // Updated icon color
          onPressed: () {
            // Refresh action can be defined here
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share_sharp, color: AppColors.primaryColor), // Share icon with primary color
            onPressed: () {
              Share.share(
                  "Check out this awesome app: https://play.google.com/store/apps/details?id=com.mdidet.wallscartoon");
            },
          ),

        ],
      ),

      body: _loading && _wallpapers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Explore',
                        style: TextStyle(
                          fontSize: isLandscape ? 28 : 41,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryColor, // Text color from AppColors
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Rounded buttons under the Explore header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Adjusts space between buttons
              children: [
                _buildRoundedButton('New', Icons.star_rounded),
                SizedBox(width: MediaQuery.of(context).size.width * 0.01), // Responsive space
                _buildRoundedButton('For You', Icons.face_unlock_rounded),
                SizedBox(width: MediaQuery.of(context).size.width * 0.01), // Responsive space
                _buildRoundedButton('Popular', Icons.local_fire_department_outlined),
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: isLandscape ? 8.0 : 16.0, vertical: 8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth < 600 ? 2 : screenWidth < 900 ? 3 : 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: isLandscape ? 2 / 2.5 : 2 / 3.5,
              ),
              itemCount: _wallpapers.length + (_loadingMore ? 1 : 0), // Add 1 for the loading indicator if loading.
              itemBuilder: (context, index) {
                if (index == _wallpapers.length && _loadingMore) {
                  return Center(child: CircularProgressIndicator());
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoDetailScreen(
                          imageUrl: _wallpapers[index]['url'],
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: CachedNetworkImage(
                      imageUrl: _wallpapers[index]['url'],
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Center(child: Icon(Icons.error)),
                      ),
                      fit: BoxFit.cover,
                      fadeInDuration: Duration(milliseconds: 200),
                      fadeOutDuration: Duration(milliseconds: 200),
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

  Widget _buildRoundedButton(String label, IconData icon) {
    // Determine if this button is selected
    bool isSelected = _selectedButton == label;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0), // Space between buttons
      child: OutlinedButton.icon(
        onPressed: () {
          setState(() {
            _selectedButton = label; // Update the selected button
          });
          // Handle button press
          print('$label button pressed'); // You can replace this with your desired action
        },
        icon: Icon(icon, color: AppColors.primaryColor), // Change icon color to match your theme
        label: Text(
          label,
          style: TextStyle(
            color: AppColors.primaryColor, // Change text color to match your theme
            fontSize: 16.0, // Adjust the font size as needed
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.borderColor), // Set the border color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0), // Vertical padding for height
          backgroundColor: isSelected ? AppColors.selectedButtonColor : Colors.transparent, // Change background color if selected
        ),
      ),
    );
  }
}
