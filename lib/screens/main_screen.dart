import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  bool _isMenuVisible = true;

  bool _handleScroll(ScrollNotification notification) {
    // Keep navigation available on utility pages. The immersive hide-on-scroll
    // behavior is only useful while browsing the Home and Explore catalogs.
    if (_currentIndex > 1) {
      return false;
    }

    if (notification.metrics.axis != Axis.vertical ||
        notification is! UserScrollNotification) {
      return false;
    }

    if (notification.direction == ScrollDirection.idle) {
      return false;
    }

    final shouldShow = notification.direction == ScrollDirection.forward;
    if (shouldShow != _isMenuVisible) {
      setState(() => _isMenuVisible = shouldShow);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    final pages = [
      HomeScreen(
        state: state,
        onNavigateToShop: () => setState(() => _currentIndex = 1),
      ),
      DiscoverScreen(state: state),
      CartScreen(
        state: state,
        onShopNow: () => setState(() => _currentIndex = 1),
      ),
      WishlistScreen(
        state: state,
        onExplore: () => setState(() => _currentIndex = 1),
      ),
      ProfileScreen(state: state),
    ];

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: ClipRect(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: _isMenuVisible ? 1 : 0,
            child: CustomBottomNav(
              currentIndex: _currentIndex,
              cartBadgeCount: state.cartCount,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  _isMenuVisible = true;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
