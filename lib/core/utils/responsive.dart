import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';

/// Responsive design utilities for the Bockvote application
class Responsive {
  /// Check if the current screen size is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppDimensions.mobileBreakpoint;
  
  /// Check if the current screen size is tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppDimensions.mobileBreakpoint &&
      MediaQuery.of(context).size.width < AppDimensions.tabletBreakpoint;
  
  /// Check if the current screen size is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppDimensions.tabletBreakpoint;
  
  /// Get the current screen type
  static ScreenType getScreenType(BuildContext context) {
    if (isMobile(context)) return ScreenType.mobile;
    if (isTablet(context)) return ScreenType.tablet;
    return ScreenType.desktop;
  }
  
  /// Build responsive widget based on screen size
  static Widget responsive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    required Widget desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
  
  /// Get responsive value based on screen size
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
  
  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsiveValue(
        context: context,
        mobile: AppDimensions.paddingM,
        tablet: AppDimensions.paddingL,
        desktop: AppDimensions.paddingXL,
      ),
      vertical: AppDimensions.paddingM,
    );
  }
  
  /// Get responsive margin
  static EdgeInsets responsiveMargin(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsiveValue(
        context: context,
        mobile: AppDimensions.marginM,
        tablet: AppDimensions.marginL,
        desktop: AppDimensions.marginXL,
      ),
      vertical: AppDimensions.marginM,
    );
  }
  
  /// Get responsive grid column count
  static int responsiveGridColumns(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
  }
  
  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    final scaleFactor = responsiveValue(
      context: context,
      mobile: 0.9,
      tablet: 1.0,
      desktop: 1.1,
    );
    return baseFontSize * scaleFactor;
  }
  
  /// Get responsive icon size
  static double responsiveIconSize(BuildContext context, double baseIconSize) {
    final scaleFactor = responsiveValue(
      context: context,
      mobile: 0.9,
      tablet: 1.0,
      desktop: 1.1,
    );
    return baseIconSize * scaleFactor;
  }
  
  /// Get responsive button height
  static double responsiveButtonHeight(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: AppDimensions.buttonHeightM,
      tablet: AppDimensions.buttonHeightL,
      desktop: AppDimensions.buttonHeightL,
    );
  }
  
  /// Get responsive card width
  static double responsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return screenWidth - (AppDimensions.paddingM * 2);
    } else if (isTablet(context)) {
      return (screenWidth - (AppDimensions.paddingL * 3)) / 2;
    } else {
      return (screenWidth - (AppDimensions.paddingXL * 4)) / 3;
    }
  }
  
  /// Get responsive container constraints
  static BoxConstraints responsiveConstraints(BuildContext context) {
    return BoxConstraints(
      maxWidth: responsiveValue(
        context: context,
        mobile: double.infinity,
        tablet: AppDimensions.maxContentWidth * 0.8,
        desktop: AppDimensions.maxContentWidth,
      ),
    );
  }
}

/// Enum for screen types
enum ScreenType {
  mobile,
  tablet,
  desktop,
}

/// Extension for responsive text styles
extension ResponsiveTextStyle on TextStyle {
  TextStyle responsive(BuildContext context) {
    return copyWith(
      fontSize: Responsive.responsiveFontSize(context, fontSize ?? 14),
    );
  }
}
