import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/constants/route_names.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/common/app_button.dart';

/// 404 Not Found screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

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
              // 404 Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.gray500,
                ),
              ),
              
              const SizedBox(height: AppDimensions.spacing32),
              
              // Title
              Text(
                '404',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.spacing16),
              
              // Subtitle
              Text(
                'Page Not Found',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.gray700,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.spacing16),
              
              // Description
              Text(
                'The page you are looking for doesn\'t exist or has been moved.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.spacing32),
              
              // Actions
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.primary(
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
