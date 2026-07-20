import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../providers/app_state.dart';
import '../widgets/category_selector.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/product_scan_dialog.dart';
import 'product_detail_screen.dart';

class DiscoverScreen extends StatelessWidget {
  final AppState state;

  const DiscoverScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final products = state.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input with Scan Icon
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: CustomSearchBar(
                hintText: 'Search electronics, fashion, shoes...',
                onChanged: (val) => state.setSearchQuery(val),
                onScanTap: () => ProductScanDialog.show(context, state),
              ),
            ),

            // Category Pills
            CategorySelector(
              categories: MockData.categories,
              selectedCategoryId: state.selectedCategoryId,
              onSelectCategory: (catId) => state.setCategory(catId),
            ),
            const SizedBox(height: 16),

            // Product Grid or Empty State
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try searching with a different keyword or category.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          isWishlisted: state.isWishlisted(product.id),
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
          ],
        ),
      ),
    );
  }
}
