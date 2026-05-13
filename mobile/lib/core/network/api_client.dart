import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  // ── Auth ──────────────────────────────────────────
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/auth/register', data: data);
    return res.data;
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    final res = await _dio.post('/api/auth/verify-email',
        data: {'email': email, 'code': code});
    return res.data;
  }

  Future<void> resendCode(String email) async {
    await _dio.post('/api/auth/resend-code', data: {'email': email});
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/auth/login', data: data);
    return res.data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/api/auth/me');
    return res.data;
  }

  // ── Scan ──────────────────────────────────────────
  Future<Map<String, dynamic>> scanPart(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.post('/api/scan/', data: formData);
    return res.data;
  }

  Future<List<dynamic>> getScanHistory() async {
    final res = await _dio.get('/api/scan/history');
    return res.data;
  }

  // ── Stores ────────────────────────────────────────
  Future<List<dynamic>> getStores({int skip = 0, int limit = 50}) async {
    final res = await _dio.get('/api/stores/',
        queryParameters: {'skip': skip, 'limit': limit});
    return res.data;
  }

  Future<Map<String, dynamic>> getStore(int id) async {
    final res = await _dio.get('/api/stores/$id');
    return res.data;
  }

  Future<Map<String, dynamic>> requestStore(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/stores/request', data: data);
    return res.data;
  }

  Future<Map<String, dynamic>> createStore(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/stores/', data: data);
    return res.data;
  }

  // ── Parts ─────────────────────────────────────────
  Future<List<dynamic>> getParts(
      {String search = '', String category = ''}) async {
    final res = await _dio.get('/api/parts/', queryParameters: {
      'search': search,
      'category': category,
    });
    return res.data;
  }

  Future<List<dynamic>> getPartPrices(int partId) async {
    final res = await _dio.get('/api/parts/$partId/prices');
    return res.data;
  }

  // ── Maps ──────────────────────────────────────────
  Future<Map<String, dynamic>> getNearbyStores(double lat, double lng) async {
    final res = await _dio.get('/api/maps/nearby',
        queryParameters: {'lat': lat, 'lng': lng});
    return res.data;
  }

  // ── Admin ─────────────────────────────────────────
  Future<Map<String, dynamic>> getAdminDashboard() async {
    final res = await _dio.get('/api/admin/dashboard');
    return res.data;
  }

  Future<List<dynamic>> getPendingStores() async {
    final res = await _dio.get('/api/admin/stores/pending');
    return res.data;
  }

  Future<void> approveStore(int id) async {
    await _dio.put('/api/admin/stores/$id/approve');
  }

  Future<void> rejectStore(int id) async {
    await _dio.put('/api/admin/stores/$id/reject');
  }

  Future<List<dynamic>> getAdminUsers() async {
    final res = await _dio.get('/api/admin/users');
    return res.data;
  }

  // ── Token ─────────────────────────────────────────
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }
}
