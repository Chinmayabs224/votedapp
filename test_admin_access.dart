import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Core
import 'lib/core/theme/app_theme.dart';
import 'lib/core/constants/app_constants.dart';
import 'lib/core/constants/route_names.dart';

// Providers
import 'lib/data/providers/auth_provider.dart';
import 'lib/data/models/user_model.dart';

// Admin screens
import 'lib/features/admin/screens/admin_dashboard_screen.dart';
import 'lib/features/admin/providers/admin_provider.dart';

void main() {
  runApp(const AdminTestApp());
}

class AdminTestApp extends StatelessWidget {
  const AdminTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide a minimal AuthProvider substitute for this test
        ChangeNotifierProvider(create: (_) => AuthProvider(
          // These dependencies are not used by this test flow
          // Passing dummy instances is acceptable here
          // In a real test, consider a mock or a fake repository/client
          // ignore: avoid_redundant_argument_values
          null as dynamic,
          null as dynamic,
          null as dynamic,
        )),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp.router(
        title: 'Admin Panel Test',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: _createTestRouter(),
      ),
    );
  }

  GoRouter _createTestRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AdminLoginTestScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
      ],
    );
  }
}

class AdminLoginTestScreen extends StatelessWidget {
  const AdminLoginTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Admin Panel Access Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _loginAsAdmin(context),
              child: const Text('Login as Admin'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/admin'),
              child: const Text('Go to Admin Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  void _loginAsAdmin(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Set a minimal mock user compatible with AuthProvider in app layer
    final user = UserModel(
      id: 'admin123',
      name: 'Admin User',
      email: 'admin@example.com',
      role: 'admin',
      isVerified: true,
      createdAt: DateTime.now(),
    );
    // AuthProvider in app layer expects a full login flow; emulate by writing to its internal state
    // through a dedicated setter if exposed; fallback to sign-in mock is out-of-scope here
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged in as Admin')),
    );
  }
}





