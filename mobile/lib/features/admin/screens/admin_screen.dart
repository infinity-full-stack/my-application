import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});
  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _stats;
  List<dynamic> _pendingStores = [];
  List<dynamic> _users = [];
  bool _loadingStats = true;
  bool _loadingStores = true;
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    _loadStats();
    _loadPendingStores();
    _loadUsers();
  }

  Future<void> _loadStats() async {
    try {
      final d = await ApiClient.instance.getAdminDashboard();
      if (mounted) setState(() { _stats = d; _loadingStats = false; });
    } catch (_) { if (mounted) setState(() => _loadingStats = false); }
  }

  Future<void> _loadPendingStores() async {
    try {
      final d = await ApiClient.instance.getPendingStores();
      if (mounted) setState(() { _pendingStores = d; _loadingStores = false; });
    } catch (_) { if (mounted) setState(() => _loadingStores = false); }
  }

  Future<void> _loadUsers() async {
    try {
      final d = await ApiClient.instance.getAdminUsers();
      if (mounted) setState(() { _users = d; _loadingUsers = false; });
    } catch (_) { if (mounted) setState(() => _loadingUsers = false); }
  }

  Future<void> _approve(int id, String name) async {
    try {
      await ApiClient.instance.approveStore(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ "$name" tasdiqlandi'),
          backgroundColor: AppTheme.secondary,
        ));
        _loadPendingStores();
        _loadStats();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Xatolik: $e'),
          backgroundColor: AppTheme.error,
        ));
      }
    }
  }

  Future<void> _reject(int id, String name) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rad etish', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('"$name" so\'rovini rad etasizmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Bekor')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rad etish',
                style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await ApiClient.instance.rejectStore(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❌ "$name" rad etildi'),
          backgroundColor: AppTheme.error,
        ));
        _loadPendingStores();
        _loadStats();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final txt = Theme.of(context).colorScheme.onSurface;
    final pendingCount = _pendingStores.length;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text('Admin Panel',
            style: TextStyle(fontWeight: FontWeight.w700, color: txt)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Dashboard'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('So\'rovlar'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$pendingCount',
                          style: const TextStyle(color: Colors.white,
                              fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Foydalanuvchilar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(isDark),
          _buildPending(isDark),
          _buildUsers(isDark),
        ],
      ),
    );
  }

  Widget _buildDashboard(bool isDark) {
    if (_loadingStats) return const Center(child: CircularProgressIndicator());
    if (_stats == null) return const Center(child: Text('Ma\'lumot yo\'q'));

    final surf = Theme.of(context).colorScheme.surface;
    final brd = isDark ? AppTheme.darkBorder : AppTheme.border;
    final txtSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;

    final items = [
      {'label': 'Foydalanuvchilar', 'value': '${_stats!['total_users']}',
        'icon': Icons.people_rounded, 'gradient': AppTheme.primaryGradientVertical},
      {'label': 'Jami do\'konlar', 'value': '${_stats!['total_stores']}',
        'icon': Icons.store_rounded, 'gradient': AppTheme.emeraldGradient},
      {'label': 'Tasdiqlangan', 'value': '${_stats!['verified_stores']}',
        'icon': Icons.verified_rounded, 'gradient': AppTheme.emeraldGradient},
      {'label': 'Kutilmoqda', 'value': '${_stats!['pending_stores']}',
        'icon': Icons.pending_rounded, 'gradient': AppTheme.amberGradient},
      {'label': 'Skanerlar', 'value': '${_stats!['total_scans']}',
        'icon': Icons.document_scanner_rounded, 'gradient': AppTheme.cyanGradient},
      {'label': 'Qismlar', 'value': '${_stats!['total_parts']}',
        'icon': Icons.build_rounded, 'gradient': const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)])},
    ];

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12,
          mainAxisSpacing: 12, childAspectRatio: 1.3,
        ),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final item = items[i];
          final gradient = item['gradient'] as LinearGradient;
          final color = gradient.colors.first;
          return Container(
            decoration: BoxDecoration(
              color: surf,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: brd),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconBox(icon: item['icon'] as IconData,
                    gradient: gradient, size: 38, iconSize: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['value'] as String,
                        style: TextStyle(fontSize: 28,
                            fontWeight: FontWeight.w800, color: color)),
                    Text(item['label'] as String,
                        style: TextStyle(fontSize: 11, color: txtSec)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPending(bool isDark) {
    if (_loadingStores) return const Center(child: CircularProgressIndicator());
    final surf = Theme.of(context).colorScheme.surface;
    final txt = Theme.of(context).colorScheme.onSurface;
    final txtSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    final brd = isDark ? AppTheme.darkBorder : AppTheme.border;

    if (_pendingStores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 64, color: AppTheme.secondary),
            const SizedBox(height: 12),
            Text('Kutilayotgan so\'rovlar yo\'q',
                style: TextStyle(color: txtSec)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingStores,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingStores.length,
        itemBuilder: (ctx, i) {
          final s = _pendingStores[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surf,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: brd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBox(icon: Icons.store_rounded,
                        gradient: AppTheme.primaryGradientVertical,
                        size: 42, iconSize: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s['name'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.w700,
                              fontSize: 15, color: txt)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _infoRow(Icons.category_rounded, s['store_type'] ?? '', txtSec),
                _infoRow(Icons.location_on_rounded, s['address'] ?? '', txtSec),
                _infoRow(Icons.phone_rounded, s['phone'] ?? '', txtSec),
                if (s['applicant_name'] != null)
                  _infoRow(Icons.person_rounded,
                      '${s['applicant_name']} • ${s['applicant_email']}', txtSec),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _reject(s['id'], s['name']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.error.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded,
                                  color: AppTheme.error, size: 16),
                              SizedBox(width: 6),
                              Text('Rad etish',
                                  style: TextStyle(color: AppTheme.error,
                                      fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _approve(s['id'], s['name']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: AppTheme.emeraldGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('Tasdiqlash',
                                  style: TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsers(bool isDark) {
    if (_loadingUsers) return const Center(child: CircularProgressIndicator());
    final surf = Theme.of(context).colorScheme.surface;
    final txt = Theme.of(context).colorScheme.onSurface;
    final txtSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    final brd = isDark ? AppTheme.darkBorder : AppTheme.border;

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (ctx, i) {
          final u = _users[i];
          final role = u['role'] as String? ?? 'user';
          final color = role == 'admin' ? AppTheme.error
              : role == 'store_owner' ? AppTheme.secondary : AppTheme.primary;
          final roleLabel = role == 'admin' ? 'Admin'
              : role == 'store_owner' ? 'Do\'kon egasi' : 'Foydalanuvchi';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surf,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: brd),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradientVertical,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      (u['name'] as String? ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u['name'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.w600, color: txt)),
                      Text(u['email'] ?? '',
                          style: TextStyle(fontSize: 12, color: txtSec)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(roleLabel,
                      style: TextStyle(color: color, fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color txtSec) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Icon(icon, size: 13, color: txtSec),
        const SizedBox(width: 6),
        Expanded(child: Text(text,
            style: TextStyle(fontSize: 12, color: txtSec))),
      ],
    ),
  );
}
