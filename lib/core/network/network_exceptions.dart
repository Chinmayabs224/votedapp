import 'package:dio/dio.dart';

/// Network exception handling for the Bockvote application
class NetworkExceptions implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic data;

  const NetworkExceptions({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.data,
  });

  /// Create NetworkException from DioException
  factory NetworkExceptions.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkExceptions(
          message: 'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return const NetworkExceptions(
          message: 'Send timeout. Please try again.',
        );
      case DioExceptionType.receiveTimeout:
        return const NetworkExceptions(
          message: 'Receive timeout. Please try again.',
        );
      case DioExceptionType.badCertificate:
        return const NetworkExceptions(
          message: 'Bad certificate. Please check your connection security.',
        );
      case DioExceptionType.badResponse:
        return NetworkExceptions._handleBadResponse(dioException);
      case DioExceptionType.cancel:
        return const NetworkExceptions(
          message: 'Request was cancelled.',
        );
      case DioExceptionType.connectionError:
        return const NetworkExceptions(
          message: 'Connection error. Please check your internet connection.',
        );
      case DioExceptionType.unknown:
        return NetworkExceptions(
          message: 'Unknown error occurred: ${dioException.message}',
        );
    }
  }

  /// Handle bad response errors
  static NetworkExceptions _handleBadResponse(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final data = dioException.response?.data;
    
    switch (statusCode) {
      case 400:
        return NetworkExceptions(
          message: _extractErrorMessage(data) ?? 'Bad request.',
          statusCode: statusCode,
          data: data,
        );
      case 401:
        return NetworkExceptions(
          message: _extractErrorMessage(data) ?? 'Unauthorized. Please login again.',
          statusCode: statusCode,
          data: data,
        );
      case 403:
        return NetworkExceptions(
          message: _extractErrorMessage(data) ?? 'Forbidden. You don\'t have permission.',
          statusCode: statusCode,
          data: data,
        );
      case 404:
        return NetworkExceptions(
          message: _extractErrorMessage(data) ?? 'Resource not found.',
          statusCode: statusCode,
          data: data,
        );
      case 409:
        return NetworkExceptions(
          message: _extractErrorMessage(data) ?? 'Conflict. Resource already exists.',
          statusCode: statusCode,
          data: data,
        );
      case 422:
        return NetworkExceptions(
          message: _extractErrorMessage(data) ?? 'Validation error.',
          statusCode: statusCode,
          data: data,
        );
      case 429:
        return NetworkExceptions(
          message: _extractErrorMessage(data) ?? 'Too many requests. Please try again later.',
          statusCode: statusCode,
          data: data,
        );
      case 500:
        return NetworkExceptions(
          message: _extractErrorMessage(data) ?? 'Internal server error.',
          statusCode: statusCode,
          data: data,
        );
      case 502:
        return NetworkExceptions(
          message: _extractErrorMessage(data) ?? 'Bad gateway.',
          statusCode: statusCode,
          data: data,
        );
      case 503:
        return NetworkExceptions(
          message: _extractErrorMessage(data) ?? 'Service unavailable.',
          statusCode: statusCode,
          data: data,
        );
      default:
        return NetworkExceptions(
          message: _extractErrorMessage(data) ?? 'Something went wrong.',
          statusCode: statusCode,
          data: data,
        );
    }
  }

  /// Extract error message from response data
  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    
    if (data is Map<String, dynamic>) {
      // Try different common error message fields
      return data['message'] ?? 
             data['error'] ?? 
             data['detail'] ?? 
             data['msg'];
    }
    
    if (data is String) {
      return data;
    }
    
    return null;
  }

  /// Check if the error is a network connectivity issue
  bool get isNetworkError {
    return message.contains('connection') || 
           message.contains('timeout') || 
           message.contains('internet');
  }

  /// Check if the error is an authentication issue
  bool get isAuthError {
    return statusCode == 401 || statusCode == 403;
  }

  /// Check if the error is a validation issue
  bool get isValidationError {
    return statusCode == 422 || statusCode == 400;
  }

  /// Check if the error is a server issue
  bool get isServerError {
    return statusCode != null && statusCode! >= 500;
  }

  /// Get user-friendly error message
  String get userFriendlyMessage {
    if (isNetworkError) {
      return 'Please check your internet connection and try again.';
    }
    
    if (isAuthError) {
      return 'Please login again to continue.';
    }
    
    if (isServerError) {
      return 'Server is currently unavailable. Please try again later.';
    }
    
    return message;
  }

  @override
  String toString() {
    return 'NetworkException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

/// Specific exception types for common scenarios
class AuthenticationException extends NetworkExceptions {
  const AuthenticationException({
    super.message = 'Authentication failed',
    super.statusCode,
    super.data,
  });
}

class ValidationException extends NetworkExceptions {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    super.message = 'Validation failed',
    super.statusCode,
    super.data,
    this.fieldErrors,
  });
}

class ServerException extends NetworkExceptions {
  const ServerException({
    super.message = 'Server error occurred',
    super.statusCode,
    super.data,
  });
}
