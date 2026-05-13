import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

// Qism kategoriyasi bo'yicha qayerda ishlatilishi
const Map<String, List<String>> categoryUsages = {
  'Dvigatel': [
    'Dvigatel yog\'ini almashtirish vaqtida',
    'Dvigatel ta\'mirlash paytida',
    'Texnik ko\'rik o\'tkazishda',
  ],
  'Tormoz': [
    'Tormoz tizimini tekshirishda',
    'Tormoz kolodkalarini almashtirishda',
    'Xavfsizlik tekshiruvida',
  ],
  'Osma': [
    'Yo\'l sifati yomon bo\'lganda tekshirishda',
    'Amortizator almashtirishda',
    'Texnik ko\'rikda',
  ],
  'Elektr': [
    'Elektr tizimi nosozligida',
    'Akkumulator tekshirishda',
    'Diagnostika o\'tkazishda',
  ],
  'Kuzov': [
    'Kuzov ta\'mirlashda',
    'Bo\'yash ishlarida',
    'Avariyadan keyin ta\'mirlashda',
  ],
  'Transmissiya': [
    'Moy almashtirish paytida',
    'Uzatmalar qutisi ta\'mirlashda',
    'Texnik ko\'rikda',
  ],
  'Sovutish': [
    'Dvigatel qizib ketganda',
    'Antifriz almashtirishda',
    'Yozgi mavsumda tekshirishda',
  ],
  'Egzoz': [
    'Egzoz tizimi tekshirishda',
    'Shovqin ko\'paysa',
    'Texnik ko\'rikda',
  ],
  'Yoqilgi': [
    'Yoqilgi tizimi ta\'mirlashda',
    'Filtr almashtirishda',
    'Iqtisodiyot muammolarida',
  ],
  'Tyuning': [
    'Avtomobil kuchini oshirishda',
    'Tashqi ko\'rinishni yaxshilashda',
    'Sport haydashga tayyorlashda',
  ],
  'Salon': [
    'Salon ta\'mirlashda',
    'Aksessuarlar o\'rnatishda',
    'Qulaylikni oshirishda',
  ],
  'Boyoq': [
    'Kuzov bo\'yashda',
    'Qoplama qo\'yishda',
    'Tonirovka qilishda',
  ],
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
    final confidence =
        (result['confidence_score'] as num?)?.toDouble() ?? 0.0;
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
            // Asosiy karta
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
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
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.build,
                            color: AppTheme.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result['part_name'] ?? 'Noma\'lum qism',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (category.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Tavsif',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    result['description'] ?? 'Tavsif mavjud emas',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: confidence,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(
                                _confidenceColor(confidence)),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$percent%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _confidenceColor(confidence),
                              )),
                          Text(_confidenceText(confidence),
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Qayerda ishlatilishi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppTheme.primary, size: 18),
                      SizedBox(width: 8),
                      Text('Qayerda ishlatiladi',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...usages.map((u) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle,
                                size: 16, color: AppTheme.secondary),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(u,
                                    style: const TextStyle(
                                        fontSize: 13, height: 1.4))),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tugmalar
            ElevatedButton.icon(
              onPressed: () =>
                  context.go('/stores'),
              icon: const Icon(Icons.search),
              label: const Text('Do\'konlarda qidirish'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => context.go('/map'),
              icon: const Icon(Icons.map_outlined),
              label: const Text('Yaqin do\'konlarni topish'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Boshqa qismni skanerlash'),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
