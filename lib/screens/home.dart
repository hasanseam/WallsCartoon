import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:share_plus/share_plus.dart';
import '../config.dart';
import 'photo_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ScrollController _scrollController = ScrollController();
  List<String> _wallpaperUrls = [];
  bool _loading = true;
  bool _isLoadingMore = false;
  String? _lastFetchedItemToken;
  static const int _fetchLimit = 10; // Number of items to load per page

  @override
  void initState() {
    super.initState();
    _fetchWallpapers();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchWallpapers() async {
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final ListResult result = await _storage
          .ref('wallpapers/')
          .list(ListOptions(
        maxResults: _fetchLimit,
        pageToken: _lastFetchedItemToken,
      ));

      // Fetch URLs for the new set of images
      final List<String> urls = [];
      for (var ref in result.items) {
        final String url = await ref.getDownloadURL();
        urls.add(url);
      }

      setState(() {
        _wallpaperUrls.addAll(urls);
        _lastFetchedItemToken = result.nextPageToken;
        _loading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      print("Error fetching wallpapers: $e");
      setState(() {
        _loading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _lastFetchedItemToken != null) {
      _fetchWallpapers();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      backgroundColor: Color(0xFFFBF3EF),
      appBar: AppBar(
        forceMaterialTransparency: true,
        toolbarHeight: isLandscape ? 45 : 65,
        leadingWidth: isLandscape ? 65 : 85,
        backgroundColor: Color(0xFFFBF3EF),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Image.asset(
            'assets/app_icon.png',
            width: isLandscape ? 40 : 30,
            height: isLandscape ? 44 : 58,
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Color(0xFFEBDED0),
              radius: isLandscape ? 25 : 30,
              child: Image.asset('assets/share_icon.png'),
            ),
            onPressed: () {
              Share.share("Check out this awesome app: https://play.google.com/store/apps/details?id=com.yourcompany.yourapp");
            },
          ),
        ],
      ),
      body: _loading
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
                        text: 'Walls',
                        style: TextStyle(
                          fontSize: isLandscape ? 28 : 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE5A219),
                        ),
                      ),
                      TextSpan(
                        text: 'cartoon',
                        style: TextStyle(
                          fontSize: isLandscape ? 28 : 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF971C1C),
                        ),
                      ),
                    ],
                  ),
                ),
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
              itemCount: _wallpaperUrls.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _wallpaperUrls.length) {
                  return Center(child: CircularProgressIndicator());
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoDetailScreen(
                          imageUrl: _wallpaperUrls[index],
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: CachedNetworkImage(
                      imageUrl: _wallpaperUrls[index],
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
}
