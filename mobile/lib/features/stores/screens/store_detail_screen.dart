import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

class StoreDetailScreen extends StatelessWidget {
  final int storeId;
  const StoreDetailScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf = Theme.of(context).colorScheme.surface;
    final txt = Theme.of(context).colorScheme.onSurface;
    final txtSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    final brd = isDark ? AppTheme.darkBorder : AppTheme.border;

    return Scaffold(
      appBar: AppBar(title: const Text('Do\'kon ma\'lumotlari')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiClient.instance.getStore(storeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik: ${snapshot.error}',
                style: TextStyle(color: txt)));
          }
          final store = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header karta ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surf,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: brd),
                    boxShadow: isDark ? [] : [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.06),
                        blurRadius: 16, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradientVertical,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 16, offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.storefront_rounded,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(store['name'] ?? '',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 22,
                                    fontWeight: FontWeight.w800, color: txt)),
                          ),
                          if (store['verified'] == true) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.verified_rounded,
                                color: AppTheme.secondary, size: 22),
                          ],
                        ],
                      ),
                      if (store['description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(store['description'],
                            textAlign: TextAlign.center,
                            style: TextStyle(color: txtSec, height: 1.5)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Info tiles ───────────────────────────────────────
                _InfoTile(
                  icon: Icons.location_on_rounded,
                  label: 'Manzil',
                  value: store['address'] ?? 'Ko\'rsatilmagan',
                  gradient: AppTheme.primaryGradientVertical,
                  surf: surf, txt: txt, txtSec: txtSec, brd: brd,
                ),
                _InfoTile(
                  icon: Icons.phone_rounded,
                  label: 'Telefon',
                  value: store['phone'] ?? 'Ko\'rsatilmagan',
                  gradient: AppTheme.emeraldGradient,
                  surf: surf, txt: txt, txtSec: txtSec, brd: brd,
                ),
                _InfoTile(
                  icon: Icons.access_time_rounded,
                  label: 'Ish vaqti',
                  value: store['working_hours'] ?? 'Ko\'rsatilmagan',
                  gradient: AppTheme.amberGradient,
                  surf: surf, txt: txt, txtSec: txtSec, brd: brd,
                ),
                _InfoTile(
                  icon: Icons.star_rounded,
                  label: 'Reyting',
                  value: '${store['rating']?.toStringAsFixed(1) ?? '0.0'} / 5.0',
                  gradient: AppTheme.amberGradient,
                  surf: surf, txt: txt, txtSec: txtSec, brd: brd,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final LinearGradient gradient;
  final Color surf, txt, txtSec, brd;

  const _InfoTile({
    required this.icon, required this.label, required this.value,
    required this.gradient, required this.surf, required this.txt,
    required this.txtSec, required this.brd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brd),
      ),
      child: Row(
        children: [
          IconBox(icon: icon, gradient: gradient, size: 38, iconSize: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: txtSec, fontSize: 11,
                    fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontWeight: FontWeight.w600,
                    color: txt, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
