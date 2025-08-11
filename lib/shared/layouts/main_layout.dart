import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'responsive_layout.dart';

/// Main layout with header, content, and footer
class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BockColors.primary700,
        foregroundColor: BockColors.white,
        title: Row(
          children: [
            _buildLogo(),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: BockColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: BockColors.white),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          if (!showBackButton) ..._buildNavigationActions(context),
          if (actions != null) ...actions!,
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: Container(
                color: BockColors.gray100,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: EdgeInsets.all(
                        ResponsiveLayout.isMobile(context)
                            ? AppConstants.smallPadding
                            : AppConstants.defaultPadding,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              width: double.infinity,
              color: BockColors.gray800,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: AppConstants.defaultPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '© ${DateTime.now().year} Bockvote. All rights reserved.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: BockColors.gray300,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _FooterLink(text: 'Privacy Policy', onTap: () {}),
                          const SizedBox(width: 16),
                          _FooterLink(text: 'Terms of Service', onTap: () {}),
                          const SizedBox(width: 16),
                          _FooterLink(text: 'Contact Us', onTap: () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: BockColors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Text(
          'B',
          style: TextStyle(
            color: BockColors.primary700,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationActions(BuildContext context) {
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

    return [
      _buildNavButton(
        context,
        'Dashboard',
        Icons.dashboard,
        '/',
        currentRoute == '/',
      ),
      _buildNavButton(
        context,
        'Voting',
        Icons.how_to_vote,
        '/voting',
        currentRoute == '/voting',
      ),
      _buildNavButton(
        context,
        'Results',
        Icons.bar_chart,
        '/results',
        currentRoute == '/results',
      ),
      const SizedBox(width: 8),
      Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: BockColors.white),
            onSelected: (value) {
              if (value == 'logout') {
                authProvider.signOut();
                context.go('/login');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(authProvider.currentUser?.name ?? 'User'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      const SizedBox(width: 16),
    ];
  }

  Widget _buildNavButton(
    BuildContext context,
    String label,
    IconData icon,
    String route,
    bool isActive,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        onPressed: () => context.go(route),
        icon: Icon(
          icon,
          color: isActive ? BockColors.primary200 : BockColors.white,
          size: 18,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isActive ? BockColors.primary200 : BockColors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: isActive ? BockColors.primary600 : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BockColors.gray400,
              decoration: TextDecoration.underline,
            ),
      ),
    );
  }
}