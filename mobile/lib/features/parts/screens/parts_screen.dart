import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

const Map<String, String> _catLabels = {
  'ENGINE_PARTS': 'Dvigatel', 'BODY_PARTS': 'Kuzov', 'ELECTRICAL': 'Elektr',
  'TIRES_WHEELS': 'Shina', 'INTERIOR': 'Salon', 'PAINT_COATING': 'Bo\'yoq',
  'TUNING': 'Tyuning', 'TINTING': 'Tonirovka', 'FLOOR_MATS': 'Polik',
  'OILS_FLUIDS': 'Moy', 'BRAKES': 'Tormoz', 'SUSPENSION': 'Osma',
  'GLASS': 'Shisha', 'TIRE_SERVICE': 'Shina servis', 'ENGINE_REPAIR': 'Motor',
  'CHASSIS': 'Xodovoy', 'OIL_CHANGE': 'Moy almashtirish',
  'DIAGNOSTICS': 'Diagnostika', 'WELDING': 'Payvandlash', 'OTHER': 'Boshqa',
};

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});
  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _selectedCat = '';
  List<dynamic> _stores = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiClient.instance.getStores(limit: 100);
      setState(() { _stores = data; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filtered {
    var list = _stores;
    if (_selectedCat.isNotEmpty) {
      list = list.where((s) => s['category'] == _selectedCat).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((s) {
        final name = (s['name'] ?? '').toString().toLowerCase();
        final cat = _catLabels[s['category']] ?? '';
        return name.contains(q) || cat.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text('Qidiruv',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Do\'kon nomi yoki manzilini kiriting...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.textSecondary),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        })
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text('Do\'kon topilmadi',
                                style: TextStyle(color: AppTheme.textSecondary)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) =>
                              _StoreCard(store: _filtered[i]),
                        ),
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
    final catLabel = _catLabels[store['category']] ?? '';
    return GestureDetector(
      onTap: () => context.push('/stores/${store['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradientVertical,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.storefront_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w700,
                          fontSize: 14, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(catLabel,
                        style: const TextStyle(fontSize: 11,
                            color: AppTheme.secondary, fontWeight: FontWeight.w600)),
                  ),
                  if (store['address'] != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 11, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(store['address'],
                              style: const TextStyle(fontSize: 11,
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
}
