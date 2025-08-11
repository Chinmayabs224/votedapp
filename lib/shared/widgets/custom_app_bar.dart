import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../layouts/responsive_layout.dart';

/// Custom app bar with logo and navigation
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<NavigationItem> navigationItems;
  final VoidCallback onMenuPressed;
  final bool isMenuOpen;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.navigationItems,
    required this.onMenuPressed,
    this.isMenuOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: BockColors.primary700,
      title: Row(
        children: [
          // Logo
          _buildLogo(),
          const SizedBox(width: 16),
          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: BockColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      actions: ResponsiveLayout.isMobile(context)
          ? [
              // Mobile menu button
              IconButton(
                icon: Icon(
                  isMenuOpen ? Icons.close : Icons.menu,
                  color: BockColors.white,
                ),
                onPressed: onMenuPressed,
              ),
            ]
          : [
              // Desktop navigation
              ...navigationItems.map((item) => _buildNavItem(context, item)),
              const SizedBox(width: 16),
            ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: BockColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'B',
          style: TextStyle(
            color: BockColors.primary700,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavigationItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: item.onTap,
        style: TextButton.styleFrom(
          foregroundColor: BockColors.white,
        ),
        child: Text(
          item.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BockColors.white,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NavigationItem {
  final String label;
  final VoidCallback onTap;

  NavigationItem({
    required this.label,
    required this.onTap,
  });
}