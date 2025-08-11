import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/theme/colors.dart';

/// A primary button widget with loading state support
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final bool isDisabled;
  final bool small;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isDisabled = false,
    this.small = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: BockColors.primary600.withValues(alpha: 0.7),
          disabledForegroundColor: BockColors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: small ? 8 : 12),
          child: isLoading
              ? SpinKitThreeBounce(
                  color: BockColors.white,
                  size: small ? 18 : 24,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: small ? 16 : 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(fontSize: small ? 14 : 16),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}