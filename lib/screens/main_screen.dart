import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../widgets/custom_bottom_nav.dart';
import 'cart_screen.dart';
import 'discover_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';

class MainScreen extends StatefulWidget {
  final AppState state;

  const MainScreen({super.key, required this.state});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    final pages = [
      HomeScreen(
        state: state,
        onNavigateToShop: () => setState(() => _currentIndex = 1),
      ),
      DiscoverScreen(state: state),
      WishlistScreen(
        state: state,
        onExplore: () => setState(() => _currentIndex = 1),
      ),
      CartScreen(
        state: state,
        onShopNow: () => setState(() => _currentIndex = 1),
      ),
      ProfileScreen(state: state),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        cartBadgeCount: state.cartCount,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
