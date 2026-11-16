import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/glass_container.dart';
import 'auth_screen.dart';
import 'location_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Confirm Logout'),
          content: const Text(
            'Are you sure you want to log out of your CINEVERSE account?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                AuthService().logout();
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthService(),
      builder: (context, child) {
        final user = AuthService().currentUser;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Your Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account settings synced with BookMyShow theme.')),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Profile Avatar & Info (BookMyShow Styling)
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: user != null && user.avatarUrl.isNotEmpty
                              ? AppNetworkImage(
                                  imageUrl: user.avatarUrl,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppColors.surfaceLight,
                                  child: const Icon(Icons.person, size: 50, color: AppColors.textSecondary),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.name ?? 'Karthik Ramachandran',
                        style: AppTextStyles.titleLarge.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${user?.email ?? 'karthik.tn@cineverse.in'} • ${user?.city ?? 'Chennai'}, Tamil Nadu',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      // CinePass VIP Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, size: 16, color: AppColors.gold),
                            const SizedBox(width: 6),
                            Text(
                              user?.tier ?? 'CinePass VIP Thalaivar',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Kollywood Stats Row
                Row(
                  children: [
                    _buildStatCard('Movies Watched', '${user?.moviesWatched ?? 18}', Icons.movie_outlined),
                    const SizedBox(width: 10),
                    _buildStatCard('CinePoints', '${user?.loyaltyPoints ?? 650}', Icons.monetization_on_outlined),
                    const SizedBox(width: 10),
                    _buildStatCard('Saved Theatres', '${user?.savedSeats ?? 5}', Icons.theater_comedy_outlined),
                  ],
                ),

                const SizedBox(height: 24),

                // Menu Options (BookMyShow Style)
                GlassContainer(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      _buildMenuTile(
                        icon: Icons.location_city_rounded,
                        title: 'Tamil Nadu Theatres & City',
                        subtitle: 'Currently set to ${user?.city ?? 'Chennai'}',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LocationScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1, color: AppColors.surfaceBorder),
                      _buildMenuTile(
                        icon: Icons.credit_card_rounded,
                        title: 'Saved Payment Methods',
                        subtitle: 'RuPay Platinum, GPay UPI, PhonePe',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Default payment: RuPay Platinum ending 8219')),
                          );
                        },
                      ),
                      const Divider(height: 1, color: AppColors.surfaceBorder),
                      _buildMenuTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Movie Release Notifications',
                        subtitle: 'Kollywood first-day-first-show reminders',
                        trailing: Switch(
                          value: true,
                          activeColor: AppColors.primary,
                          onChanged: (val) {},
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceBorder),
                      _buildMenuTile(
                        icon: Icons.palette_outlined,
                        title: 'Theme Style',
                        subtitle: 'BookMyShow Red & White Edition',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'Active',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceBorder),
                      _buildMenuTile(
                        icon: Icons.support_agent_rounded,
                        title: 'Help Centre & Cancellation',
                        subtitle: '24/7 customer support & instant refunds',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('CINEVERSE support: support@cineverse.in / 1800-425-BOOK')),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Logout Button
                InkWell(
                  onTap: () => _confirmLogout(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Log Out of CINEVERSE',
                          style: AppTextStyles.button.copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 13.5)),
        subtitle: Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
        trailing: trailing ??
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
