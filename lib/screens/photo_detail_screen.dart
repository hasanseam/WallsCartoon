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
        await FlDownloader.download(url);

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
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

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
          // Top gradient overlay
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
          // Bottom gradient overlay
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
          Positioned(
            top: isLandscape ? 20 : 40,
            left: 20,
            child: IconButton(
              icon: CircleAvatar(
                backgroundColor: Color(0xFF74625E),
                radius: 25,
                child: Image.asset(
                  'assets/arrow_icon.png',
                  height: 24.0,
                  width: 24.0,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // Overlay with buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _isDownloading
                ? _buildProgressButton() // Show progress button while downloading
                : _buildButtons(screenSize), // Show buttons when not downloading
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(Size screenSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Download Button
        Container(
          width: screenSize.width * 0.6, // Responsive width
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: () => _checkAndDownloadImage(widget.imageUrl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/download_icon.png',
                    height: 24.0,
                    width: 24.0,
                  ),
                  SizedBox(width: 16.0),
                  Text(
                    'Download',
                    style: TextStyle(
                      color: Color(0xFF971C1C),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF9CC03),
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
        // Share Button
        IconButton(
          icon: CircleAvatar(
            backgroundColor: Color(0xFFEBDED0),
            radius: 30,
            child: Image.asset(
              'assets/share_icon.png',
              height: 24.0,
              width: 24.0,
            ),
          ),
          onPressed: () {
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
        width: 120.0,
        height: 60.0,
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 120.0, height: 60.0),
          child: CustomPaint(
            painter: _MyElevatedRoundedButtonPainter(
              (_progress / 1000) / _totalActionTimeInSeconds,
            ),
            child: Center(
              child: Text(
                'Downloading...',
                style: TextStyle(
                  color: Color(0xFF14AE5C),
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
        Rect.fromLTRB(0.0, 6.0, size.width, size.height + 6.0),
        Radius.circular(30.0),
      ),
      paint,
    );

    // Draw button background
    paint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0.0, 0.0, size.width, size.height),
        Radius.circular(30.0),
      ),
      paint,
    );

    // Draw progress bar with padding
    double padding = 8.0;
    paint.color = Color(0xFFC7E7D6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          padding,
          padding,
          (progress * (size.width - (2 * padding))),
          size.height - padding,
        ),
        Radius.circular(30.0),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_MyElevatedRoundedButtonPainter oldDelegate) => this.progress != oldDelegate.progress;
}
