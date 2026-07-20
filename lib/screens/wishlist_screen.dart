import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onExplore;

  const WishlistScreen({
    super.key,
    required this.state,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final wishlistItems = state.wishlistProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Wishlist (${wishlistItems.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: wishlistItems.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7675).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 64,
                          color: Color(0xFFFF7675),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Your Wishlist is Empty',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Explore your favorite items and tap the heart icon to save them here.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: onExplore,
                        child: const Text('Start Exploring'),
                      ),
                    ],
                  ),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final product = wishlistItems[index];
                  return ProductCard(
                    product: product,
                    isWishlisted: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: product,
                            state: state,
                          ),
                        ),
                      );
                    },
                    onFavoriteTap: () => state.toggleWishlist(product.id),
                    onAddToCartTap: () {
                      state.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${product.name} to cart!'),
                          backgroundColor: const Color(0xFF6C5CE7),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
