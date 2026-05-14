import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ApiClient.instance.register({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'role': 'user',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ro\'yxatdan o\'tdingiz! Endi kiring.'),
          backgroundColor: AppTheme.secondary,
        ));
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().contains('400')
              ? 'Bu email allaqachon ro\'yxatdan o\'tgan'
              : 'Xatolik yuz berdi'),
          backgroundColor: AppTheme.error,
        ));
      }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 52),

              // ── Logo ──────────────────────────────────────────────────
              Container(
                width: 84, height: 84,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradientVertical,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      blurRadius: 24, offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.document_scanner_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 18),
              ShaderMask(
                shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
                child: const Text('Master Scan',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: -0.8)),
              ),
              const SizedBox(height: 4),
              Text('AI Avto Ehtiyot Qismlar Bozori',
                  style: TextStyle(color: txtSec, fontSize: 14)),
              const SizedBox(height: 36),

              // ── Form ──────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surf,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: brd),
                  boxShadow: isDark ? [] : [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.07),
                      blurRadius: 24, offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ro\'yxatdan o\'tish',
                          style: TextStyle(fontSize: 22,
                              fontWeight: FontWeight.w800, color: txt)),
                      Text('Yangi hisob yarating',
                          style: TextStyle(color: txtSec, fontSize: 13)),
                      const SizedBox(height: 22),

                      _label('To\'liq ism', txt),
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(color: txt),
                        decoration: InputDecoration(
                          hintText: 'Ismingizni kiriting',
                          prefixIcon: Icon(Icons.person_outline_rounded,
                              color: isDark ? AppTheme.darkTextSecondary
                                  : AppTheme.textSecondary, size: 20),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Majburiy' : null,
                      ),
                      const SizedBox(height: 14),

                      _label('Email', txt),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: txt),
                        decoration: InputDecoration(
                          hintText: 'email@example.com',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: isDark ? AppTheme.darkTextSecondary
                                  : AppTheme.textSecondary, size: 20),
                        ),
                        validator: (v) => v == null || !v.contains('@')
                            ? 'To\'g\'ri email kiriting' : null,
                      ),
                      const SizedBox(height: 14),

                      _label('Parol', txt),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: TextStyle(color: txt),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: Icon(Icons.lock_outline_rounded,
                              color: isDark ? AppTheme.darkTextSecondary
                                  : AppTheme.textSecondary, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: isDark ? AppTheme.darkTextSecondary
                                  : AppTheme.textSecondary),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'Kamida 6 ta belgi' : null,
                      ),
                      const SizedBox(height: 22),
                      GradientButton(
                        text: 'Ro\'yxatdan o\'tish',
                        icon: Icons.person_add_rounded,
                        onPressed: _isLoading ? null : _register,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hisobingiz bormi? ',
                      style: TextStyle(color: txtSec)),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: ShaderMask(
                      shaderCallback: (b) =>
                          AppTheme.primaryGradient.createShader(b),
                      child: const Text('Kirish',
                          style: TextStyle(fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, Color txt) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: TextStyle(fontWeight: FontWeight.w600,
            fontSize: 13, color: txt)),
  );
}
