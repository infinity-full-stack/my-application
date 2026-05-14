import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

const Map<String, List<String>> categoryUsages = {
  'Dvigatel': ['Dvigatel yog\'ini almashtirish vaqtida', 'Dvigatel ta\'mirlash paytida', 'Texnik ko\'rik o\'tkazishda'],
  'Tormoz': ['Tormoz tizimini tekshirishda', 'Tormoz kolodkalarini almashtirishda', 'Xavfsizlik tekshiruvida'],
  'Osma': ['Yo\'l sifati yomon bo\'lganda tekshirishda', 'Amortizator almashtirishda', 'Texnik ko\'rikda'],
  'Elektr': ['Elektr tizimi nosozligida', 'Akkumulator tekshirishda', 'Diagnostika o\'tkazishda'],
  'Kuzov': ['Kuzov ta\'mirlashda', 'Bo\'yash ishlarida', 'Avariyadan keyin ta\'mirlashda'],
  'Transmissiya': ['Moy almashtirish paytida', 'Uzatmalar qutisi ta\'mirlashda', 'Texnik ko\'rikda'],
  'Sovutish': ['Dvigatel qizib ketganda', 'Antifriz almashtirishda', 'Yozgi mavsumda tekshirishda'],
  'Egzoz': ['Egzoz tizimi tekshirishda', 'Shovqin ko\'paysa', 'Texnik ko\'rikda'],
  'Yoqilgi': ['Yoqilgi tizimi ta\'mirlashda', 'Filtr almashtirishda', 'Iqtisodiyot muammolarida'],
  'Tyuning': ['Avtomobil kuchini oshirishda', 'Tashqi ko\'rinishni yaxshilashda', 'Sport haydashga tayyorlashda'],
  'Salon': ['Salon ta\'mirlashda', 'Aksessuarlar o\'rnatishda', 'Qulaylikni oshirishda'],
  'Boyoq': ['Kuzov bo\'yashda', 'Qoplama qo\'yishda', 'Tonirovka qilishda'],
};

class ScanResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  const ScanResultScreen({super.key, required this.result});

  Color _confidenceColor(double score) {
    if (score >= 0.8) return AppTheme.secondary;
    if (score >= 0.5) return AppTheme.warning;
    return AppTheme.error;
  }

  String _confidenceText(double score) {
    if (score >= 0.8) return 'Yuqori aniqlik';
    if (score >= 0.5) return 'O\'rtacha aniqlik';
    return 'Past aniqlik';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf = Theme.of(context).colorScheme.surface;
    final txt = Theme.of(context).colorScheme.onSurface;
    final txtSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    final brd = isDark ? AppTheme.darkBorder : AppTheme.border;

    final confidence = (result['confidence_score'] as num?)?.toDouble() ?? 0.0;
    final percent = (confidence * 100).toStringAsFixed(0);
    final category = result['category'] as String? ?? '';
    final usages = categoryUsages[category] ?? [
      'Avtomobil ta\'mirlash ishlarida',
      'Texnik ko\'rik paytida',
      'Ehtiyot qism almashtirishda',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skaner natijasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Asosiy karta ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surf,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: brd),
                boxShadow: isDark ? [] : [
                  BoxShadow(color: AppTheme.primary.withValues(alpha: 0.06),
                      blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradientVertical,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.build_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(result['part_name'] ?? 'Noma\'lum qism',
                                style: TextStyle(fontSize: 20,
                                    fontWeight: FontWeight.w800, color: txt)),
                            if (category.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(category,
                                    style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Tavsif', style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13, color: txt)),
                  const SizedBox(height: 6),
                  Text(result['description'] ?? 'Tavsif mavjud emas',
                      style: TextStyle(color: txtSec, height: 1.5, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: confidence,
                            backgroundColor: isDark
                                ? AppTheme.darkBorder
                                : Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(
                                _confidenceColor(confidence)),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$percent%', style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _confidenceColor(confidence))),
                          Text(_confidenceText(confidence),
                              style: TextStyle(fontSize: 10, color: txtSec)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Qayerda ishlatiladi ───────────────────────────────────
            Container(
              width: double.infinity,
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
                      const IconBox(
                        icon: Icons.info_outline_rounded,
                        gradient: AppTheme.cyanGradient,
                        size: 32, iconSize: 16,
                      ),
                      const SizedBox(width: 10),
                      Text('Qayerda ishlatiladi',
                          style: TextStyle(fontWeight: FontWeight.w700,
                              fontSize: 14, color: txt)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...usages.map((u) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 16, color: AppTheme.secondary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(u,
                            style: TextStyle(fontSize: 13,
                                height: 1.4, color: txt))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Tugmalar ─────────────────────────────────────────────
            GradientButton(
              text: 'Do\'konlarda qidirish',
              icon: Icons.search_rounded,
              onPressed: () => context.go('/stores'),
            ),
            const SizedBox(height: 10),
            GradientButton(
              text: 'Yaqin do\'konlarni topish',
              icon: Icons.map_rounded,
              gradient: AppTheme.cyanGradient,
              onPressed: () => context.go('/map'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/'),
                icon: Icon(Icons.camera_alt_outlined, color: txtSec),
                label: Text('Boshqa qismni skanerlash',
                    style: TextStyle(color: txtSec)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: brd),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
