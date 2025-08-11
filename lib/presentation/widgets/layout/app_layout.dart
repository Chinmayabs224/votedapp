import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/route_names.dart';
import '../../../data/providers/auth_provider.dart';
import 'app_header.dart';
import 'navigation_drawer.dart';

/// Main layout widget for the Bockvote application
class AppLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showDrawer;
  final bool showBottomNavigation;
  final FloatingActionButton? floatingActionButton;
  final Color? backgroundColor;

  const AppLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.showDrawer = true,
    this.showBottomNavigation = false,
    this.floatingActionButton,
    this.backgroundColor,
  });

  /// Landing page layout constructor (no navigation)
  const AppLayout.landing({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.backgroundColor,
  }) : showBackButton = false,
       onBackPressed = null,
       showDrawer = false,
       showBottomNavigation = false,
       floatingActionButton = null;

  /// Auth layout constructor (minimal layout for login/register)
  const AppLayout.auth({
    super.key,
    required this.child,
    this.title,
    this.backgroundColor,
  }) : actions = null,
       showBackButton = false,
       onBackPressed = null,
       showDrawer = false,
       showBottomNavigation = false,
       floatingActionButton = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomNavigation(context),
      floatingActionButton: floatingActionButton,
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    // Don't show app bar for landing pages
    if (!showDrawer && !showBackButton && title == null) {
      return null;
    }

    return AppHeader(
      title: title,
      actions: actions,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      showMenuButton: showDrawer && Responsive.isMobile(context),
    );
  }

  Widget? _buildDrawer(BuildContext context) {
    if (!showDrawer || !Responsive.isMobile(context)) {
      return null;
    }

    return const AppNavigationDrawer();
  }

  Widget _buildBody(BuildContext context) {
    if (showDrawer && !Responsive.isMobile(context)) {
      // Desktop layout with side navigation
      return Row(
        children: [
          const SizedBox(
            width: 280,
            child: AppNavigationDrawer(),
          ),
          Expanded(
            child: Container(
              padding: Responsive.responsivePadding(context),
              child: child,
            ),
          ),
        ],
      );
    }

    // Mobile layout or layouts without navigation
    return Container(
      padding: showDrawer 
          ? Responsive.responsivePadding(context)
          : EdgeInsets.zero,
      child: child,
    );
  }

  Widget? _buildBottomNavigation(BuildContext context) {
    if (!showBottomNavigation || !Responsive.isMobile(context)) {
      return null;
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isLoggedIn) {
          return const SizedBox.shrink();
        }

        final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary600,
          unselectedItemColor: AppColors.gray500,
          selectedLabelStyle: AppTextStyles.caption,
          unselectedLabelStyle: AppTextStyles.caption,
          currentIndex: _getCurrentIndex(currentRoute),
          onTap: (index) => _onBottomNavTap(context, index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.how_to_vote),
              label: 'Elections',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Results',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
      },
    );
  }

  int _getCurrentIndex(String currentRoute) {
    if (currentRoute.startsWith(RouteNames.elections) || 
        currentRoute.startsWith(RouteNames.voting)) {
      return 1;
    } else if (currentRoute.startsWith(RouteNames.results)) {
      return 2;
    } else if (currentRoute.startsWith(RouteNames.profile)) {
      return 3;
    }
    return 0; // Dashboard
  }

  void _onBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.elections);
        break;
      case 2:
        context.go(RouteNames.results);
        break;
      case 3:
        context.go(RouteNames.profile);
        break;
    }
  }
}

/// Responsive layout wrapper
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return Responsive.responsive(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Constrained content wrapper
class ConstrainedContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? AppDimensions.maxContentWidth,
        ),
        padding: padding ?? Responsive.responsivePadding(context),
        child: child,
      ),
    );
  }
}

/// Section wrapper with title and content
class Section extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const Section({
    super.key,
    this.title,
    this.titleWidget,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: AppDimensions.paddingL),
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || titleWidget != null) ...[
            titleWidget ?? Text(
              title!,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
          ],
          child,
        ],
      ),
    );
  }
}
