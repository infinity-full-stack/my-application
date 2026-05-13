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
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
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
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Logo
              Container(
                width: 80, height: 80,
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
                child: const Icon(Icons.document_scanner_rounded,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (b) =>
                    AppTheme.primaryGradient.createShader(b),
                child: const Text('Master Scan',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: -0.5)),
              ),
              const Text('AI Avto Ehtiyot Qismlar Bozori',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 32),

              // Form karta
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ro\'yxatdan o\'tish',
                          style: TextStyle(fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary)),
                      const Text('Yangi hisob yarating',
                          style: TextStyle(color: AppTheme.textSecondary,
                              fontSize: 13)),
                      const SizedBox(height: 20),
                      _label('To\'liq ism'),
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                            hintText: 'Ismingizni kiriting'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Majburiy' : null,
                      ),
                      const SizedBox(height: 14),
                      _label('Email'),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            hintText: 'email@example.com'),
                        validator: (v) => v == null || !v.contains('@')
                            ? 'To\'g\'ri email kiriting' : null,
                      ),
                      const SizedBox(height: 14),
                      _label('Parol'),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                                size: 20, color: AppTheme.textSecondary),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'Kamida 6 ta belgi' : null,
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        text: 'Ro\'yxatdan o\'tish',
                        onPressed: _isLoading ? null : _register,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Hisobingiz bormi? ',
                      style: TextStyle(color: AppTheme.textSecondary)),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(fontWeight: FontWeight.w600,
            fontSize: 13, color: AppTheme.textPrimary)),
  );
}
