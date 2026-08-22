import 'package:flutter/material.dart';
import '../models/product.dart';
import 'rating_stars.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onAddToCartTap;
  final int cartQuantity;
  final VoidCallback? onDecreaseTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onAddToCartTap,
    this.cartQuantity = 0,
    this.onDecreaseTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flexible Product Image Header
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image(
                      image: product.imageProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Badges
                  if (product.discountPercentage > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7675),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercentage}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isWishlisted
                              ? const Color(0xFFFF7675)
                              : Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Flexible Product Details Body
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    RatingStars(
                      rating: product.rating,
                      reviewCount: product.reviewCount,
                      starSize: 11,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (product.originalPrice > product.price)
                                Text(
                                  product.formattedOriginalPrice,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                product.formattedPrice,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF6C5CE7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        cartQuantity == 0
                            ? InkWell(
                                onTap: onAddToCartTap,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C5CE7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              )
                            : Container(
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C5CE7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _QuantityButton(
                                      icon: Icons.remove_rounded,
                                      onTap: onDecreaseTap,
                                    ),
                                    Text(
                                      '$cartQuantity',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    _QuantityButton(
                                      icon: Icons.add_rounded,
                                      onTap: onAddToCartTap,
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 24,
        height: 28,
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }
}
