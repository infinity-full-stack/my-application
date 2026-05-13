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
      setState(() {
        _scans = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skaner tarixi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scans.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Hali skanerlangan qismlar yo\'q',
                          style:
                              TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _scans.length,
                    itemBuilder: (context, i) =>
                        _ScanCard(scan: _scans[i]),
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
    final confidence =
        (scan['confidence_score'] as num?)?.toDouble() ?? 0.0;
    final percent = (confidence * 100).toStringAsFixed(0);
    final createdAt = scan['created_at'] != null
        ? DateFormat('dd.MM.yyyy HH:mm')
            .format(DateTime.parse(scan['created_at']).toLocal())
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.build,
                      color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan['part_name'] ?? 'Noma\'lum qism',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      if (scan['category'] != null)
                        Text(scan['category'],
                            style: const TextStyle(
                                color: AppTheme.primary, fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _confidenceColor(confidence),
                  ),
                ),
              ],
            ),
            if (scan['description'] != null) ...[
              const SizedBox(height: 10),
              Text(
                scan['description'],
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4),
              ),
            ],
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 13, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(createdAt,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
