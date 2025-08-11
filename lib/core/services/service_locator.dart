import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/api_service.dart';
import '../constants/app_constants.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/election_repository.dart';
import '../../data/repositories/voting_repository.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/election_provider.dart' as data_election;
import '../../data/providers/results_provider.dart';
import '../../features/admin/providers/admin_provider.dart';

/// Service locator for dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};
  bool _isInitialized = false;

  /// Initialize all services
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _registerSingleton<SharedPreferences>(prefs);

    // Initialize network layer
    _initializeNetworkLayer();

    // Initialize repositories
    _initializeRepositories();

    // Initialize providers
    _initializeProviders();

    _isInitialized = true;
  }

  /// Initialize network layer
  void _initializeNetworkLayer() {
    // Create Dio instance
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      sendTimeout: AppConstants.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _registerSingleton<Dio>(dio);

    // Create API client
    final apiClient = ApiClient();
    _registerSingleton<ApiClient>(apiClient);

    // Create API service - Force mock for development
    final apiService = MockApiService();
    _registerSingleton<ApiService>(apiService);
  }

  /// Initialize repositories
  void _initializeRepositories() {
    final apiService = get<ApiService>();

    _registerSingleton<AuthRepository>(AuthRepository(apiService));
    _registerSingleton<ElectionRepository>(ElectionRepository(apiService));
    _registerSingleton<VotingRepository>(VotingRepository(apiService));
  }

  /// Initialize providers
  void _initializeProviders() {
    final authRepository = get<AuthRepository>();
    final electionRepository = get<ElectionRepository>();
    final votingRepository = get<VotingRepository>();
    final prefs = get<SharedPreferences>();
    final apiClient = get<ApiClient>();

    _registerSingleton<AuthProvider>(
      AuthProvider(authRepository, prefs, apiClient),
    );
    _registerSingleton<data_election.ElectionProvider>(
      data_election.ElectionProvider(electionRepository),
    );
    _registerSingleton<ResultsProvider>(
      ResultsProvider(votingRepository),
    );
    _registerSingleton<AdminProvider>(
      AdminProvider(),
    );
  }

  /// Register a singleton service
  void _registerSingleton<T>(T service) {
    _services[T] = service;
  }

  /// Register a factory service
  void _registerFactory<T>(T Function() factory) {
    _services[T] = factory;
  }

  /// Get a service by type
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T is not registered');
    }
    
    if (service is T Function()) {
      return service();
    }
    
    return service as T;
  }

  /// Check if a service is registered
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Reset all services (useful for testing)
  void reset() {
    _services.clear();
    _isInitialized = false;
  }

  /// Register test services (for testing)
  Future<void> registerTestServices() async {
    // Register mock services for testing
    _registerSingleton<ApiService>(MockApiService());
    _registerSingleton<ApiClient>(ApiClient());
    final prefs = await SharedPreferences.getInstance();
    _registerSingleton<SharedPreferences>(prefs);
    _registerSingleton<AuthRepository>(AuthRepository(get<ApiService>()));
    _registerSingleton<AuthProvider>(AuthProvider(get<AuthRepository>(), get<SharedPreferences>(), get<ApiClient>()));
    
    // You can add more test-specific services here
  }
}

/// Extension for easy access to service locator
extension ServiceLocatorExtension on Object {
  T getService<T>() => ServiceLocator().get<T>();
}

/// Global service locator instance
final serviceLocator = ServiceLocator();

/// Convenience getters for commonly used services
AuthProvider get authProvider => serviceLocator.get<AuthProvider>();
data_election.ElectionProvider get electionProvider => serviceLocator.get<data_election.ElectionProvider>();
ResultsProvider get resultsProvider => serviceLocator.get<ResultsProvider>();
ApiClient get apiClient => serviceLocator.get<ApiClient>();
SharedPreferences get sharedPreferences => serviceLocator.get<SharedPreferences>();
