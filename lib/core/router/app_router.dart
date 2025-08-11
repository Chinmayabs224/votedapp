import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Core
import '../constants/route_names.dart';

// Features
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/voter_registration_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/voting/screens/voting_screen.dart';
import '../../features/voting/screens/vote_confirmation_screen.dart';
import '../../features/voting/screens/elections_screen.dart';
import '../../features/results/screens/results_screen.dart';
import '../../features/results/screens/result_detail_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/admin/screens/admin_elections_screen.dart';
import '../../features/admin/screens/admin_reports_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/keys/screens/key_management_screen.dart';
import '../../features/keys/screens/generate_keys_screen.dart';
import '../../presentation/screens/common/not_found_screen.dart';
/// Router configuration for the application
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        // Auth routes
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
        GoRoute(
          path: RouteNames.voterRegistration,
          name: 'voter-registration',
          builder: (context, state) => const VoterRegistrationScreen(),
        ),
        
        // Main routes
        GoRoute(
          path: RouteNames.home,
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.elections,
          name: 'elections',
          builder: (context, state) => const ElectionsScreen(),
        ),
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
        
        // Admin routes
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
        
        // Profile routes
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
        
        // Key management routes
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
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Oops! The page you are looking for does not exist.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static GoRouter getRouter(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final bool isLoggedIn = authProvider.isLoggedIn;
        final bool isLoginRoute = state.matchedLocation == RouteNames.login;
        final bool isRegisterRoute = state.matchedLocation == RouteNames.register;
        final bool isAdminRoute = state.matchedLocation.startsWith(RouteNames.admin);
        
        // If user is not logged in and not on login or register page, redirect to login
        if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
          return RouteNames.login;
        }
        
        // If user is logged in and on login or register page, redirect to dashboard
        if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
          return RouteNames.home;
        }
        
        // If user is trying to access admin routes but is not an admin, redirect to home
         if (isLoggedIn && isAdminRoute && authProvider.currentUser != null && !(authProvider.currentUser!.role == 'admin')) {
          return RouteNames.home;
        }
        
        // No redirect needed
        return null;
      },
      routes: [
        // Auth routes
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
        GoRoute(
          path: RouteNames.voterRegistration,
          name: 'voter-registration',
          builder: (context, state) => const VoterRegistrationScreen(),
        ),
        
        // Main routes
        GoRoute(
          path: RouteNames.home,
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.elections,
          name: 'elections',
          builder: (context, state) => const ElectionsScreen(),
        ),
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
        
        // Admin routes
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
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Oops! The page you are looking for does not exist.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}