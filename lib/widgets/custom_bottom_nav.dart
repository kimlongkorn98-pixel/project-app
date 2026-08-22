import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final int cartBadgeCount;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.cartBadgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.explore_rounded, 'label': 'Shop'},
      {'icon': Icons.shopping_bag_rounded, 'label': 'Cart'},
      {'icon': Icons.favorite_rounded, 'label': 'Saved'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      height: 68,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final isSelected = currentIndex == index;
          final item = navItems[index];
          final isCart = index == 2;

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C5CE7).withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: isSelected
                            ? const Color(0xFF6C5CE7)
                            : (isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600),
                        size: 22,
                      ),
                      if (isCart && cartBadgeCount > 0)
                        Positioned(
                          top: -4,
                          right: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF7675),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$cartBadgeCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        color: Color(0xFF6C5CE7),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
