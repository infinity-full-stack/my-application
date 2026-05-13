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
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradientVertical,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.document_scanner_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Skaner',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                Text('Qismni aniqlang',
                    style: TextStyle(fontSize: 11,
                        color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded,
                color: AppTheme.textSecondary),
            onPressed: () => context.push('/scan-history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI bilan qism aniqlang',
                      style: TextStyle(color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text('Avtomobil ehtiyot qismining rasmini oling\nva AI uni bir zumda aniqlaydi',
                      style: TextStyle(color: Colors.white70, fontSize: 13,
                          height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kamera / Galereya
            Row(
              children: [
                Expanded(child: _PickCard(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  gradient: AppTheme.primaryGradientVertical,
                  onTap: () => _pickImage(ImageSource.camera),
                )),
                const SizedBox(width: 12),
                Expanded(child: _PickCard(
                  icon: Icons.photo_library_rounded,
                  label: 'Galereya',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => _pickImage(ImageSource.gallery),
                )),
              ],
            ),
            const SizedBox(height: 16),

            // Tanlangan rasm
            if (_selectedImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_selectedImage!,
                    height: 220, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              GradientButton(
                text: _isScanning ? 'Aniqlanmoqda...' : 'Qismni aniqlash',
                onPressed: _isScanning ? null : _scan,
                isLoading: _isScanning,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _selectedImage = null),
                child: const Text('Bekor qilish',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ],

            // Maslahatlar
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.lightbulb_rounded,
                            color: AppTheme.warning, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text('Maslahatlar',
                          style: TextStyle(fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _tip('Rasmni yorug\' joyda oling'),
                  _tip('Qismni yaqindan suratga oling'),
                  _tip('Qismning barchasini ko\'rsating'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tip(String text) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      children: [
        const Text('• ', style: TextStyle(color: AppTheme.warning,
            fontWeight: FontWeight.w700)),
        Text(text, style: const TextStyle(fontSize: 13,
            color: Color(0xFF92400E))),
      ],
    ),
  );
}

class _PickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _PickCard({required this.icon, required this.label,
      required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600,
                fontSize: 14, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}
