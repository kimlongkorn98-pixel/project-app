import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final VoidCallback onContinueShopping;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.onContinueShopping,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Icon Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Order Placed Successfully! 🎉',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'Thank you for your purchase. Your order #$orderId has been placed and is being prepared for shipping.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Tracking Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryInfo(
                      'Estimated Delivery',
                      'July 24 - July 26',
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    _buildSummaryInfo('Shipping Method', 'Standard Express'),
                  ],
                ),
              ),

              const Spacer(),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    onContinueShopping();
                  },
                  child: const Text('Back to Home'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
