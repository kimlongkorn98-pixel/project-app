import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../providers/app_state.dart';
import '../widgets/category_selector.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_carousel.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onNavigateToShop;

  const HomeScreen({
    super.key,
    required this.state,
    required this.onNavigateToShop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final flashSaleProducts =
        MockData.products.where((p) => p.isFlashSale).toList();
    final popularProducts = state.filteredProducts;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Alex! 👋',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            const Text(
                              'Discover Trends',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            state.isDarkMode
                                ? Icons.wb_sunny_rounded
                                : Icons.nightlight_round,
                            color: const Color(0xFF6C5CE7),
                          ),
                          onPressed: () => state.toggleTheme(),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_none_rounded),
                              onPressed: () {},
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF7675),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: CustomSearchBar(
                  onChanged: (val) {
                    state.setSearchQuery(val);
                    if (val.isNotEmpty) {
                      onNavigateToShop();
                    }
                  },
                  onFilterTap: onNavigateToShop,
                ),
              ),
              const SizedBox(height: 16),

              // Hero Promo Carousel
              PromoCarousel(
                banners: MockData.promoBanners,
                onBannerTap: (code) {
                  final applied = state.applyPromoCode(code);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(applied
                          ? 'Promo code "$code" applied!'
                          : 'Invalid promo code'),
                      backgroundColor: const Color(0xFF6C5CE7),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Category Selector
              CategorySelector(
                categories: MockData.categories,
                selectedCategoryId: state.selectedCategoryId,
                onSelectCategory: (catId) {
                  state.setCategory(catId);
                },
              ),
              const SizedBox(height: 24),

              // Flash Sale Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFFFF7675),
                          size: 24,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Flash Deals',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: onNavigateToShop,
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: Color(0xFF6C5CE7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Flash Deals Horizontal List
              SizedBox(
                height: 250,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: flashSaleProducts.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final product = flashSaleProducts[index];
                    return SizedBox(
                      width: 170,
                      child: ProductCard(
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
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Popular Products Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trending Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextButton(
                      onPressed: onNavigateToShop,
                      child: const Text(
                        'Explore',
                        style: TextStyle(
                          color: Color(0xFF6C5CE7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Grid of Popular Products
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: popularProducts.length,
                  itemBuilder: (context, index) {
                    final product = popularProducts[index];
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
      ),
    );
  }
}
