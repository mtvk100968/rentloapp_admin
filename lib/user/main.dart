// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:provider/provider.dart';
//
// import '../admin/services/property_service.dart';
// import './components/bottom_nav_bar.dart';
// import './utils/keys.dart'; // Import global keys and tab indices
//
// // Example providers. Replace these with your real ones:
// import './providers/property_provider.dart';
// import './services/property_service.dart';
// import 'firebase_options.dart';
//
// /// Recommended to add the entry-point annotation for Flutter 3.3+.
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.messageId}");
// }
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   try {
//     // 1. Initialize Firebase
//     await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform);
//
//     // 2. Setup background message handling
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//     // 3. Get FCM token (for debugging/logging or your backend)
//     final messaging = FirebaseMessaging.instance;
//     final fcmToken = await messaging.getToken();
//     print("FCM Token: $fcmToken");
//
//     // 4. iOS permissions (no effect on Android)
//     final settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       print('User granted provisional permission');
//     } else {
//       print('User declined or has not granted permission');
//     }
//   } catch (e) {
//     print("Error initializing Firebase: $e");
//   }
//
//   // Wrap your app in the MultiProvider at the root level:
//   runApp(
//     MultiProvider(
//       providers: [
//         // Put your real providers here:
//         ChangeNotifierProvider<PropertyProvider>(
//           create: (_) => PropertyProvider(),
//         ),
//         Provider<PropertyService>(
//           create: (_) => PropertyService(),
//         ),
//         // Add more providers if needed
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Rentloapp',
//       theme: ThemeData(
//         fontFamily: 'Lato',
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
//         useMaterial3: true, // Opt into Material 3 design
//       ),
//       debugShowCheckedModeBanner: false,
//       home: BottomNavBar(key: bottomNavBarKey),
//     );
//   }
// }
