import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'photo_detail_screen.dart';  // Import the new file

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> _wallpaperUrls = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWallpapers();
  }

  Future<void> _fetchWallpapers() async {
    try {
      final ListResult result = await _storage.ref('wallpapers/').listAll();
      final List<String> urls = [];

      for (var ref in result.items) {
        final String url = await ref.getDownloadURL();
        urls.add(url);
      }

      setState(() {
        _wallpaperUrls = urls;
        _loading = false;
      });
    } catch (e) {
      print("Error fetching wallpapers: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBF3EF),
      appBar: AppBar(
        forceMaterialTransparency: true,
        toolbarHeight: 100,
        leadingWidth: 120,
        backgroundColor: Color(0xFFFBF3EF), // Set the app bar color
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8), // Reduced padding for larger icon
          child: Image.asset(
            'assets/app_icon.png', // Replace with your app icon path
            width: 52, // Larger icon width
            height: 58, // Larger icon height
          ),
        ),
        actions: [
          IconButton(
            icon:CircleAvatar(
      backgroundColor: Color(0xFFEBDED0),
        radius: 30, // Adjust the radius as needed
        child: Image.asset('assets/share_icon.png'),
      ) ,
            onPressed: () {
              // Implement your share functionality here
              // For example, you might use the share package to share the current content
            },
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Walls',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE5A219), // Color for "Wall"
                        ),
                      ),
                      TextSpan(
                        text: 'cartoon',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF971C1C), // Color for "cartoon"
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
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 2/3.5,
              ),
              itemCount: _wallpaperUrls.length,
              itemBuilder: (context, index) {
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
