import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/scan/screens/scan_screen.dart';
import '../../features/scan/screens/scan_result_screen.dart';
import '../../features/scan/screens/scan_history_screen.dart';
import '../../features/stores/screens/stores_screen.dart';
import '../../features/stores/screens/store_detail_screen.dart';
import '../../features/stores/screens/add_store_screen.dart';
import '../../features/parts/screens/parts_screen.dart';
import '../../features/maps/screens/map_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/admin/screens/admin_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' ||
          loc == '/register' ||
          loc.startsWith('/verify-email');

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final email = state.extra as String;
          return VerifyEmailScreen(email: email);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const ScanScreen()),
          GoRoute(path: '/stores', builder: (_, __) => const StoresScreen()),
          GoRoute(path: '/parts', builder: (_, __) => const PartsScreen()),
          GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
          GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/scan-result',
        builder: (context, state) {
          final result = state.extra as Map<String, dynamic>;
          return ScanResultScreen(result: result);
        },
      ),
      GoRoute(
        path: '/stores/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return StoreDetailScreen(storeId: id);
        },
      ),
      GoRoute(path: '/add-store', builder: (_, __) => const AddStoreScreen()),
      GoRoute(path: '/scan-history', builder: (_, __) => const ScanHistoryScreen()),
    ],
  );
});
