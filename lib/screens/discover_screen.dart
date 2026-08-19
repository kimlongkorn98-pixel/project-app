import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../providers/app_state.dart';
import '../widgets/category_selector.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/product_scan_dialog.dart';
import 'product_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  final AppState state;

  const DiscoverScreen({super.key, required this.state});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  bool _isHeaderVisible = true;

  bool _handleScroll(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification ||
        notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final scrollDelta = notification.scrollDelta;
    if (scrollDelta == null || scrollDelta == 0) {
      return false;
    }

    final shouldShow = scrollDelta < 0;
    if (_isHeaderVisible != shouldShow) {
      setState(() => _isHeaderVisible = shouldShow);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final products = state.filteredProducts;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _isHeaderVisible ? 1 : 0,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Explore Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                        child: CustomSearchBar(
                          hintText: 'Search electronics, fashion, shoes...',
                          onChanged: (val) => state.setSearchQuery(val),
                          onScanTap: () =>
                              ProductScanDialog.show(context, state),
                        ),
                      ),
                      CategorySelector(
                        categories: MockData.categories,
                        selectedCategoryId: state.selectedCategoryId,
                        onSelectCategory: (catId) => state.setCategory(catId),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

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
                  : NotificationListener<ScrollNotification>(
                      onNotification: _handleScroll,
                      child: GridView.builder(
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
                            cartQuantity: state.cartQuantityForProduct(
                              product.id,
                            ),
                            onDecreaseTap: () =>
                                state.removeOneFromCart(product),
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
                            onFavoriteTap: () =>
                                state.toggleWishlist(product.id),
                            onAddToCartTap: () {
                              state.addToCart(product);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
