import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    Map<String, dynamic>? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api;

  AuthNotifier(this._api) : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _api.getToken();
    if (token != null) {
      try {
        final user = await _api.getMe();
        state = AuthState(isAuthenticated: true, user: user);
      } catch (_) {
        await _api.clearToken();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.login({'email': email, 'password': password});
      await _api.saveToken(res['access_token']);
      state = AuthState(isAuthenticated: true, user: res['user']);
      return true;
    } on DioException catch (e) {
      final msg = _parseDioError(e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Serverga ulanib bo\'lmadi');
      return false;
    }
  }

  Future<bool> register(
      String name, String email, String password, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.register({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      final msg = _parseDioError(e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Serverga ulanib bo\'lmadi');
      return false;
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    state = const AuthState();
  }

  String _parseDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Serverga ulanib bo\'lmadi. Internet yoki server tekshiring.';
    }
    final status = e.response?.statusCode;
    final detail = e.response?.data?['detail'];
    if (status == 400) return detail ?? 'Bu email allaqachon ro\'yxatdan o\'tgan';
    if (status == 401) return 'Email yoki parol noto\'g\'ri';
    if (status == 403) return detail ?? 'Emailingizni tasdiqlang';
    return detail ?? 'Xatolik yuz berdi';
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ApiClient.instance);
});
