import 'dart:async';
import 'package:fl_downloader/fl_downloader.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

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
        // await FlDownloader.download(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download completed!')),
        );
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
      _progress = 0; // Reset progress
      _isDownloading = false; // Reset downloading state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          CachedNetworkImage(
            imageUrl: widget.imageUrl,
            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          // Gradient overlay at the top
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.9), // Darker color at the top
                  Colors.black.withOpacity(0.4), // Lighter color at the middle
                  Colors.transparent, // Fully transparent in the center
                ],
                stops: [0.0, 0.5, 0.75], // Stops to control fade
                begin: Alignment.topCenter,
                end: Alignment.center, // Fade from top to center
              ),
            ),
          ),
          // Gradient overlay at the bottom
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent, // Fully transparent in the middle
                  Colors.black.withOpacity(0.4), // Lighter color at the middle
                  Colors.black.withOpacity(0.9), // Darker color at the bottom
                ],
                stops: [0.0, 0.25, 1.0], // Stops to control fade
                begin: Alignment.center,
                end: Alignment.bottomCenter, // Fade from center to bottom
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: CircleAvatar(
                backgroundColor: Color(0xFF74625E), // Background color of the arrow button
                radius: 25, // Adjust the radius as needed
                child: Image.asset(
                  'assets/arrow_icon.png', // Set your arrow icon image here
                  height: 24.0, // Set height of the icon
                  width: 24.0, // Set width of the icon
                ),
              ),
              onPressed: (){
                Navigator.pop(context);
              }, // Call the share function
            ),
          ),
          // Overlay with buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _isDownloading
                ? _buildProgressButton() // Show progress button while downloading
                : _buildButtons(), // Show buttons when not downloading
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
      children: [
        // Download Button
        Container(
          width: 290, // Set the width of the download button
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: () => _checkAndDownloadImage(widget.imageUrl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/download_icon.png', // Set your download icon image here
                    height: 24.0, // Set height of the icon
                    width: 24.0, // Set width of the icon
                  ),
                  SizedBox(width: 16.0), // Space between icon and text
                  Text(
                    'Download',
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
        SizedBox(width: 20), // Space between the buttons
        // Share Button
        IconButton(
          icon: CircleAvatar(
            backgroundColor: Color(0xFFEBDED0), // Background color of the share button
            radius: 30, // Adjust the radius as needed
            child: Image.asset(
              'assets/share_icon.png', // Set your share icon image here
              height: 24.0, // Set height of the icon
              width: 24.0, // Set width of the icon
            ),
          ),
          onPressed: () {
            // Implement your share functionality here
            Share.share('Check out this wallpaper: ${widget.imageUrl}');
          },
        ),
      ],
    );
  }

  Widget _buildProgressButton() {
    return GestureDetector(
      onTapDown: (_) => _initCounter(),
      onTapUp: (_) => _stopCounter(),
      child: SizedBox(
        width: 120.0, // Adjust the width as needed
        height: 60.0,
        child: ConstrainedBox( // Wrap CustomPaint with ConstrainedBox
          constraints: BoxConstraints.tightFor(width: 120.0, height: 60.0), // Set constraints
          child: CustomPaint(
            painter: _MyElevatedRoundedButtonPainter(
              (_progress / 1000) / _totalActionTimeInSeconds,
            ),
            child: Center(
              child: Text(
                'Downloading...',
                style: TextStyle(
                  color: Color(0xFF14AE5C), // Text color
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}



class _MyElevatedRoundedButtonPainter extends CustomPainter {
  const _MyElevatedRoundedButtonPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    // Draw shadow
    paint.color = Colors.black.withOpacity(0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0.0, 6.0, size.width, size.height + 6.0), // Offset the shadow downwards
        Radius.circular(30.0), // Rounded corners for shadow
      ),
      paint,
    );

    // Draw button background
    paint.color = Colors.white; // Button color
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0.0, 0.0, size.width, size.height), // Regular position
        Radius.circular(30.0), // Rounded corners for the button
      ),
      paint,
    );

    // Draw progress bar with padding
    double padding = 8.0; // Set the padding for the progress bar
    paint.color = Color(0xFFC7E7D6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          padding, // Left padding
          padding, // Top padding
          (progress * (size.width - (2 * padding))), // Right edge with padding
          size.height - padding, // Bottom edge with top padding
        ),
        Radius.circular(30.0), // Rounded corners for the progress bar
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_MyElevatedRoundedButtonPainter oldDelegate) => this.progress != oldDelegate.progress;
}