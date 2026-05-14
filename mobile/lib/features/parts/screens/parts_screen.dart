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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final surf = Theme.of(context).colorScheme.surface;
    final txt = Theme.of(context).colorScheme.onSurface;
    final txtSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    final brd = isDark ? AppTheme.darkBorder : AppTheme.border;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text('Qidiruv',
            style: TextStyle(fontWeight: FontWeight.w700, color: txt)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: txt),
              decoration: InputDecoration(
                hintText: 'Do\'kon nomi yoki manzilini kiriting...',
                prefixIcon: Icon(Icons.search_rounded, color: txtSec),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: txtSec),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        })
                    : null,
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
                    isDark: isDark, surf: surf, brd: brd,
                    onTap: () => setState(() => _selectedCat = '')),
                ..._catLabels.entries.map((e) => _Chip(
                  label: e.value,
                  selected: _selectedCat == e.key,
                  isDark: isDark, surf: surf, brd: brd,
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
                                size: 64, color: txtSec),
                            const SizedBox(height: 12),
                            Text('Do\'kon topilmadi',
                                style: TextStyle(color: txtSec)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) => _StoreCard(
                            store: _filtered[i],
                            isDark: isDark, surf: surf,
                            txt: txt, txtSec: txtSec, brd: brd,
                          ),
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
  final bool isDark;
  final Color surf, brd;
  final VoidCallback onTap;

  const _Chip({
    required this.label, required this.selected, required this.onTap,
    required this.isDark, required this.surf, required this.brd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : surf,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : brd),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.white
                  : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
              fontSize: 12, fontWeight: FontWeight.w500,
            )),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final Map<String, dynamic> store;
  final bool isDark;
  final Color surf, txt, txtSec, brd;

  const _StoreCard({
    required this.store, required this.isDark,
    required this.surf, required this.txt,
    required this.txtSec, required this.brd,
  });

  @override
  Widget build(BuildContext context) {
    final catLabel = _catLabels[store['category']] ?? '';
    return GestureDetector(
      onTap: () => context.push('/stores/${store['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surf,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brd),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
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
                      style: TextStyle(fontWeight: FontWeight.w700,
                          fontSize: 14, color: txt)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.12),
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
                        Icon(Icons.location_on_rounded, size: 11, color: txtSec),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(store['address'],
                              style: TextStyle(fontSize: 11, color: txtSec),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: txtSec),
          ],
        ),
      ),
    );
  }
}
