import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final AppState state;

  const CheckoutScreen({super.key, required this.state});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Credit Card';
  final String _selectedAddress =
      '123 Tech Avenue, Silicon Suite #404, San Francisco, CA';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'Credit Card',
      'name': 'Credit / Debit Card',
      'icon': Icons.credit_card_rounded,
      'subtitle': '**** **** **** 4242',
    },
    {
      'id': 'Apple Pay',
      'name': 'Apple Pay / Google Pay',
      'icon': Icons.account_balance_wallet_rounded,
      'subtitle': 'Fast & secure 1-Tap checkout',
    },
    {
      'id': 'PayPal',
      'name': 'PayPal',
      'icon': Icons.payment_rounded,
      'subtitle': 'user@example.com',
    },
    {
      'id': 'COD',
      'name': 'Cash on Delivery',
      'icon': Icons.local_atm_rounded,
      'subtitle': 'Pay when package arrives',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = widget.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address Card
            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF6C5CE7),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Home Address',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedAddress,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        size: 20, color: Color(0xFF6C5CE7)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Methods
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: _paymentMethods.map((pm) {
                final isSelected = _selectedPaymentMethod == pm['id'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF6C5CE7)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        pm['icon'] as IconData,
                        color: isSelected
                            ? const Color(0xFF6C5CE7)
                            : (isDark ? Colors.white70 : Colors.black54),
                      ),
                      title: Text(
                        pm['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        pm['subtitle'] as String,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF6C5CE7))
                          : const Icon(Icons.circle_outlined, color: Colors.grey),
                      onTap: () {
                        setState(
                            () => _selectedPaymentMethod = pm['id'] as String);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Summary
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                      'Subtotal', '\$${state.subtotal.toStringAsFixed(2)}'),
                  if (state.discountAmount > 0)
                    _buildSummaryRow(
                        'Discount (${state.appliedPromoCode})',
                        '-\$${state.discountAmount.toStringAsFixed(2)}',
                        isDiscount: true),
                  _buildSummaryRow(
                      'Shipping Fee',
                      state.shippingFee == 0
                          ? 'FREE'
                          : '\$${state.shippingFee.toStringAsFixed(2)}'),
                  const Divider(height: 24),
                  _buildSummaryRow(
                      'Total Amount', '\$${state.grandTotal.toStringAsFixed(2)}',
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () async {
                        setState(() => _isProcessing = true);
                        await Future.delayed(const Duration(milliseconds: 1200));

                        if (!mounted) return;

                        final order = widget.state.placeOrder(
                          address: _selectedAddress,
                          paymentMethod: _selectedPaymentMethod,
                        );

                        if (order != null && mounted) {
                          Navigator.pushReplacement(
                            this.context,
                            MaterialPageRoute(
                              builder: (context) => OrderSuccessScreen(
                                orderId: order.id,
                                onContinueShopping: () {},
                              ),
                            ),
                          );
                        }
                      },
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Confirm & Pay \$${state.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount,
      {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? const Color(0xFFFF7675) : null,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
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
