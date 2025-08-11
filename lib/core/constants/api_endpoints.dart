/// API endpoint constants for the Bockvote application
class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://localhost:9000';
  
  // Authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  
  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  
  // Election endpoints
  static const String elections = '/elections';
  static const String electionById = '/elections/{id}';
  static const String createElection = '/elections';
  static const String updateElection = '/elections/{id}';
  static const String deleteElection = '/elections/{id}';
  static const String electionCandidates = '/elections/{id}/candidates';
  static const String electionResults = '/elections/{id}/results';
  
  // Candidate endpoints
  static const String candidates = '/candidates';
  static const String candidateById = '/candidates/{id}';
  static const String createCandidate = '/candidates';
  static const String updateCandidate = '/candidates/{id}';
  static const String deleteCandidate = '/candidates/{id}';
  
  // Voting endpoints
  static const String vote = '/vote';
  static const String voteHistory = '/vote/history';
  static const String voteVerification = '/vote/verify';
  static const String voteReceipt = '/vote/receipt/{id}';
  
  // Results endpoints
  static const String results = '/results';
  static const String resultsByElection = '/results/election/{id}';
  static const String liveResults = '/results/live/{id}';
  
  // Admin endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminElections = '/admin/elections';
  static const String adminReports = '/admin/reports';
  
  // Key management endpoints
  static const String keys = '/keys';
  static const String generateKeys = '/keys/generate';
  static const String publicKey = '/keys/public';
  static const String keyVerification = '/keys/verify';
  
  // Utility methods
  static String replacePathParams(String endpoint, Map<String, String> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
  
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
