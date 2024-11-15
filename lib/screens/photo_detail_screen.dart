import 'dart:async';
import 'package:fl_downloader/fl_downloader.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../color.dart';// Import the AppColors class


class PhotoDetailScreen extends StatefulWidget {
  final String imageUrl;
  final Function() ? onLiked;

  PhotoDetailScreen({Key? key, required this.imageUrl, this.onLiked}) : super(key: key);

  @override
  _PhotoDetailScreenState createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  bool _isDownloading = false;
  bool _isLiked = false; // Track if the wallpaper is liked
  Timer? _timer;
  int _progress = 0;
  final int _totalActionTimeInSeconds = 3;

  //InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  @override
  void initState() {
    super.initState();
    //loadInterstitialAd();  // Load the interstitial ad when screen initializes
    _checkIfLiked();  // Check if the wallpaper is liked when the screen loads
  }

  // Load the interstitial ad
  /*void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: '//////////////////////////////////////',  // Your Interstitial Ad Unit ID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdReady = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          _isAdReady = false;
        },
      ),
    );
  }*/

  // Show the interstitial ad if ready
  /*void showInterstitialAd() {
    if (_isAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;  // Reset ad after showing
      _isAdReady = false;
      loadInterstitialAd();  // Preload the next ad
    }
  }*/

  Future<void> _checkIfLiked() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> likedWallpapers = prefs.getStringList('likedWallpapers') ?? [];

    // Check if the current wallpaper is in the liked list
    setState(() {
      _isLiked = likedWallpapers.contains(widget.imageUrl);
    });
  }

  Future<void> _saveLikedWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> likedWallpapers = prefs.getStringList('likedWallpapers') ?? [];

    if (_isLiked) {
      // Remove the wallpaper from the liked list
      likedWallpapers.remove(widget.imageUrl);
      await prefs.setStringList('likedWallpapers', likedWallpapers);
    } else {
      // Add the wallpaper to the liked list
      likedWallpapers.add(widget.imageUrl);
      await prefs.setStringList('likedWallpapers', likedWallpapers);
    }

    // Toggle the liked state
    setState(() {
      _isLiked = !_isLiked;
    });

    widget.onLiked?.call();

  }

  Future<void> _checkAndDownloadImage(String url) async {
    final permission = await FlDownloader.requestPermission();
    if (permission == StoragePermissionStatus.granted) {
      setState(() {
        _isDownloading = true;
      });

      _initCounter();

      try {
        // Simulate a download delay for testing
        await Future.delayed(Duration(seconds: _totalActionTimeInSeconds));
        // Uncomment the next line when you're ready for actual download
        await FlDownloader.download(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download completed!')),
        );

        // Show the ad after download completes
        //showInterstitialAd();
      } catch (e) {
        debugPrint('Download failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      } finally {
        _stopCounter();
      }
    } else {
      debugPrint('Permission denied =(');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  void _initCounter() {
    _timer?.cancel();
    _progress = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() => _progress += 50);

      if (Duration(milliseconds: _progress).inSeconds >= _totalActionTimeInSeconds) {
        _timer?.cancel();
      }
    });
  }

  void _stopCounter() {
    _timer?.cancel();
    setState(() {
      _progress = 0;  // Reset progress
      _isDownloading = false;  // Reset downloading state
    });
  }

  @override
  void dispose() {
   // _interstitialAd?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: widget.imageUrl,
            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            maxHeightDiskCache: 500,
            maxWidthDiskCache: 500,
          ),
          // Dim the screen when downloading
          if (_isDownloading)
            Container(
              color: Colors.black.withOpacity(0.65), // Dimmed layer
            ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: screenSize.height * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: screenSize.height * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          if (!_isDownloading)
            Positioned(
              top: isLandscape ? 20 : 40,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.likeBorderColor(context), size: 28,),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          if (!_isDownloading)
            Positioned(
              top: isLandscape ? 20 : 40,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.ios_share_rounded, color: AppColors.likeBorderColor(context), size: 28,),
                onPressed: () {
                  Share.share("Check out this awesome app: https://play.google.com/store/apps/details?id=com.mdidet.wallscartoon");
                },
              ),
            ),
          // Show loading indicator when downloading, otherwise show buttons
          if (_isDownloading)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.16,  // 11% of screen width
                height: MediaQuery.of(context).size.width * 0.16, // Maintain aspect ratio
                child: CircularProgressIndicator(
                    strokeWidth: 5.0, // Keep stroke width as is or adjust
                    color: AppColors.secondaryColor(context),
                    backgroundColor: AppColors.borderColor(context).withOpacity(0.2)
                ),
              ),
            )
          else
            Positioned(
              bottom: 30,  // Move download button slightly up
              left: 20,
              right: 20,
              child: _buildButtons(screenSize),  // Show buttons when not downloading
            ),
        ],
      ),
    );
  }

  Widget _buildButtons(Size screenSize) {
    final buttonWidth = screenSize.width * 0.4; // Adjust button width
    final downloadIconSize = screenSize.width * 0.07; // Icon size for download button
    final loveIconSize = screenSize.width * 0.05; // Slightly smaller icon size for love button
    final fontSize = screenSize.width * 0.045; // Font size based on screen width
    final buttonHeight = screenSize.height * 0.06; // Button height based on screen height

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Download Button
        Container(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () => _checkAndDownloadImage(widget.imageUrl),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.borderColor(context), // Background color
              padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.2), // Responsive padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonHeight * 0.5), // Rounded corners
                side: BorderSide(
                  color: AppColors.borderColor(context), // Border color
                  width: 2.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_alt_outlined,color: AppColors.primaryColor(context),),
                SizedBox(width: screenSize.width * 0.02), // Responsive spacing
                Text(
                  'Download',
                  style: TextStyle(
                    color: AppColors.primaryColor(context),
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: screenSize.width * 0.04),  // Responsive spacing between buttons

        // Circular Love Button with Border
        Container(
          width: buttonHeight,
          height: buttonHeight,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isLiked ? AppColors.likeBorderColor(context) : Colors.transparent, // Background color when liked
            border: Border.all(color: AppColors.likeBorderColor(context), width: 2.0), // Border color
          ),
          child: IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_outline, // Toggle the icon
              color: _isLiked ? AppColors.likeColor(context) : AppColors.likeBorderColor(context), // Icon color when liked
            ),
            onPressed: _saveLikedWallpaper, // Toggle the liked state
          ),
        ),
      ],
    );
  }
}

