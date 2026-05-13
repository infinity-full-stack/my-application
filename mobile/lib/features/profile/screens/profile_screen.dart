import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final role = user?['role'] as String? ?? 'user';
    final isAdmin = role.toUpperCase() == 'ADMIN';
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final name = user?['name'] as String? ?? 'Foydalanuvchi';
    final email = user?['email'] as String? ?? '';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradientVertical,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                    ),
                    child: Center(
                      child: Text(name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 28,
                              fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: const TextStyle(fontSize: 20,
                      fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(email, style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAdmin ? 'Admin' : 'Foydalanuvchi',
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin
                  if (isAdmin) ...[
                    _sectionTitle('ADMIN'),
                    _MenuItem(
                      icon: Icons.admin_panel_settings_rounded,
                      label: 'Admin Panel',
                      gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                      onTap: () => context.push('/admin'),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Xizmatlar
                  _sectionTitle('XIZMATLAR'),
                  _MenuItem(
                    icon: Icons.storefront_rounded,
                    label: 'Do\'kon / Ustaxona qo\'shish',
                    subtitle: 'Yangi joyni ro\'yxatga oling',
                    gradient: AppTheme.primaryGradientVertical,
                    onTap: () => context.push('/add-store'),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: Icons.history_rounded,
                    label: 'Skaner tarixi',
                    subtitle: 'Skanerlangan qismlar',
                    gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]),
                    onTap: () => context.push('/scan-history'),
                  ),
                  const SizedBox(height: 16),

                  // Navigatsiya
                  _sectionTitle('NAVIGATSIYA'),
                  _NavItem(
                    icon: Icons.store_rounded,
                    label: 'Do\'konlar',
                    onTap: () => context.go('/stores'),
                  ),
                  _NavItem(
                    icon: Icons.search_rounded,
                    label: 'Ehtiyot qismlar',
                    onTap: () => context.go('/parts'),
                  ),
                  _NavItem(
                    icon: Icons.location_on_rounded,
                    label: 'Yaqin do\'konlar',
                    onTap: () => context.go('/map'),
                  ),
                  const SizedBox(height: 16),

                  // Sozlamalar
                  _sectionTitle('SOZLAMALAR'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: AppTheme.warning, size: 20,
                        ),
                      ),
                      title: Text(isDark ? 'Tungi rejim' : 'Kunduzgi rejim',
                          style: const TextStyle(fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary)),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                        activeColor: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chiqish
                  GestureDetector(
                    onTap: () => ref.read(authProvider.notifier).logout(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.error.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded,
                              color: AppTheme.error, size: 18),
                          SizedBox(width: 8),
                          Text('Chiqish',
                              style: TextStyle(color: AppTheme.error,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 11,
        fontWeight: FontWeight.w700, color: AppTheme.textSecondary,
        letterSpacing: 1)),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label,
      required this.gradient, required this.onTap, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!, style: const TextStyle(fontSize: 12,
                        color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary))),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
