/// Route name constants for the Bockvote application
class RouteNames {
  // Main routes
  static const String home = '/';
  static const String dashboard = '/dashboard';
  
  // Authentication routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  
  // Election routes
  static const String elections = '/elections';
  static const String electionDetail = '/elections/:id';
  static const String voting = '/voting';
  static const String voteConfirmation = '/voting/confirm/:electionId/:candidateId';
  
  // Results routes
  static const String results = '/results';
  static const String resultDetail = '/results/:id';
  
  // Registration routes
  static const String voterRegistration = '/register/voter';
  static const String candidateRegistration = '/register/candidate';
  
  // Admin routes
  static const String admin = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminElections = '/admin/elections';
  static const String adminUsers = '/admin/users';
  static const String adminReports = '/admin/reports';
  static const String electionManagement = '/admin/elections/manage';
  static const String createElection = '/admin/elections/create';
  static const String editElection = '/admin/elections/:id/edit';
  
  // Key management routes
  static const String keys = '/keys';
  static const String keyManagement = '/keys/manage';
  static const String generateKeys = '/keys/generate';
  
  // Profile routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  
  // Error routes
  static const String notFound = '/404';
  static const String error = '/error';
  
  // Utility methods
  static String replaceParams(String route, Map<String, String> params) {
    String result = route;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }
  
  static String getElectionDetail(String electionId) {
    return electionDetail.replaceAll(':id', electionId);
  }
  
  static String getResultDetail(String electionId) {
    return resultDetail.replaceAll(':id', electionId);
  }
  
  static String getVoteConfirmation(String electionId, String candidateId) {
    return voteConfirmation
        .replaceAll(':electionId', electionId)
        .replaceAll(':candidateId', candidateId);
  }
  
  static String getEditElection(String electionId) {
    return editElection.replaceAll(':id', electionId);
  }
}
