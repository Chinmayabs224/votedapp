import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

/// Reusable card widget for the Bockvote application
class AppCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final VoidCallback? onTap;
  final bool isSelected;
  final AppCardType type;

  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.titleWidget,
    this.actions,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.borderSide,
    this.onTap,
    this.isSelected = false,
    this.type = AppCardType.elevated,
  });

  /// Elevated card constructor
  const AppCard.elevated({
    super.key,
    required this.child,
    this.title,
    this.titleWidget,
    this.actions,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.borderSide,
    this.onTap,
    this.isSelected = false,
  }) : type = AppCardType.elevated;

  /// Outlined card constructor
  const AppCard.outlined({
    super.key,
    required this.child,
    this.title,
    this.titleWidget,
    this.actions,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.borderSide,
    this.onTap,
    this.isSelected = false,
  }) : type = AppCardType.outlined,
       elevation = 0;

  /// Filled card constructor
  const AppCard.filled({
    super.key,
    required this.child,
    this.title,
    this.titleWidget,
    this.actions,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.borderSide,
    this.onTap,
    this.isSelected = false,
  }) : type = AppCardType.filled,
       elevation = 0;

  @override
  Widget build(BuildContext context) {
    final cardChild = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || titleWidget != null || actions != null)
          _buildHeader(),
        if (title != null || titleWidget != null || actions != null)
          const SizedBox(height: AppDimensions.spacing12),
        child,
      ],
    );

    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingM),
      child: cardChild,
    );

    Widget card;
    switch (type) {
      case AppCardType.elevated:
        card = Card(
          elevation: elevation ?? AppDimensions.elevation2,
          color: backgroundColor ?? AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
            side: borderSide ?? const BorderSide(style: BorderStyle.none),
          ),
          margin: margin ?? const EdgeInsets.all(AppDimensions.marginS),
          child: cardContent,
        );
        break;
      case AppCardType.outlined:
        card = Card(
          elevation: 0,
          color: backgroundColor ?? AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
            side: borderSide ?? const BorderSide(color: AppColors.gray300),
          ),
          margin: margin ?? const EdgeInsets.all(AppDimensions.marginS),
          child: cardContent,
        );
        break;
      case AppCardType.filled:
        card = Card(
          elevation: 0,
          color: backgroundColor ?? AppColors.gray50,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
            side: borderSide ?? const BorderSide(style: BorderStyle.none),
          ),
          margin: margin ?? const EdgeInsets.all(AppDimensions.marginS),
          child: cardContent,
        );
        break;
    }

    if (isSelected) {
      card = Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: AppColors.primary500,
            width: 2,
          ),
        ),
        child: card,
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusL),
        child: card,
      );
    }

    return card;
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: titleWidget ?? 
            (title != null 
              ? Text(
                  title!,
                  style: AppTextStyles.heading5.copyWith(
                    color: AppColors.gray900,
                  ),
                )
              : const SizedBox.shrink()),
        ),
        if (actions != null) ...[
          const SizedBox(width: AppDimensions.spacing8),
          ...actions!,
        ],
      ],
    );
  }
}

/// Card type enumeration
enum AppCardType {
  elevated,
  outlined,
  filled,
}

/// Specialized card widgets

/// Info card with icon and content
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary600).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary600,
              size: AppDimensions.iconL,
            ),
          ),
          const SizedBox(width: AppDimensions.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading6.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card with number and label
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;
  final String? trend;
  final bool isPositiveTrend;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color,
    this.trend,
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: AppTextStyles.heading2.copyWith(
                  color: color ?? AppColors.primary600,
                ),
              ),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingXS),
                  decoration: BoxDecoration(
                    color: (color ?? AppColors.primary600).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: color ?? AppColors.primary600,
                    size: AppDimensions.iconM,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: AppDimensions.spacing4),
            Row(
              children: [
                Icon(
                  isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                  color: isPositiveTrend ? AppColors.success : AppColors.error,
                  size: AppDimensions.iconS,
                ),
                const SizedBox(width: AppDimensions.spacing4),
                Text(
                  trend!,
                  style: AppTextStyles.caption.copyWith(
                    color: isPositiveTrend ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
