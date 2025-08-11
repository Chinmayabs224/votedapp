import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// A responsive layout wrapper that provides different layouts based on screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? mobile;
  final Widget? tabletLayout;
  final Widget? desktopLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    this.mobile,
    this.tabletLayout,
    this.desktopLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.desktopBreakpoint) {
          return desktopLayout ?? tabletLayout ?? mobileLayout;
        } else if (constraints.maxWidth >= AppConstants.mobileBreakpoint + 1) {
          return tabletLayout ?? mobileLayout;
        } else {
          return mobile ?? mobileLayout;
        }
      },
    );
  }

  /// Helper method to determine if the current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= AppConstants.mobileBreakpoint;
  }

  /// Helper method to determine if the current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > AppConstants.mobileBreakpoint && width <= AppConstants.tabletBreakpoint;
  }

  /// Helper method to determine if the current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > AppConstants.tabletBreakpoint;
  }
}