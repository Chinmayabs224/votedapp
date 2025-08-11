import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// Status types for the badge
enum StatusType {
  success,
  error,
  warning,
  info,
  neutral
}

/// Alias for backward compatibility
typedef StatusBadgeType = StatusType;

/// A badge widget for displaying status information
class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType type;
  final bool isOutlined;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : _getBackgroundColor(),
        border: isOutlined ? Border.all(color: _getBorderColor()) : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isOutlined ? _getBorderColor() : _getTextColor(),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case StatusType.success:
        return BockColors.success.withValues(alpha: 0.1);
      case StatusType.error:
        return BockColors.error.withValues(alpha: 0.1);
      case StatusType.warning:
        return BockColors.warning.withValues(alpha: 0.1);
      case StatusType.info:
        return BockColors.info.withValues(alpha: 0.1);
      case StatusType.neutral:
        return BockColors.gray200;
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case StatusType.success:
        return BockColors.success;
      case StatusType.error:
        return BockColors.error;
      case StatusType.warning:
        return BockColors.warning;
      case StatusType.info:
        return BockColors.info;
      case StatusType.neutral:
        return BockColors.gray500;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case StatusType.success:
        return BockColors.success;
      case StatusType.error:
        return BockColors.error;
      case StatusType.warning:
        return BockColors.warning;
      case StatusType.info:
        return BockColors.info;
      case StatusType.neutral:
        return BockColors.gray700;
    }
  }
}