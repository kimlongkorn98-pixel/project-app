import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import 'order_history_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AppState state;

  const ProfileScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.text('profile'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          child: Column(
            children: [
              // User Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                        : [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Alex Morgan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF7675),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'alex.morgan@example.com',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats Row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      state.text('orders'),
                      '${state.orders.length}',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderHistoryScreen(state: state),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                    _buildStatItem(
                      state.text('saved'),
                      '${state.wishlistIds.length}',
                      () {},
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                    _buildStatItem(
                      state.text('vouchers'),
                      '3 ${state.text('active')}',
                      () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu List wrapped in Material widget
              Material(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildMenuTile(
                      icon: Icons.local_shipping_rounded,
                      title: state.text('orderHistory'),
                      subtitle: state.text('trackOrders'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderHistoryScreen(state: state),
                          ),
                        );
                      },
                    ),
                    _buildDivider(isDark),

                    _buildMenuTile(
                      icon: Icons.location_on_rounded,
                      title: state.text('shippingAddresses'),
                      subtitle: state.text('savedAddress'),
                      onTap: () {},
                    ),
                    _buildDivider(isDark),

                    _buildMenuTile(
                      icon: Icons.payment_rounded,
                      title: state.text('paymentCards'),
                      subtitle: 'Visa ending in 4242',
                      onTap: () {},
                    ),
                    _buildDivider(isDark),

                    _buildMenuTile(
                      icon: Icons.help_outline_rounded,
                      title: state.text('helpSupport'),
                      subtitle: 'FAQs, Live Chat, Contact us',
                      onTap: () {},
                    ),
                    _buildDivider(isDark),

                    _buildMenuTile(
                      icon: Icons.settings_rounded,
                      title: state.text('profileSettings'),
                      subtitle: 'Display, language, and preferences',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(state: state),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logout Button
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF7675),
                ),
                label: Text(
                  state.text('logOut'),
                  style: TextStyle(
                    color: Color(0xFFFF7675),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Color(0xFFFF7675), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF6C5CE7),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 76,
      endIndent: 16,
      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF6C5CE7)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }
}
