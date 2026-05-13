import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

final storesProvider = FutureProvider<List<dynamic>>((ref) async {
  return ApiClient.instance.getStores();
});

const Map<String, String> _typeLabels = {
  'WORKSHOP': 'Ustaxona', 'PARTS_STORE': 'Mashina qismlari',
  'TIRE_SERVICE': 'Shina', 'BODY_SHOP': 'Kuzov', 'ELECTRONICS': 'Elektronika',
  'TUNING_SHOP': 'Tyuning', 'PAINT_SHOP': 'Bo\'yoq', 'OIL_SERVICE': 'Moy',
  'DIAGNOSTIC': 'Diagnostika', 'OTHER': 'Boshqa',
};

const Map<String, String> _catLabels = {
  'ENGINE_PARTS': 'Dvigatel', 'BODY_PARTS': 'Kuzov', 'ELECTRICAL': 'Elektr',
  'TIRES_WHEELS': 'Shina', 'INTERIOR': 'Salon', 'PAINT_COATING': 'Bo\'yoq',
  'TUNING': 'Tyuning', 'TINTING': 'Tonirovka', 'FLOOR_MATS': 'Polik',
  'OILS_FLUIDS': 'Moy', 'BRAKES': 'Tormoz', 'SUSPENSION': 'Osma',
  'GLASS': 'Shisha', 'TIRE_SERVICE': 'Shina servis', 'ENGINE_REPAIR': 'Motor',
  'CHASSIS': 'Xodovoy', 'OIL_CHANGE': 'Moy almashtirish',
  'DIAGNOSTICS': 'Diagnostika', 'WELDING': 'Payvandlash', 'OTHER': 'Boshqa',
};

class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key});
  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen> {
  String _selectedCat = '';

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(storesProvider);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text('Do\'konlar',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradientVertical,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            ),
            onPressed: () => context.push('/add-store'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                _Chip(label: 'Barchasi', selected: _selectedCat.isEmpty,
                    onTap: () => setState(() => _selectedCat = '')),
                ..._catLabels.entries.map((e) => _Chip(
                  label: e.value,
                  selected: _selectedCat == e.key,
                  onTap: () => setState(() =>
                      _selectedCat = _selectedCat == e.key ? '' : e.key),
                )),
              ],
            ),
          ),
          Expanded(
            child: storesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('Yuklab bo\'lmadi'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.refresh(storesProvider),
                      child: const Text('Qayta'),
                    ),
                  ],
                ),
              ),
              data: (stores) {
                final filtered = _selectedCat.isEmpty
                    ? stores
                    : stores.where((s) => s['category'] == _selectedCat).toList();
                if (filtered.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Do\'konlar topilmadi',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(storesProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _StoreCard(store: filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? Colors.transparent : AppTheme.border),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.white : AppTheme.textSecondary,
              fontSize: 12, fontWeight: FontWeight.w500,
            )),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final Map<String, dynamic> store;
  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    final typeLabel = _typeLabels[store['store_type']] ?? '';
    final catLabel = _catLabels[store['category']] ?? '';

    return GestureDetector(
      onTap: () => context.push('/stores/${store['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradientVertical,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.storefront_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(store['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w700,
                                fontSize: 15, color: AppTheme.textPrimary)),
                      ),
                      if (store['verified'] == true)
                        const Icon(Icons.verified_rounded,
                            color: AppTheme.secondary, size: 16),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _badge(typeLabel, AppTheme.primary),
                      const SizedBox(width: 6),
                      _badge(catLabel, AppTheme.secondary),
                    ],
                  ),
                  if (store['address'] != null) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(store['address'],
                              style: const TextStyle(fontSize: 12,
                                  color: AppTheme.textSecondary),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
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

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(text, style: TextStyle(fontSize: 11,
        color: color, fontWeight: FontWeight.w600)),
  );
}
