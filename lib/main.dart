import 'package:download_wallpaper/screens/first_time_screen.dart';
import 'package:download_wallpaper/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:iconsax_plus/iconsax_plus.dart';

import 'color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //MobileAds.instance.initialize();

  // Initialize FCM background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Run initialization of services and decide initial screen
  initializeServices().then((isFirstTime) async {
    await FirebaseMessaging.instance.subscribeToTopic("newWallpaper");
    runApp(MyApp(isFirstTime: isFirstTime));
  });
}

// Define background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background notification
  print("Handling a background message: ${message.messageId}");
}

Future<bool> initializeServices() async {
  final List results = await Future.wait([
    Firebase.initializeApp(),
    SharedPreferences.getInstance(),
  ]);

  final SharedPreferences prefs = results[1];
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  Future.microtask(() async {
   // await MobileAds.instance.initialize();
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
    await _initializeFCM(); // Initialize FCM
  });

  return isFirstTime;
}

// Initialize Firebase Cloud Messaging (FCM)
Future<void> _initializeFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission for notifications on iOS
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted notification permission');
  } else {
    print('User declined or has not accepted notification permission');
  }

  // Get and print the FCM token
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // Handle token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print("Refreshed FCM Token: $newToken");
    // Optionally, update the token on the server if needed
  });

  // Set up foreground message handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a foreground message');
    if (message.notification != null) {
      print('Notification Title: ${message.notification!.title}');
      print('Notification Body: ${message.notification!.body}');
    }
  });

  // Set up notification click handler
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('User tapped on notification');
    // Optionally, handle navigation here
  });
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({Key? key, required this.isFirstTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpaper Cartoon',
      debugShowCheckedModeBanner: false,

      // Light Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor(context),
          brightness: Brightness.light,
          background: AppColors.backgroundColorLight,
          secondary: AppColors.secondaryColor(context),
        ),
        useMaterial3: true,
      ),

      // Dark Theme
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor(context),
          brightness: Brightness.dark,
          background: AppColors.backgroundColorDark,
          secondary: AppColors.secondaryColor(context),
        ),
        useMaterial3: true,
      ),

      // Automatically switch theme based on system settings
      themeMode: ThemeMode.system,

      // Set the initial screen
      home: isFirstTime ? FirstTimeScreen() : HomeScreen(),
    );
  }
}


