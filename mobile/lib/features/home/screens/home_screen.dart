import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  int _idx(String loc, bool isAdmin) {
    if (loc == '/') return 0;
    if (loc.startsWith('/stores')) return 1;
    if (loc.startsWith('/parts')) return 2;
    if (loc.startsWith('/map')) return 3;
    if (isAdmin && loc.startsWith('/admin')) return 4;
    if (loc.startsWith('/profile')) return isAdmin ? 5 : 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isAdmin = user?['role']?.toString().toUpperCase() == 'ADMIN';
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _idx(loc, isAdmin);

    final items = [
      _NavItem(icon: Icons.document_scanner_outlined,
          activeIcon: Icons.document_scanner_rounded, label: 'Skaner'),
      _NavItem(icon: Icons.store_outlined,
          activeIcon: Icons.store_rounded, label: 'Do\'konlar'),
      _NavItem(icon: Icons.search_outlined,
          activeIcon: Icons.search_rounded, label: 'Qidiruv'),
      _NavItem(icon: Icons.map_outlined,
          activeIcon: Icons.map_rounded, label: 'Xarita'),
      if (isAdmin)
        _NavItem(icon: Icons.admin_panel_settings_outlined,
            activeIcon: Icons.admin_panel_settings_rounded, label: 'Admin'),
      _NavItem(icon: Icons.person_outlined,
          activeIcon: Icons.person_rounded, label: 'Profil'),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final item = items[i];
                final selected = idx == i;
                return GestureDetector(
                  onTap: () {
                    final routes = isAdmin
                        ? ['/', '/stores', '/parts', '/map', '/admin', '/profile']
                        : ['/', '/stores', '/parts', '/map', '/profile'];
                    context.go(routes[i]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: selected ? AppTheme.primaryGradient : null,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected ? Colors.white : AppTheme.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                              color: selected ? Colors.white : AppTheme.textSecondary,
                            )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
