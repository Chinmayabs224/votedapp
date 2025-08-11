import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/colors.dart';

/// A custom card widget for displaying content
class CustomCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool hasBorder;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.padding,
    this.width,
    this.height,
    this.hasBorder = false,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? BockColors.white,
          borderRadius: BorderRadius.circular(12),
          border: hasBorder
              ? Border.all(color: BockColors.gray300, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: BockColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || actions != null) ...[  
              Padding(
                padding: const EdgeInsets.all(AppConstants.smallPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    if (actions != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
            ],
            Padding(
              padding: padding ?? const EdgeInsets.all(AppConstants.defaultPadding),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}