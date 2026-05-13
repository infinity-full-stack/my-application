import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

class StoreDetailScreen extends StatelessWidget {
  final int storeId;
  const StoreDetailScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Do\'kon ma\'lumotlari')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiClient.instance.getStore(storeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik: ${snapshot.error}'));
          }
          final store = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.store,
                            color: AppTheme.primary, size: 36),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            store['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (store['verified'] == true) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.verified,
                                color: AppTheme.primary, size: 20),
                          ],
                        ],
                      ),
                      if (store['description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          store['description'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppTheme.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Manzil',
                  value: store['address'] ?? 'Ko\'rsatilmagan',
                ),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Telefon',
                  value: store['phone'] ?? 'Ko\'rsatilmagan',
                ),
                _InfoTile(
                  icon: Icons.star_outlined,
                  label: 'Reyting',
                  value:
                      '${store['rating']?.toStringAsFixed(1) ?? '0.0'} / 5.0',
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

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDADCE0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
