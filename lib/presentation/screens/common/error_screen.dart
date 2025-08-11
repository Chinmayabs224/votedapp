import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/constants/route_names.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

/// Error screen for displaying application errors
class ErrorScreen extends StatelessWidget {
  final String? error;
  final String? title;
  final String? description;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    this.error,
    this.title,
    this.description,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppLayout.auth(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.error,
                ),
              ),
              
              const SizedBox(height: AppDimensions.spacing32),
              
              // Title
              Text(
                title ?? 'Something went wrong',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.spacing16),
              
              // Description
              Text(
                description ?? 'An unexpected error occurred. Please try again.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (error != null) ...[
                const SizedBox(height: AppDimensions.spacing24),
                
                // Error Details Card
                AppCard.outlined(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.bug_report,
                            size: AppDimensions.iconM,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          Text(
                            'Error Details',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.gray900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacing12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.gray50,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: Text(
                          error!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: AppDimensions.spacing32),
              
              // Actions
              Column(
                children: [
                  if (onRetry != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        text: 'Try Again',
                        onPressed: onRetry,
                        icon: Icons.refresh,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing12),
                  ],
                  
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.secondary(
                      text: 'Go to Home',
                      onPressed: () => context.go(RouteNames.home),
                      icon: Icons.home,
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.spacing12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.text(
                      text: 'Go Back',
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.home);
                        }
                      },
                      icon: Icons.arrow_back,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Network error screen
class NetworkErrorScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorScreen({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      title: 'Connection Problem',
      description: 'Please check your internet connection and try again.',
      onRetry: onRetry,
    );
  }
}

/// Server error screen
class ServerErrorScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorScreen({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      title: 'Server Error',
      description: 'The server is currently unavailable. Please try again later.',
      onRetry: onRetry,
    );
  }
}

/// Maintenance screen
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout.auth(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Maintenance Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                ),
                child: const Icon(
                  Icons.build,
                  size: 60,
                  color: AppColors.warning,
                ),
              ),
              
              const SizedBox(height: AppDimensions.spacing32),
              
              // Title
              Text(
                'Under Maintenance',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.spacing16),
              
              // Description
              Text(
                'We\'re currently performing maintenance to improve your experience. '
                'Please check back in a few minutes.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.spacing32),
              
              // Refresh Button
              SizedBox(
                width: double.infinity,
                child: AppButton.primary(
                  text: 'Refresh Page',
                  onPressed: () {
                    // Refresh the current page
                    context.go(context.namedLocation('home'));
                  },
                  icon: Icons.refresh,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
