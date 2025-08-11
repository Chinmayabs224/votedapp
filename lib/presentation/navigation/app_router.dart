import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_names.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/user_model.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
// Placeholder screens will be created later
import '../screens/common/not_found_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/keys/screens/key_management_screen.dart';
import '../../features/keys/screens/generate_keys_screen.dart';
import '../screens/common/error_screen.dart';
// Admin screens
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/admin/screens/admin_elections_screen.dart';
import '../../features/admin/screens/admin_reports_screen.dart';
import '../../features/auth/screens/voter_registration_screen.dart';
import '../../features/voting/screens/elections_screen.dart';
import '../../features/voting/screens/voting_screen.dart';
import '../../features/voting/screens/vote_confirmation_screen.dart';
import '../../features/results/screens/results_screen.dart';
import '../../features/results/screens/result_detail_screen.dart';

/// Main router configuration for the Bockvote application
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: RouteNames.home,
      debugLogDiagnostics: true,
      redirect: _handleRedirect,
      routes: [
        // Home/Landing route
        GoRoute(
          path: RouteNames.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        // Authentication routes
        GoRoute(
          path: RouteNames.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteNames.register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Election routes
        GoRoute(
          path: RouteNames.elections,
          name: 'elections',
          builder: (context, state) => const ElectionsScreen(),
        ),
        GoRoute(
          path: RouteNames.electionDetail,
          name: 'election-detail',
          builder: (context, state) => const ElectionsScreen(), // Will be replaced with ElectionDetailScreen in future
        ),

        // Voting routes
        GoRoute(
          path: RouteNames.voting,
          name: 'voting',
          builder: (context, state) => const VotingScreen(),
        ),
        GoRoute(
          path: RouteNames.voteConfirmation,
          name: 'vote-confirmation',
          builder: (context, state) => VoteConfirmationScreen(
            electionId: state.pathParameters['electionId'] ?? '',
            candidateId: state.pathParameters['candidateId'] ?? '',
          ),
        ),

        // Results routes
        GoRoute(
          path: RouteNames.results,
          name: 'results',
          builder: (context, state) => const ResultsScreen(),
        ),
        GoRoute(
          path: RouteNames.resultDetail,
          name: 'result-detail',
          builder: (context, state) => ResultDetailScreen(
            electionId: state.pathParameters['id'] ?? '',
          ),
        ),

        // Registration routes
        GoRoute(
          path: RouteNames.voterRegistration,
          name: 'voter-registration',
          builder: (context, state) => const VoterRegistrationScreen(),
        ),

        GoRoute(
          path: RouteNames.candidateRegistration,
          name: 'candidate-registration',
          builder: (context, state) => const NotFoundScreen(), // Will be implemented in future
        ),

        GoRoute(
          path: RouteNames.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: RouteNames.editProfile,
          name: 'edit-profile',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Edit Profile - Coming Soon')),
          ),
        ),
        GoRoute(
          path: RouteNames.changePassword,
          name: 'change-password',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Change Password - Coming Soon')),
          ),
        ),

        GoRoute(
          path: RouteNames.admin,
          name: 'admin',
          redirect: (_, __) => RouteNames.adminDashboard,
        ),
        GoRoute(
          path: RouteNames.adminDashboard,
          name: 'admin-dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.adminUsers,
          name: 'admin-users',
          builder: (context, state) => const AdminUsersScreen(),
        ),
        GoRoute(
          path: RouteNames.adminElections,
          name: 'admin-elections',
          builder: (context, state) => const AdminElectionsScreen(),
        ),
        GoRoute(
          path: RouteNames.adminReports,
          name: 'admin-reports',
          builder: (context, state) => const AdminReportsScreen(),
        ),
        GoRoute(
          path: RouteNames.createElection,
          name: 'admin-elections-create',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Create Election Screen - Coming Soon')),
          ),
        ),
        GoRoute(
          path: RouteNames.editElection,
          name: 'admin-elections-edit',
          builder: (context, state) => Scaffold(
            body: Center(child: Text('Edit Election ${state.pathParameters['id']} - Coming Soon')),
          ),
        ),

        GoRoute(
          path: RouteNames.keys,
          name: 'keys',
          redirect: (_, __) => RouteNames.keyManagement,
        ),
        GoRoute(
          path: RouteNames.keyManagement,
          name: 'key-management',
          builder: (context, state) => const KeyManagementScreen(),
        ),
        GoRoute(
          path: RouteNames.generateKeys,
          name: 'generate-keys',
          builder: (context, state) => const GenerateKeysScreen(),
        ),

        // Error routes
        GoRoute(
          path: RouteNames.notFound,
          name: 'not-found',
          builder: (context, state) => const NotFoundScreen(),
        ),
        GoRoute(
          path: RouteNames.error,
          name: 'error',
          builder: (context, state) {
            final error = state.extra as String?;
            return ErrorScreen(error: error);
          },
        ),
      ],
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }

  /// Handle route redirects based on authentication state
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isLoggedIn;
    final isLoggingIn = state.matchedLocation == RouteNames.login;
    final isRegistering = state.matchedLocation == RouteNames.register;
    final isOnPublicRoute = _isPublicRoute(state.matchedLocation);

    // If not logged in and trying to access protected route, redirect to login
    if (!isLoggedIn && !isOnPublicRoute && !isLoggingIn && !isRegistering) {
      return RouteNames.login;
    }

    // If logged in and trying to access auth routes, redirect to home
    if (isLoggedIn && (isLoggingIn || isRegistering)) {
      return RouteNames.home;
    }

    // Check admin routes
    if (state.matchedLocation.startsWith(RouteNames.admin)) {
      if (!isLoggedIn) {
        return RouteNames.login;
      }
      if (authProvider.currentUser?.role != UserRole.admin) {
        return RouteNames.home; // Redirect non-admin users
      }
    }

    return null; // No redirect needed
  }

  /// Check if a route is public (accessible without authentication)
  static bool _isPublicRoute(String route) {
    const publicRoutes = [
      RouteNames.home,
      RouteNames.elections,
      RouteNames.results,
      RouteNames.voterRegistration,
      RouteNames.candidateRegistration,
      RouteNames.notFound,
      RouteNames.error,
    ];

    return publicRoutes.any((publicRoute) => 
      route == publicRoute || route.startsWith('$publicRoute/'));
  }

  /// Navigate to election detail
  static void goToElectionDetail(BuildContext context, String electionId) {
    context.go('${RouteNames.elections}/$electionId');
  }

  /// Navigate to voting screen
  static void goToVoting(BuildContext context, String electionId) {
    context.go('${RouteNames.elections}/$electionId/vote');
  }

  /// Navigate to vote confirmation
  static void goToVoteConfirmation(
    BuildContext context, 
    String electionId, 
    String candidateId,
  ) {
    context.go('/voting/confirm/$electionId/$candidateId');
  }

  /// Navigate to results detail
  static void goToResultDetail(BuildContext context, String electionId) {
    context.go('${RouteNames.results}/$electionId');
  }

  /// Navigate to admin election edit
  static void goToEditElection(BuildContext context, String electionId) {
    context.go('${RouteNames.admin}/elections/$electionId/edit');
  }

  /// Navigate with error handling
  static void safeNavigate(BuildContext context, String route, {Object? extra}) {
    try {
      if (extra != null) {
        context.go(route, extra: extra);
      } else {
        context.go(route);
      }
    } catch (e) {
      context.go(RouteNames.error, extra: e.toString());
    }
  }

  /// Navigate back with fallback
  static void goBack(BuildContext context, {String? fallback}) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallback ?? RouteNames.home);
    }
  }
}
