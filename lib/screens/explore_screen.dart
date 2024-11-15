import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import '../color.dart';
import 'photo_detail_screen.dart';

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
  //late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  int _page = 0;
  final int _limit = 5; // Reduced number of wallpapers to fetch per batch.
  bool _loadingMore = false; // Prevent multiple loading triggers.
  String _selectedButton = 'New'; // Default selected button

  int _wallpaperViewLimit = 20;
  int _wallpapersViewed = 0;
  //late RewardedAd _rewardedAd;
  bool _isRewardedAdReady = false;


  @override
  void initState() {
    super.initState();
   // _loadBannerAd();
    //_loadRewardedAd(); // load reward ad
    _fetchInitialWallpapers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if(_wallpapersViewed>=_wallpaperViewLimit){
          //show button for rewarded ad after reaching view limit
          setState(() {});// update the state to show button
        }else{
          _fetchMoreWallpapers();
        }

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

  /// Fetches wallpapers from Firebase Storage based on the selected category.
  Future<void> _fetchWallpapers() async {
    if (_loading) return; // Prevent multiple fetches.
    setState(() {
      _loading = true;
    });

    try {
      String folderPath;

      // Select folder based on the selected button.
      switch (_selectedButton) {
        case 'New':
          folderPath = 'wallpapers/';
          break;
        case 'Popular':
          folderPath = 'Popular/';
          break;
        default:
          folderPath = 'wallpapers/'; // Default folder (you can change this)
      }

      final ListResult result = await _storage.ref(folderPath).listAll();

      // Sort the wallpaper items based on their names in descending order.
      List<Reference> sortedItems = result.items.toList()
        ..sort((a, b) =>
            int.parse(b.name.split('.')[0]).compareTo(
                int.parse(a.name.split('.')[0])));

      List<Future<Map<String, dynamic>>> fetchFutures = [];
      int start = _page * _limit;
      int end = start + _limit;

      // Fetch limited wallpapers.
      for (var i = start; i < end && i < sortedItems.length; i++) {
        fetchFutures.add(_getWallpaperData(sortedItems[i]));
      }

      // Use Future.wait to fetch all wallpapers in parallel.
      List<Map<String, dynamic>> newWallpapers = await Future.wait(
          fetchFutures);

      // Update wallpapers and increment page.
      setState(() {
        _wallpapers.addAll(newWallpapers);
        _wallpapersViewed+=newWallpapers.length; // Increment viewwed count
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

  /// Loads a banner ad.
  /*void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6988636964260545/1401033031',
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Failed to load a banner ad: ${error.message}');
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }*/

  /// Method to refresh wallpapers.
  Future<void> _refreshWallpapers() async {
    setState(() {
      _wallpapers.clear(); // Clear the current list of wallpapers.
      _page = 0; // Reset page number.
    });
    await _fetchWallpapers(); // Fetch wallpapers again.
  }

  /*void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-6988636964260545/7047550305',
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
            print('Reward award ready');
          });
        },
        onAdFailedToLoad: (error) {
          print('Failed to load a rewarded ad: ${error.message}');
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isRewardedAdReady) {
      _rewardedAd.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        setState(() {
          _wallpapersViewed = 0; // Reset the viewed counter after watching ad
        });
      });
      _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd(); // Load a new ad for next time
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
        },
      );
    }
  }*/

  @override
  void dispose() {
    //_bannerAd.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isLandscape = screenWidth > MediaQuery
        .of(context)
        .size
        .height;

    final buttonWidth = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context), // Updated to use AppColors
      appBar: AppBar(
        forceMaterialTransparency: true,
        toolbarHeight: isLandscape ? 65 : 80,
        // Adjust height for alignment
        leadingWidth: 45,
        // Consistent leading width
        backgroundColor: AppColors.backgroundColor(context),
        // Updated to use AppColors
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.refresh_rounded, color: AppColors.primaryColor(context), size: 28,),
          // Updated icon color
          onPressed: () {
            _refreshWallpapers();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share_rounded, color: AppColors.primaryColor(context),
              size: 28,), // Share icon with primary color
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
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Explore',
                        style: TextStyle(
                          fontSize: isLandscape ? 28 : 35,
                          fontWeight: FontWeight.w600,
                          color: AppColors
                              .primaryColor(context), // Text color from AppColors
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
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // Align buttons at the start
              children: [
                Flexible(
                  flex: 1, // Give equal space to all buttons
                  child: _buildRoundedButton('New',
                      _selectedButton == 'New' ? Icons.star_rounded : Icons.star_outline_rounded),
                ),
                Flexible(
                  flex: 1,
                  child: _buildRoundedButton('Popular',
                      _selectedButton == 'Popular'
                          ? Icons.local_fire_department : Icons.local_fire_department_outlined),
                ),
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? 8.0 : 16.0, vertical: 9.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth < 600 ? 2 : screenWidth < 900
                    ? 3
                    : 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: isLandscape ? 2 / 2.5 : 2 / 3.5,
              ),
              itemCount: _wallpapers.length + (_loadingMore ? 1 : 0),
              // Add 1 for the loading indicator if loading.
              itemBuilder: (context, index) {
                if (index == _wallpapers.length && _loadingMore) {
                  return Center(child: CircularProgressIndicator());
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PhotoDetailScreen(
                              imageUrl: _wallpapers[index]['url'],
                            ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: CachedNetworkImage(
                      imageUrl: _wallpapers[index]['url'],
                      placeholder: (context, url) =>
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.borderColor(context).withOpacity(0.2) ,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      errorWidget: (context, url, error) =>
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.borderColor(context).withOpacity(0.2),
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
          if (_wallpapersViewed >= _wallpaperViewLimit)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05, // 5% of screen width
                vertical: MediaQuery.of(context).size.height * 0.02, // 2% of screen height
              ), // Adjust the padding as needed
              child: Container(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () {
                    // Your action here
                   // _showRewardedAd();
                  },
                  child: Text(
                    'Watch Ads to Load More',
                    style: TextStyle(
                      color: AppColors.backgroundColorLight,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:AppColors.primaryColor(context) ,
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.02, // 2% of screen height
                    ),
                  ),
                ),
              ),
            ),
          /*Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: _showRewardedAd,
                child: Text("Watch Ad to View More"),
              ),
            ),*/
          /*if (_isBannerAdReady)
            Container(
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),*/
        ],
      ),
    );
  }

  Widget _buildRoundedButton(String label, IconData icon) {
    bool isSelected = _selectedButton == label;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0), // Space between buttons
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedButton = label; // Update the selected button
            _wallpapers.clear(); // Clear current wallpapers to fetch new ones
            _page = 0; // Reset page number
          });
          _fetchWallpapers(); // Fetch wallpapers based on the selected category
          print('$label button pressed');
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.borderColor(context)),
          // Border color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
          // Padding for height
          backgroundColor: isSelected ? AppColors.selectedButtonColor(context) : Colors
              .transparent, // Background color when selected
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          // Ensures the row takes up only necessary space
          children: [
            Icon(icon, color: AppColors.primaryColor(context)),
            // Icon
            SizedBox(width: 2.0),
            // Adjust this width to change space between the icon and label
            Text(
              label,
              style: TextStyle(
                color: AppColors.primaryColor(context), // Text color
                fontSize: 16.0, // Font size for the text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
