import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/constants/route_names.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

/// Navigation drawer widget for the Bockvote application
class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildNavigationItems(context),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return DrawerHeader(
          decoration: const BoxDecoration(
            color: AppColors.primary700,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLogo(),
                  const SizedBox(width: AppDimensions.spacing12),
                  Text(
                    'Bock Vote',
                    style: AppTextStyles.heading4.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              if (authProvider.isLoggedIn) ...[
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary500,
                      child: Text(
                        authProvider.currentUser?.name.isNotEmpty == true
                            ? authProvider.currentUser!.name.substring(0, 1).toUpperCase()
                            : 'U',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.currentUser?.name ?? 'User',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            authProvider.currentUser?.email ?? '',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary200,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  'Welcome to Bock Vote',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  'Secure blockchain voting',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary200,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Center(
        child: Text(
          'B',
          style: AppTextStyles.heading5.copyWith(
            color: AppColors.primary700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

        if (!authProvider.isLoggedIn) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildNavigationItem(
                context,
                icon: Icons.home,
                title: 'Home',
                route: RouteNames.home,
                isActive: currentRoute == RouteNames.home,
              ),
              _buildNavigationItem(
                context,
                icon: Icons.how_to_vote,
                title: 'Elections',
                route: RouteNames.elections,
                isActive: currentRoute.startsWith(RouteNames.elections),
              ),
              _buildNavigationItem(
                context,
                icon: Icons.person_add,
                title: 'Register',
                route: RouteNames.register,
                isActive: currentRoute.startsWith(RouteNames.register),
              ),
              const Divider(),
              _buildNavigationItem(
                context,
                icon: Icons.login,
                title: 'Login',
                route: RouteNames.login,
                isActive: currentRoute == RouteNames.login,
              ),
            ],
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildNavigationItem(
              context,
              icon: Icons.dashboard,
              title: 'Dashboard',
              route: RouteNames.home,
              isActive: currentRoute == RouteNames.home,
            ),
            _buildNavigationItem(
              context,
              icon: Icons.how_to_vote,
              title: 'Elections',
              route: RouteNames.elections,
              isActive: currentRoute.startsWith(RouteNames.elections) ||
                       currentRoute.startsWith(RouteNames.voting),
            ),
            _buildNavigationItem(
              context,
              icon: Icons.bar_chart,
              title: 'Results',
              route: RouteNames.results,
              isActive: currentRoute.startsWith(RouteNames.results),
            ),
            const Divider(),
            _buildNavigationItem(
              context,
              icon: Icons.person,
              title: 'Profile',
              route: RouteNames.profile,
              isActive: currentRoute.startsWith(RouteNames.profile),
            ),
            _buildNavigationItem(
              context,
              icon: Icons.key,
              title: 'Key Management',
              route: RouteNames.keys,
              isActive: currentRoute.startsWith(RouteNames.keys),
            ),
            if (authProvider.currentUser?.role == UserRole.admin) ...[
              const Divider(),
              _buildNavigationItem(
                context,
                icon: Icons.admin_panel_settings,
                title: 'Admin Panel',
                route: RouteNames.admin,
                isActive: currentRoute.startsWith(RouteNames.admin),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    bool isActive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.primary600 : AppColors.gray600,
        size: AppDimensions.iconM,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isActive ? AppColors.primary600 : AppColors.gray800,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.primary100,
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        context.go(route);
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isLoggedIn) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.gray200),
            ),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.logout,
              color: AppColors.error,
              size: AppDimensions.iconM,
            ),
            title: Text(
              'Logout',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              authProvider.signOut();
              context.go(RouteNames.home);
            },
          ),
        );
      },
    );
  }
}
