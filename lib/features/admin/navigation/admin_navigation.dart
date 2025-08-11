import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Core
import '../../../core/constants/route_names.dart';
import '../../../core/theme/app_colors.dart';

// Admin
import '../providers/admin_provider.dart';

/// Admin Navigation Widget
/// 
/// This widget provides a consistent navigation sidebar for all admin screens.
class AdminNavigation extends StatelessWidget {
  final String currentRoute;
  
  const AdminNavigation({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        return Container(
          width: 250,
          color: AppColors.white,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildNavItems(context),
              ),
            ],
          ),
        );
      });
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.admin_panel_settings,
            color: AppColors.primary600,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Admin Panel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavItems(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildNavItem(
          context: context,
          icon: Icons.dashboard,
          title: 'Dashboard',
          route: RouteNames.adminDashboard,
        ),
        _buildNavItem(
          context: context,
          icon: Icons.verified_user,
          title: 'Verify Users',
          route: RouteNames.adminUsers,
        ),
        _buildNavItem(
          context: context,
          icon: Icons.how_to_vote,
          title: 'Manage Elections',
          route: RouteNames.adminElections,
        ),
        _buildNavItem(
          context: context,
          icon: Icons.bar_chart,
          title: 'View Stats',
          route: RouteNames.adminReports,
        ),
        _buildNavItem(
          context: context,
          icon: Icons.play_circle_filled,
          title: 'Start Election',
          route: RouteNames.createElection,
        ),
        const Divider(),
        _buildNavItem(
          context: context,
          icon: Icons.home,
          title: 'Back to Home',
          route: RouteNames.home,
        ),
      ],
      );
  }
  
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
  }) {
    final bool isActive = currentRoute == route;
    
    return InkWell(
      onTap: () {
        if (currentRoute != route) {
          context.go(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary600.withValues(alpha: 0.1) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? AppColors.primary600 : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary600 : AppColors.gray600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isActive ? AppColors.primary600 : AppColors.gray800,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Admin Layout Widget
/// 
/// This widget provides a consistent layout for all admin screens,
/// including the navigation sidebar and a content area.
class AdminLayout extends StatelessWidget {
  final String currentRoute;
  final Widget child;
  final String title;
  final List<Widget>? actions;
  
  const AdminLayout({
    super.key,
    required this.currentRoute,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: Row(
        children: [
          AdminNavigation(currentRoute: currentRoute),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}