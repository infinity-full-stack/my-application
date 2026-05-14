import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});
  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _picker = ImagePicker();
  bool _isScanning = false;
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1024);
    if (picked == null) return;
    setState(() => _selectedImage = File(picked.path));
  }

  Future<void> _scan() async {
    if (_selectedImage == null) return;
    setState(() => _isScanning = true);
    try {
      final result = await ApiClient.instance.scanPart(_selectedImage!.path);
      if (mounted) {
        context.push('/scan-result', extra: result);
        setState(() => _selectedImage = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Xatolik: ${e.toString()}'),
          backgroundColor: AppTheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
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
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradientVertical,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8, offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.document_scanner_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Skaner',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                        color: txt, letterSpacing: -0.3)),
                Text('Qismni aniqlang',
                    style: TextStyle(fontSize: 11, color: txtSec)),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: brd),
            ),
            child: IconButton(
              icon: Icon(Icons.history_rounded, color: txtSec, size: 20),
              onPressed: () => context.push('/scan-history'),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Hero Banner ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradientVertical,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 20, offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI bilan qism aniqlang',
                            style: TextStyle(color: Colors.white, fontSize: 18,
                                fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                        const SizedBox(height: 6),
                        Text('Avtomobil ehtiyot qismining rasmini oling\nva AI uni bir zumda aniqlaydi',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12, height: 1.5)),
                      ],
                    ),
                  ),
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Pick Cards ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _PickCard(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  subtitle: 'Rasm olish',
                  gradient: AppTheme.primaryGradientVertical,
                  surf: surf, brd: brd, txt: txt, txtSec: txtSec,
                  onTap: () => _pickImage(ImageSource.camera),
                )),
                const SizedBox(width: 12),
                Expanded(child: _PickCard(
                  icon: Icons.photo_library_rounded,
                  label: 'Galereya',
                  subtitle: 'Rasmdan tanlash',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  surf: surf, brd: brd, txt: txt, txtSec: txtSec,
                  onTap: () => _pickImage(ImageSource.gallery),
                )),
              ],
            ),
            const SizedBox(height: 16),

            // ── Selected Image ───────────────────────────────────────────
            if (_selectedImage != null) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.4), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      blurRadius: 16, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_selectedImage!,
                      height: 220, width: double.infinity,
                      fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),
              GradientButton(
                text: _isScanning ? 'Aniqlanmoqda...' : 'Qismni aniqlash',
                icon: Icons.auto_awesome_rounded,
                onPressed: _isScanning ? null : _scan,
                isLoading: _isScanning,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(() => _selectedImage = null),
                icon: Icon(Icons.close_rounded, size: 16, color: txtSec),
                label: Text('Bekor qilish',
                    style: TextStyle(color: txtSec, fontSize: 13)),
              ),
            ],

            // ── Tips ─────────────────────────────────────────────────────
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.warning.withValues(alpha: 0.08)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.warning.withValues(alpha: isDark ? 0.2 : 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          gradient: AppTheme.amberGradient,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.lightbulb_rounded,
                            color: Colors.white, size: 17),
                      ),
                      const SizedBox(width: 10),
                      Text('Maslahatlar',
                          style: TextStyle(fontWeight: FontWeight.w700,
                              color: txt, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _tip('Rasmni yorug\' joyda oling', isDark),
                  _tip('Qismni yaqindan suratga oling', isDark),
                  _tip('Qismning barchasini ko\'rsating', isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _tip(String text, bool isDark) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        Container(
          width: 6, height: 6,
          decoration: const BoxDecoration(
            color: AppTheme.warning,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppTheme.warning.withValues(alpha: 0.9)
                : const Color(0xFF92400E))),
      ],
    ),
  );
}

class _PickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final Color surf, brd, txt, txtSec;

  const _PickCard({
    required this.icon, required this.label, required this.subtitle,
    required this.gradient, required this.onTap,
    required this.surf, required this.brd,
    required this.txt, required this.txtSec,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: surf,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: brd),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.08),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 12, offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700,
                fontSize: 14, color: txt)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, color: txtSec)),
          ],
        ),
      ),
    );
  }
}
