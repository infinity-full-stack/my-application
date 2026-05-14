import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  bool _obscure = true;
  bool _showSavedDropdown = false;
  String? _savedEmail;
  String? _savedPass;

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus && _savedEmail != null) {
        setState(() => _showSavedDropdown = true);
      } else {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showSavedDropdown = false);
        });
      }
    });
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('last_email');
    final pass = prefs.getString('last_pass');
    if (email != null && mounted) {
      setState(() {
        _savedEmail = email;
        _savedPass = pass ?? '';
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_email', _emailCtrl.text.trim());
    await prefs.setString('last_pass', _passCtrl.text);
    final ok = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ref.read(authProvider).error ?? 'Kirish muvaffaqiyatsiz'),
        backgroundColor: AppTheme.error,
      ));
    }
  }

  void _fillSaved() {
    _emailCtrl.text = _savedEmail!;
    _passCtrl.text = _savedPass!;
    setState(() => _showSavedDropdown = false);
    _emailFocus.unfocus();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
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
                      blurRadius: 24,
                      offset: const Offset(0, 10),
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
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kirish',
                          style: TextStyle(fontSize: 22,
                              fontWeight: FontWeight.w800, color: txt)),
                      Text('Hisobingizga kiring',
                          style: TextStyle(color: txtSec, fontSize: 13)),
                      const SizedBox(height: 22),

                      // Email with saved dropdown
                      Text('Email',
                          style: TextStyle(fontWeight: FontWeight.w600,
                              fontSize: 13, color: txt)),
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          TextFormField(
                            controller: _emailCtrl,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: txt),
                            decoration: InputDecoration(
                              hintText: 'email@example.com',
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: txtSec, size: 20),
                              suffixIcon: _savedEmail != null
                                  ? Icon(Icons.expand_more_rounded,
                                      color: AppTheme.primary, size: 20)
                                  : null,
                            ),
                            validator: (v) => v == null || !v.contains('@')
                                ? 'To\'g\'ri email kiriting' : null,
                          ),
                          if (_showSavedDropdown && _savedEmail != null)
                            Positioned(
                              top: 54,
                              left: 0, right: 0,
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: surf,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withValues(alpha: 0.15),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: _fillSaved,
                                    borderRadius: BorderRadius.circular(14),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40, height: 40,
                                            decoration: BoxDecoration(
                                              gradient: AppTheme.primaryGradientVertical,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                _savedEmail![0].toUpperCase(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Saqlangan hisob',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: txtSec)),
                                                Text(_savedEmail!,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        color: txt,
                                                        fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios_rounded,
                                              size: 13, color: AppTheme.primary),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Text('Parol',
                          style: TextStyle(fontWeight: FontWeight.w600,
                              fontSize: 13, color: txt)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: TextStyle(color: txt),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: Icon(Icons.lock_outline_rounded,
                              color: txtSec, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20, color: txtSec),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'Kamida 6 ta belgi' : null,
                      ),
                      const SizedBox(height: 22),
                      GradientButton(
                        text: 'Kirish',
                        icon: Icons.login_rounded,
                        onPressed: isLoading ? null : _login,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hisobingiz yo\'qmi? ',
                      style: TextStyle(color: txtSec)),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: ShaderMask(
                      shaderCallback: (b) =>
                          AppTheme.primaryGradient.createShader(b),
                      child: const Text('Ro\'yxatdan o\'tish',
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
}
