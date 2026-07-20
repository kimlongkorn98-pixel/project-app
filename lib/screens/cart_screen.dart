import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../widgets/cart_item_tile.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onShopNow;

  const CartScreen({
    super.key,
    required this.state,
    required this.onShopNow,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = widget.state;
    final cartItems = state.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping Cart (${state.cartCount})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                state.clearCart();
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Color(0xFFFF7675)),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: cartItems.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Color(0xFF6C5CE7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Your Cart is Empty',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Looks like you haven\'t added any items to your shopping cart yet.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: widget.onShopNow,
                        child: const Text('Start Shopping'),
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cart Items List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return CartItemTile(
                              item: item,
                              onQuantityChanged: (newQty) {
                                state.updateQuantity(item, newQty);
                              },
                              onRemove: () {
                                state.removeFromCart(item);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Promo Code Input Box
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _promoController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter Promo Code (e.g. SUMMER50)',
                                    hintStyle: TextStyle(fontSize: 13),
                                    fillColor: Colors.transparent,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 14),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final code = _promoController.text;
                                  final success = state.applyPromoCode(code);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success
                                          ? 'Promo code "$code" applied successfully!'
                                          : 'Invalid promo code! Try SUMMER50 or FREESHIP'),
                                      backgroundColor: success
                                          ? const Color(0xFF6C5CE7)
                                          : const Color(0xFFFF7675),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                child: const Text(
                                  'Apply',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Order Breakdown Summary Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cost Breakdown',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildCostRow('Subtotal',
                                  '\$${state.subtotal.toStringAsFixed(2)}'),
                              if (state.discountAmount > 0)
                                _buildCostRow(
                                  'Promo Discount (${state.appliedPromoCode})',
                                  '-\$${state.discountAmount.toStringAsFixed(2)}',
                                  isDiscount: true,
                                ),
                              _buildCostRow(
                                'Estimated Shipping',
                                state.shippingFee == 0
                                    ? 'FREE'
                                    : '\$${state.shippingFee.toStringAsFixed(2)}',
                              ),
                              const Divider(height: 24),
                              _buildCostRow(
                                'Grand Total',
                                '\$${state.grandTotal.toStringAsFixed(2)}',
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Fixed Checkout Action Bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Total Price',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                '\$${state.grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF6C5CE7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CheckoutScreen(state: state),
                                  ),
                                );
                              },
                              child: const Text('Proceed to Checkout'),
                            ),
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

  Widget _buildCostRow(String label, String value,
      {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? const Color(0xFFFF7675) : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight:
                  isTotal || isDiscount ? FontWeight.bold : FontWeight.w600,
              color: isDiscount
                  ? const Color(0xFFFF7675)
                  : (isTotal ? const Color(0xFF6C5CE7) : null),
            ),
          ),
        ],
      ),
    );
  }
}
