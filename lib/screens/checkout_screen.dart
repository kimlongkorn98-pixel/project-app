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
  int _currentStep = 0;
  bool _isProcessing = false;
  String _selectedAddress =
      '123 Tech Avenue, Silicon Suite #404, San Francisco, CA';
  String _selectedPaymentMethod = 'Credit Card';

  static const _addresses = [
    {
      'label': 'Home',
      'address': '123 Tech Avenue, Silicon Suite #404, San Francisco, CA',
    },
    {
      'label': 'Office',
      'address': '88 Market Street, Floor 12, San Francisco, CA',
    },
  ];

  static const _paymentMethods = [
    {
      'id': 'Credit Card',
      'name': 'Credit / Debit Card',
      'icon': Icons.credit_card_rounded,
      'subtitle': '•••• •••• •••• 4242',
    },
    {
      'id': 'Digital Wallet',
      'name': 'Google Pay',
      'icon': Icons.account_balance_wallet_rounded,
      'subtitle': 'Fast and secure checkout',
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
      'subtitle': 'Pay when the package arrives',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _confirmClearCart,
            child: const Text(
              'Clear',
              style: TextStyle(
                color: Color(0xFFFF7675),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepProgress(currentStep: _currentStep),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: switch (_currentStep) {
                  0 => _buildAddressStep(isDark),
                  1 => _buildPaymentStep(isDark),
                  _ => _buildInvoiceStep(isDark),
                },
              ),
            ),
            _buildBottomActions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose delivery location',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select where you want your order delivered.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ..._addresses.map((address) {
          final isSelected = _selectedAddress == address['address'];
          return _SelectionCard(
            selected: isSelected,
            isDark: isDark,
            icon: Icons.location_on_rounded,
            title: address['label']!,
            subtitle: address['address']!,
            onTap: () => setState(() => _selectedAddress = address['address']!),
          );
        }),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add new address'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose payment method',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your payment information is protected.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ..._paymentMethods.map((method) {
          final isSelected = _selectedPaymentMethod == method['id'];
          return _SelectionCard(
            selected: isSelected,
            isDark: isDark,
            icon: method['icon'] as IconData,
            title: method['name'] as String,
            subtitle: method['subtitle'] as String,
            onTap: () =>
                setState(() => _selectedPaymentMethod = method['id'] as String),
          );
        }),
      ],
    );
  }

  Widget _buildInvoiceStep(bool isDark) {
    final state = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review your invoice',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Check your order before placing it.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        _InvoiceSection(
          title: 'Delivery location',
          icon: Icons.location_on_rounded,
          value: _selectedAddress,
          onEdit: () => setState(() => _currentStep = 0),
        ),
        const SizedBox(height: 12),
        _InvoiceSection(
          title: 'Payment method',
          icon: Icons.credit_card_rounded,
          value:
              _paymentMethods.firstWhere(
                    (method) => method['id'] == _selectedPaymentMethod,
                  )['name']
                  as String,
          onEdit: () => setState(() => _currentStep = 1),
        ),
        const SizedBox(height: 20),
        const Text(
          'Items',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(isDark),
          child: Column(
            children: [
              ...state.cartItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${item.quantity} × ${item.product.formattedPriceForSize(item.selectedSize)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              _amountRow('Subtotal', '\$${state.subtotal.toStringAsFixed(2)}'),
              if (state.discountAmount > 0)
                _amountRow(
                  'Discount',
                  '-\$${state.discountAmount.toStringAsFixed(2)}',
                  color: const Color(0xFFFF7675),
                ),
              _amountRow(
                'Shipping',
                state.shippingFee == 0
                    ? 'FREE'
                    : '\$${state.shippingFee.toStringAsFixed(2)}',
              ),
              const Divider(height: 24),
              _amountRow(
                'Total',
                '\$${state.grandTotal.toStringAsFixed(2)}',
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(bool isDark) {
    final isLastStep = _currentStep == 2;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            OutlinedButton(
              onPressed: _isProcessing
                  ? null
                  : () => setState(() => _currentStep--),
              style: OutlinedButton.styleFrom(minimumSize: const Size(92, 52)),
              child: const Text('Back'),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : (isLastStep
                          ? _placeOrder
                          : () => setState(() => _currentStep++)),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        isLastStep
                            ? 'Place order • \$${widget.state.grandTotal.toStringAsFixed(2)}'
                            : 'Continue',
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final order = widget.state.placeOrder(
      address: _selectedAddress,
      paymentMethod: _selectedPaymentMethod,
    );
    if (order == null || !mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OrderSuccessScreen(orderId: order.id, onContinueShopping: () {}),
      ),
    );
  }

  Future<void> _confirmClearCart() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear your cart?'),
        content: const Text(
          'This will remove all items from your cart and cancel checkout.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Color(0xFFFF7675)),
            ),
          ),
        ],
      ),
    );

    if (shouldClear == true && mounted) {
      widget.state.clearCart();
      Navigator.pop(context);
    }
  }

  BoxDecoration _cardDecoration(bool isDark) => BoxDecoration(
    color: isDark ? const Color(0xFF1E293B) : Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
    ],
  );

  Widget _amountRow(
    String label,
    String value, {
    Color? color,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? (isTotal ? const Color(0xFF6C5CE7) : null),
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int currentStep;
  const _StepProgress({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Location', 'Payment', 'Invoice'];
    const primary = Color(0xFF6C5CE7);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? Colors.white12 : const Color(0xFFE2E8F0);
    final progress =
        currentStep.clamp(0, labels.length - 1) / (labels.length - 1);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFF1F2F6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stepWidth = constraints.maxWidth / labels.length;

          return Stack(
            children: [
              Positioned(
                top: 16,
                left: stepWidth / 2,
                right: stepWidth / 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: SizedBox(
                    height: 3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: trackColor),
                        TweenAnimationBuilder<double>(
                          tween: Tween(end: progress),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) => Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: value,
                              child: const ColoredBox(color: primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(labels.length, (index) {
                  final isComplete = index < currentStep;
                  final isActive = index == currentStep;

                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isComplete
                                ? primary
                                : (isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isComplete || isActive
                                  ? primary
                                  : trackColor,
                              width: isActive ? 3 : 2,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.22),
                                      blurRadius: 9,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isComplete
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isActive ? primary : Colors.grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isActive
                                ? primary
                                : (isComplete
                                      ? (isDark
                                            ? Colors.white70
                                            : const Color(0xFF475569))
                                      : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final bool selected;
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SelectionCard({
    required this.selected,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? const Color(0xFF6C5CE7) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF6C5CE7)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? const Color(0xFF6C5CE7) : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final VoidCallback onEdit;
  const _InvoiceSection({
    required this.title,
    required this.icon,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C5CE7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Edit')),
        ],
      ),
    );
  }
}
