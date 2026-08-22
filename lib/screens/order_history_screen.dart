import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';

class OrderHistoryScreen extends StatelessWidget {
  final AppState state;

  const OrderHistoryScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final orders = state.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: orders.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 64,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Orders Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'When you place an order, it will show up here.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6C5CE7,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                order.status.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF6C5CE7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy • hh:mm a',
                          ).format(order.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const Divider(height: 20),

                        // Item Thumbnails
                        SizedBox(
                          height: 50,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: order.items.length,
                            separatorBuilder: (context, idx) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final item = order.items[idx];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.product.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${order.items.length} Item(s)',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Total: \$${order.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: Color(0xFF6C5CE7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
