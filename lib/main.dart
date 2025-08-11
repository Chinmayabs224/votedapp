import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/service_locator.dart';

// Providers
import 'data/providers/auth_provider.dart';
import 'data/providers/election_provider.dart' as data_election;
import 'data/providers/results_provider.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/voting/providers/election_provider.dart';
import 'features/keys/providers/blockchain_key_provider.dart';

// Navigation
import 'presentation/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator
  await serviceLocator.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => serviceLocator.get<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => serviceLocator.get<data_election.ElectionProvider>()),
        ChangeNotifierProvider(create: (_) => serviceLocator.get<ResultsProvider>()),
        ChangeNotifierProvider(create: (_) => serviceLocator.get<AdminProvider>()),
        ChangeNotifierProvider(create: (_) => ElectionProvider()),
        ChangeNotifierProvider(create: (_) => BlockchainKeyProvider()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.createRouter(),
      ),
    );
  }
}
