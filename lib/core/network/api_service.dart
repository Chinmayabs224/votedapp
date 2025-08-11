import 'package:dio/dio.dart';

/// API service interface for the Bockvote application
abstract class ApiService {
  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  });

  /// Set authentication token
  void setAuthToken(String token);

  /// Clear authentication token
  void clearAuthToken();
}

/// API service implementation using Dio
class DioApiService implements ApiService {
  final Dio _dio;

  DioApiService(this._dio);

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) {
    return _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      options: options,
    );
  }

  @override
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  @override
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

/// Mock API service for testing and development
class MockApiService implements ApiService {
  final Map<String, dynamic> _mockData = {};
  String? _authToken;

  MockApiService() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Initialize with mock data for development
    _mockData['elections'] = [
      {
        'id': '1',
        'title': 'Presidential Election 2024',
        'description': 'National presidential election',
        'startDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'endDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'status': 'active',
        'type': 'general',
        'candidateIds': ['1', '2', '3'],
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'createdBy': 'admin',
      },
      {
        'id': '2',
        'title': 'Local Council Election',
        'description': 'City council member election',
        'startDate': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
        'endDate': DateTime.now().add(const Duration(days: 21)).toIso8601String(),
        'status': 'scheduled',
        'type': 'local',
        'candidateIds': ['4', '5'],
        'createdAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'createdBy': 'admin',
      },
    ];

    _mockData['candidates'] = [
      {
        'id': '1',
        'name': 'John Smith',
        'party': 'Democratic Party',
        'description': 'Experienced leader with a vision for change',
        'experience': '10 years in public service',
        'education': 'Harvard Law School',
        'electionIds': ['1'],
        'status': 'active',
        'createdAt': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'userId': 'user1',
      },
      {
        'id': '2',
        'name': 'Jane Doe',
        'party': 'Republican Party',
        'description': 'Conservative values and fiscal responsibility',
        'experience': '8 years as governor',
        'education': 'Yale University',
        'electionIds': ['1'],
        'status': 'active',
        'createdAt': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'userId': 'user2',
      },
    ];

    _mockData['results'] = [
      {
        'electionId': '1',
        'electionTitle': 'Presidential Election 2024',
        'totalVotes': 1500,
        'candidateResults': [
          {
            'candidateId': '1',
            'candidateName': 'John Smith',
            'party': 'Democratic Party',
            'voteCount': 800,
            'percentage': 53.3,
          },
          {
            'candidateId': '2',
            'candidateName': 'Jane Doe',
            'party': 'Republican Party',
            'voteCount': 700,
            'percentage': 46.7,
          },
        ],
        'lastUpdated': DateTime.now().toIso8601String(),
        'isFinal': false,
      },
    ];
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    dynamic data;
    if (path.contains('/elections')) {
      data = {'elections': _mockData['elections']};
    } else if (path.contains('/candidates')) {
      data = {'candidates': _mockData['candidates']};
    } else if (path.contains('/results')) {
      data = {'results': _mockData['results']};
    } else {
      data = {};
    }

    return Response<T>(
      data: data as T,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (path.contains('/auth/login')) {
      // Extract email and password from request data
      final Map<String, dynamic> requestData = data as Map<String, dynamic>;
      final String email = requestData['email'] as String;
      final String password = requestData['password'] as String;
      
      // Check for admin credentials
      if (email == 'admin@example.com' && password == 'admin123') {
        return Response<T>(
          data: {
            'user': {
              'id': 'admin123',
              'email': 'admin@example.com',
              'name': 'Admin User',
              'role': 'admin',
              'status': 'active',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            'accessToken': 'mock_admin_access_token',
            'refreshToken': 'mock_admin_refresh_token',
            'expiresAt': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
          } as T,
          statusCode: 200,
          requestOptions: RequestOptions(path: path),
        );
      }
      
      // Regular user login (existing code)
      return Response<T>(
        data: {
          'user': {
            'id': 'user123',
            'email': 'user@example.com',
            'name': 'Test User',
            'role': 'voter',
            'status': 'active',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
          'accessToken': 'mock_access_token',
          'refreshToken': 'mock_refresh_token',
          'expiresAt': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        } as T,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }

    return Response<T>(
      data: data as T,
      statusCode: 201,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Response<T>(
      data: data as T,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Response<T>(
      data: null as T,
      statusCode: 204,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Response<T>(
      data: data as T,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return Response(
      statusCode: 200,
      requestOptions: RequestOptions(path: urlPath),
    );
  }

  @override
  void setAuthToken(String token) {
    _authToken = token;
  }

  @override
  void clearAuthToken() {
    _authToken = null;
  }
}
