import 'dart:async';
import 'package:fl_downloader/fl_downloader.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../color.dart';// Import the AppColors class

class PhotoDetailScreen extends StatefulWidget {
  final String imageUrl;

  PhotoDetailScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _PhotoDetailScreenState createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  bool _isDownloading = false;
  Timer? _timer;
  int _progress = 0;
  final int _totalActionTimeInSeconds = 3;

  bool _isAdReady = false;

  @override
  void initState() {
    super.initState();
  }

  // Show the interstitial ad if ready


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

  Future<void> _saveLikedWallpaper(String wallpaperName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> likedWallpapers = prefs.getStringList('likedWallpapers') ?? [];

    if (!likedWallpapers.contains(wallpaperName)) {
      likedWallpapers.add(wallpaperName);
      await prefs.setStringList('likedWallpapers', likedWallpapers);
    }
  }

  @override
  void dispose() {
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
              left: 20,
              child: IconButton(
                icon: Icon(IconsaxPlusLinear.arrow_left_1, color: AppColors.secondaryColor),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          if (!_isDownloading)
            Positioned(
              top: isLandscape ? 20 : 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.ios_share_sharp, color: AppColors.secondaryColor),
                onPressed: () {
                  Share.share("Check out this awesome app: https://play.google.com/store/apps/details?id=com.mdidet.wallscartoon");
                },
              ),
            ),
          // Show loading indicator when downloading, otherwise show buttons
          if (_isDownloading)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.11,  // 11% of screen width
                height: MediaQuery.of(context).size.width * 0.11, // Maintain aspect ratio
                child: CircularProgressIndicator(
                  strokeWidth: 5.0, // Keep stroke width as is or adjust
                  color: AppColors.secondaryColor,
                  backgroundColor: AppColors.borderColor,
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
    final buttonWidth = screenSize.width * 0.6; // Adjust button width
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
              backgroundColor: AppColors.borderColor, // Background color
              padding: EdgeInsets.symmetric(vertical: buttonHeight * 0.2), // Responsive padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonHeight * 0.5), // Rounded corners
                side: BorderSide(
                  color: AppColors.borderColor, // Border color
                  width: 2.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_alt_outlined,color: AppColors.primaryColor,),
                SizedBox(width: screenSize.width * 0.02), // Responsive spacing
                Text(
                  'Download',
                  style: TextStyle(
                    color: AppColors.primaryColor,
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
            border: Border.all(color: AppColors.borderColor, width: 2.0), // Border color
          ),
          child: IconButton(
            icon: Icon(
              Icons.favorite_outline,
              color: AppColors.backgroundColor, // Icon color
            ),
            // Add functionality for the love
            onPressed:() async {
              await _saveLikedWallpaper(widget.imageUrl); // Pass actual wallpaper name
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Wallpaper added to liked wallpapers!')),
              );
            },

          ),
        ),
      ],
    );
  }
}
