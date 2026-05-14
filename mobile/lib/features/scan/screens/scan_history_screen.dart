import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});
  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  List<dynamic> _scans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.getScanHistory();
      setState(() { _scans = data; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txtSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Skaner tarixi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 64, color: txtSec),
                      const SizedBox(height: 16),
                      Text('Hali skanerlangan qismlar yo\'q',
                          style: TextStyle(color: txtSec)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _scans.length,
                    itemBuilder: (ctx, i) => _ScanCard(scan: _scans[i]),
                  ),
                ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final Map<String, dynamic> scan;
  const _ScanCard({required this.scan});

  Color _confidenceColor(double score) {
    if (score >= 0.8) return AppTheme.secondary;
    if (score >= 0.5) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surf = Theme.of(context).colorScheme.surface;
    final txt = Theme.of(context).colorScheme.onSurface;
    final txtSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
    final brd = isDark ? AppTheme.darkBorder : AppTheme.border;

    final confidence = (scan['confidence_score'] as num?)?.toDouble() ?? 0.0;
    final percent = (confidence * 100).toStringAsFixed(0);
    final createdAt = scan['created_at'] != null
        ? DateFormat('dd.MM.yyyy HH:mm')
            .format(DateTime.parse(scan['created_at']).toLocal())
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brd),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradientVertical,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.build_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scan['part_name'] ?? 'Noma\'lum qism',
                        style: TextStyle(fontWeight: FontWeight.w700,
                            fontSize: 15, color: txt)),
                    if (scan['category'] != null)
                      Text(scan['category'],
                          style: const TextStyle(
                              color: AppTheme.primary, fontSize: 12,
                              fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _confidenceColor(confidence).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$percent%', style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _confidenceColor(confidence), fontSize: 13)),
              ),
            ],
          ),
          if (scan['description'] != null) ...[
            const SizedBox(height: 10),
            Text(scan['description'],
                style: TextStyle(color: txtSec, fontSize: 13, height: 1.4)),
          ],
          const SizedBox(height: 10),
          Divider(height: 1, color: brd),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 13, color: txtSec),
              const SizedBox(width: 4),
              Text(createdAt, style: TextStyle(fontSize: 12, color: txtSec)),
            ],
          ),
        ],
      ),
    );
  }
}
