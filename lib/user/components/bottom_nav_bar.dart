import 'package:flutter/material.dart';
import '../../utils/keys.dart';
import '../screens/alerts_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/post_property_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/rent_property_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0; // Default to the first tab

  // List of navigator keys corresponding to each tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    rentPropertyNavigatorKey, // Buy Land
    favoritesNavigatorKey, // Favorites
    postPropertyNavigatorKey, // Sell Land
    alertsNavigatorKey, // Alerts
    profileNavigatorKey, // Profile
  ];

  // Method to switch tabs
  void switchTab(int index) {
    if (index == _selectedIndex) {
      // If the user taps the active tab, pop to the first route
      _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Handle system back button press
  void _onPopInvokedWithResult(bool didPop, Object? result) {
    final NavigatorState currentNavigator =
    _navigatorKeys[_selectedIndex].currentState!;
    if (currentNavigator.canPop()) {
      currentNavigator.pop();
    } else {
      // Allow the app to exit if on the root route
      Navigator.of(context).maybePop();
    }
  }

  // Build offstage navigator for each tab
  Widget _buildOffstageNavigator(int index) {
    Widget child = const SizedBox(); // ✅ Default value to prevent uninitialized error

    switch (index) {
      case 0:
        child = const RentPropertyScreen(properties: [], center: null,);
        break;
      case 1:
        child = const FavoritesScreen();
        break;
      case 2:
        child = const PostPropertyScreen();
        break;
      case 3:
        child = const AlertsScreen();
        break;
      case 4:
        child = const ProfileScreen();
        break;
    }

    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (context) => child,
            settings: settings,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: Scaffold(
        body: Stack(
          children: List.generate(
            _navigatorKeys.length,
                (index) => _buildOffstageNavigator(index),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              label: 'Rent',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.place_outlined),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_outlined),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
              fontSize: 12), // Custom font size for selected label
          unselectedLabelStyle: const TextStyle(
              fontSize: 12), // Custom font size for unselected labels
          onTap: (index) {
            switchTab(index);
          },
        ),
      ),
    );
  }
}
