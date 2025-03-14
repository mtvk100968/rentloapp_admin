// // lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rentloapp_admin/user/components/bottom_nav_bar.dart';
import 'package:rentloapp_admin/user/components/views/property_map_view.dart';
import 'package:rentloapp_admin/user/screens/profile_screen.dart';
import 'package:rentloapp_admin/user/screens/rent_property_screen.dart';
import 'common/models_user/property_model.dart';
import 'common/providers_user/property_provider.dart';
import 'common/services_admin/property_service.dart';
import 'common/services_user/property_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the primary (admin) Firebase app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.admin,
  );
  print("Primary (admin) Firebase app initialized.");

  // Initialize the secondary (user) Firebase app
  if (Firebase.apps.where((app) => app.name == 'user').isEmpty) {
    try {
      await Firebase.initializeApp(
        name: 'user',
        options: DefaultFirebaseOptions.user,
      );
      print("Secondary (user) Firebase app initialized.");
    } catch (e) {
      print("Error initializing user Firebase app: $e");
    }
  } else {
    print("Secondary (user) Firebase app already initialized.");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PropertyProvider>(
          create: (_) => PropertyProvider(),
        ),
        Provider<PropertyService>(
          create: (_) => PropertyService(),
        ),
        Provider<PropertyServiceUser>(
          create: (_) => PropertyServiceUser(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rentloapp',
      theme: ThemeData(
        fontFamily: 'Lato',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: BottomNavBar(),
// For example, you could have a bottom nav bar as your home
      routes: {
        '/homeScreen': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(), // User profile screen
// other routes
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  Future<List<Property>> fetchProperties() async {
    final userFirestore = FirebaseFirestore.instanceFor(app: Firebase.app('user'));
    QuerySnapshot snapshot = await userFirestore.collection('properties').get();
    return snapshot.docs
        .map((doc) => Property.fromDocument(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  void _goToRentPropertyScreen(BuildContext context) async {
    List<Property> properties = await fetchProperties();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            Provider<PropertyServiceUser>(create: (_) => PropertyServiceUser()),
          ],
          child: RentPropertyScreen(
            properties: properties,
            center: properties.isNotEmpty
                ? LatLng(properties.first.latitude, properties.first.longitude)
                : const LatLng(20.5937, 78.9629),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _goToRentPropertyScreen(context),
          child: const Text("Go to Rent Property Screen"),
        ),
      ),
    );
  }
}