import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../providers/app_state.dart';
import '../widgets/auto_horizontal_product_list.dart';
import '../widgets/category_selector.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/product_scan_dialog.dart';
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
    final categoryProducts = state.catalogProducts.where((product) {
      return state.selectedCategoryId == 'all' ||
          product.category == state.selectedCategoryId;
    }).toList();
    final flashSaleProducts = categoryProducts
        .where((p) => p.isFlashSale)
        .toList();
    final popularProducts = categoryProducts;
    const languages = {
      'en': (flag: '🇺🇸', name: 'English'),
      'km': (flag: '🇰🇭', name: 'ខ្មែរ'),
      'vi': (flag: '🇻🇳', name: 'Tiếng Việt'),
    };

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF6C5CE7),
          onRefresh: state.refreshCatalog,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                                'Hello, ${state.currentUserFirstName}! 👋',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
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
                          PopupMenuButton<String>(
                            tooltip: state.text('language'),
                            initialValue: state.languageCode,
                            onSelected: state.setLanguage,
                            offset: const Offset(0, 8),
                            position: PopupMenuPosition.under,
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            surfaceTintColor: Colors.transparent,
                            elevation: 14,
                            menuPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            constraints: const BoxConstraints(minWidth: 200),
                            padding: EdgeInsets.zero,
                            style: IconButton.styleFrom(
                              minimumSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            icon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.language_rounded,
                                  color: Color(0xFF6C5CE7),
                                  size: 22,
                                ),
                                Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: Color(0xFF6C5CE7),
                                  size: 15,
                                ),
                              ],
                            ),
                            itemBuilder: (context) => languages.entries.map((
                              language,
                            ) {
                              final isSelected =
                                  state.languageCode == language.key;
                              return PopupMenuItem<String>(
                                value: language.key,
                                height: 54,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(
                                                0xFF6C5CE7,
                                              ).withValues(alpha: 0.10)
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        language.value.flag,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        language.value.name,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF6C5CE7),
                                        size: 20,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          IconButton(
                            constraints: const BoxConstraints.tightFor(
                              width: 40,
                              height: 40,
                            ),
                            padding: const EdgeInsets.all(8),
                            visualDensity: VisualDensity.compact,
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
                                constraints: const BoxConstraints.tightFor(
                                  width: 40,
                                  height: 40,
                                ),
                                padding: const EdgeInsets.all(8),
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                ),
                                onPressed: () {},
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
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

                // Search Bar with Scan Icon
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: CustomSearchBar(
                    suggestions: state.catalogProducts.map(
                      (product) => product.name,
                    ),
                    onChanged: (val) {
                      state.setSearchQuery(val);
                      if (val.isNotEmpty) {
                        onNavigateToShop();
                      }
                    },
                    onScanTap: () => ProductScanDialog.show(context, state),
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
                        content: Text(
                          applied
                              ? 'Promo code "$code" applied!'
                              : 'Invalid promo code',
                        ),
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

                // Flash Deals Auto Horizontal List
                AutoHorizontalProductList(
                  products: flashSaleProducts,
                  state: state,
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        cartQuantity: state.cartQuantityForProduct(product.id),
                        onDecreaseTap: () => state.removeOneFromCart(product),
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
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
