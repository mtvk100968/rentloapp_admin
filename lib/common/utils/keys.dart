// lib/utils/keys.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../user/components/bottom_nav_bar.dart';


// Navigator keys for each tab
final GlobalKey<NavigatorState> rentPropertyNavigatorKey =
GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> favoritesNavigatorKey =
GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> postPropertyNavigatorKey =
GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> alertsNavigatorKey =
GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> profileNavigatorKey =
GlobalKey<NavigatorState>();

// Define tab indices for easier reference
class TabIndices {
  static const int rentProperty = 0;
  static const int favorites = 1;
  static const int postProperty = 2;
  static const int alerts = 3;
  static const int profile = 4;
}

// Global key for BottomNavBar to allow external access
final GlobalKey<BottomNavBarState> bottomNavBarKey =
GlobalKey<BottomNavBarState>();

/// ApiKeys class to hold all API keys and other constants
class ApiKeys {
  /// Retrieves the Google Maps API key from environment variables
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

// Add other API keys here with similar getters
// static String get anotherApiKey => dotenv.env['ANOTHER_API_KEY'] ?? '';
}
