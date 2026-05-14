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
    final theme = Theme.of(context);
    final surf = theme.colorScheme.surface;
    final txt = theme.colorScheme.onSurface;
    final txtSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    final brd = isDark ? AppTheme.darkBorder : AppTheme.border;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradientVertical,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 30,
                              fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(name, style: const TextStyle(fontSize: 22,
                      fontWeight: FontWeight.w800, color: Colors.white,
                      letterSpacing: -0.3)),
                  const SizedBox(height: 3),
                  Text(email, style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      isAdmin ? '⚡ Admin' : '👤 Foydalanuvchi',
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Admin ──────────────────────────────────────────────
                  if (isAdmin) ...[
                    SectionHeader(title: 'ADMIN'),
                    const SizedBox(height: 10),
                    _MenuItem(
                      icon: Icons.admin_panel_settings_rounded,
                      label: 'Admin Panel',
                      subtitle: 'Boshqaruv markazi',
                      gradient: AppTheme.roseGradient,
                      surf: surf, txt: txt, brd: brd,
                      onTap: () => context.push('/admin'),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Xizmatlar ──────────────────────────────────────────
                  SectionHeader(title: 'XIZMATLAR'),
                  const SizedBox(height: 10),
                  _MenuItem(
                    icon: Icons.storefront_rounded,
                    label: 'Do\'kon / Ustaxona qo\'shish',
                    subtitle: 'Yangi joyni ro\'yxatga oling',
                    gradient: AppTheme.primaryGradientVertical,
                    surf: surf, txt: txt, brd: brd,
                    onTap: () => context.push('/add-store'),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: Icons.history_rounded,
                    label: 'Skaner tarixi',
                    subtitle: 'Skanerlangan qismlar',
                    gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)]),
                    surf: surf, txt: txt, brd: brd,
                    onTap: () => context.push('/scan-history'),
                  ),
                  const SizedBox(height: 20),

                  // ── Navigatsiya ────────────────────────────────────────
                  SectionHeader(title: 'NAVIGATSIYA'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: surf,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: brd),
                    ),
                    child: Column(
                      children: [
                        _NavTile(icon: Icons.store_rounded, label: 'Do\'konlar',
                            txt: txt, txtSec: txtSec, brd: brd,
                            onTap: () => context.go('/stores')),
                        Divider(height: 1, color: brd, indent: 56),
                        _NavTile(icon: Icons.search_rounded, label: 'Ehtiyot qismlar',
                            txt: txt, txtSec: txtSec, brd: brd,
                            onTap: () => context.go('/parts')),
                        Divider(height: 1, color: brd, indent: 56),
                        _NavTile(icon: Icons.location_on_rounded, label: 'Yaqin do\'konlar',
                            txt: txt, txtSec: txtSec, brd: brd,
                            onTap: () => context.go('/map'), isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Sozlamalar ─────────────────────────────────────────
                  SectionHeader(title: 'SOZLAMALAR'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: surf,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: brd),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          gradient: AppTheme.amberGradient,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: Colors.white, size: 20,
                        ),
                      ),
                      title: Text(isDark ? 'Tungi rejim' : 'Kunduzgi rejim',
                          style: TextStyle(fontWeight: FontWeight.w600,
                              color: txt, fontSize: 14)),
                      subtitle: Text(isDark ? 'Qorong\'u ko\'rinish' : 'Yorug\' ko\'rinish',
                          style: TextStyle(color: txtSec, fontSize: 12)),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Chiqish ────────────────────────────────────────────
                  GestureDetector(
                    onTap: () => ref.read(authProvider.notifier).logout(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: isDark ? 0.12 : 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.error.withValues(alpha: 0.25)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded,
                              color: AppTheme.error, size: 18),
                          SizedBox(width: 8),
                          Text('Chiqish',
                              style: TextStyle(color: AppTheme.error,
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final Color surf, txt, brd;

  const _MenuItem({
    required this.icon, required this.label, required this.gradient,
    required this.onTap, required this.surf, required this.txt,
    required this.brd, this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surf,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brd),
        ),
        child: Row(
          children: [
            IconBox(icon: icon, gradient: gradient, size: 46, iconSize: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.w700,
                      color: txt, fontSize: 14)),
                  if (subtitle != null)
                    Text(subtitle!, style: TextStyle(fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color txt, txtSec, brd;
  final bool isLast;

  const _NavTile({
    required this.icon, required this.label, required this.onTap,
    required this.txt, required this.txtSec, required this.brd,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isLast ? 0 : 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 17),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label,
                style: TextStyle(fontWeight: FontWeight.w500,
                    color: txt, fontSize: 14))),
            Icon(Icons.arrow_forward_ios_rounded, size: 13, color: txtSec),
          ],
        ),
      ),
    );
  }
}
