import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

/// App header/app bar widget for the Bockvote application
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showMenuButton;
  final bool showLogo;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppHeader({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.showMenuButton = false,
    this.showLogo = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.primary700,
      foregroundColor: foregroundColor ?? AppColors.white,
      elevation: AppDimensions.elevation2,
      centerTitle: false,
      leading: _buildLeading(context),
      title: _buildTitle(context),
      actions: _buildActions(context),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }

    if (showMenuButton) {
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      );
    }

    return null;
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLogo) ...[
          _buildLogo(),
          const SizedBox(width: AppDimensions.spacing12),
        ],
        if (title != null)
          Flexible(
            child: Text(
              title!,
              style: AppTextStyles.heading4.copyWith(
                color: foregroundColor ?? AppColors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
        else if (showLogo)
          Text(
            'Bock Vote',
            style: AppTextStyles.heading4.copyWith(
              color: foregroundColor ?? AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
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

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> actionWidgets = [];

    // Add desktop navigation if not mobile
    if (!Responsive.isMobile(context)) {
      actionWidgets.addAll(_buildDesktopNavigation(context));
    }

    // Add custom actions
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    // Add user menu
    actionWidgets.add(_buildUserMenu(context));

    return actionWidgets;
  }

  List<Widget> _buildDesktopNavigation(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isLoggedIn) {
      return [
        _buildNavButton(context, 'Home', RouteNames.home),
        _buildNavButton(context, 'Elections', RouteNames.elections),
        _buildNavButton(context, 'Register', RouteNames.register),
      ];
    }

    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

    return [
      _buildNavButton(
        context,
        'Dashboard',
        RouteNames.home,
        isActive: currentRoute == RouteNames.home,
      ),
      _buildNavButton(
        context,
        'Elections',
        RouteNames.elections,
        isActive: currentRoute.startsWith(RouteNames.elections) ||
                 currentRoute.startsWith(RouteNames.voting),
      ),
      _buildNavButton(
        context,
        'Results',
        RouteNames.results,
        isActive: currentRoute.startsWith(RouteNames.results),
      ),
      if (authProvider.currentUser?.role == UserRole.admin)
        _buildNavButton(
          context,
          'Admin',
          RouteNames.admin,
          isActive: currentRoute.startsWith(RouteNames.admin),
        ),
    ];
  }

  Widget _buildNavButton(
    BuildContext context, 
    String label, 
    String route, {
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXS),
      child: TextButton(
        onPressed: () => context.go(route),
        style: TextButton.styleFrom(
          foregroundColor: isActive 
              ? AppColors.primary200 
              : (foregroundColor ?? AppColors.white),
          backgroundColor: isActive
              ? AppColors.primary600.withValues(alpha: 0.2)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isLoggedIn) {
          return TextButton(
            onPressed: () => context.go(RouteNames.login),
            style: TextButton.styleFrom(
              foregroundColor: foregroundColor ?? AppColors.white,
            ),
            child: const Text('Login'),
          );
        }

        return PopupMenuButton<String>(
          icon: Icon(
            Icons.account_circle,
            color: foregroundColor ?? AppColors.white,
            size: AppDimensions.iconL,
          ),
          onSelected: (value) => _handleMenuSelection(context, value, authProvider),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person, size: AppDimensions.iconM),
                  const SizedBox(width: AppDimensions.spacing8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        authProvider.currentUser?.name ?? 'User',
                        style: AppTextStyles.labelLarge,
                      ),
                      Text(
                        authProvider.currentUser?.email ?? '',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.settings, size: AppDimensions.iconM),
                  SizedBox(width: AppDimensions.spacing8),
                  Text('Profile Settings'),
                ],
              ),
            ),
            if (authProvider.currentUser?.role == UserRole.admin)
              const PopupMenuItem(
                value: 'admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, size: AppDimensions.iconM),
                    SizedBox(width: AppDimensions.spacing8),
                    Text('Admin Panel'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'keys',
              child: Row(
                children: [
                  Icon(Icons.key, size: AppDimensions.iconM),
                  SizedBox(width: AppDimensions.spacing8),
                  Text('Key Management'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: AppDimensions.iconM),
                  SizedBox(width: AppDimensions.spacing8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleMenuSelection(
    BuildContext context, 
    String value, 
    AuthProvider authProvider,
  ) {
    switch (value) {
      case 'profile':
        context.go(RouteNames.profile);
        break;
      case 'admin':
        context.go(RouteNames.admin);
        break;
      case 'keys':
        context.go(RouteNames.keys);
        break;
      case 'logout':
        authProvider.signOut();
        context.go(RouteNames.home);
        break;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
