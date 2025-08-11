import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive.dart';

/// App footer widget for the Bockvote application
class AppFooter extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;
  final bool showLinks;

  const AppFooter({
    super.key,
    this.backgroundColor,
    this.textColor,
    this.showLinks = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.responsivePadding(context).horizontal,
        vertical: AppDimensions.paddingL,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.gray800,
        border: const Border(
          top: BorderSide(color: AppColors.gray300),
        ),
      ),
      child: Responsive.responsive(
        context: context,
        mobile: _buildMobileFooter(context),
        desktop: _buildDesktopFooter(context),
      ),
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      children: [
        if (showLinks) ...[
          _buildFooterLinks(context),
          const SizedBox(height: AppDimensions.spacing24),
        ],
        _buildCopyright(context),
      ],
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCopyright(context),
        if (showLinks) _buildFooterLinks(context),
      ],
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Text(
      '© ${DateTime.now().year} ${AppConstants.appName}. All rights reserved.',
      style: AppTextStyles.caption.copyWith(
        color: textColor ?? AppColors.gray400,
      ),
      textAlign: Responsive.isMobile(context) ? TextAlign.center : TextAlign.left,
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    final links = [
      FooterLink('Privacy Policy', '/privacy'),
      FooterLink('Terms of Service', '/terms'),
      FooterLink('Contact Us', '/contact'),
    ];

    if (Responsive.isMobile(context)) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: AppDimensions.spacing16,
        children: links.map((link) => _buildFooterLink(context, link)).toList(),
      );
    }

    return Row(
      children: links
          .map((link) => _buildFooterLink(context, link))
          .expand((widget) => [widget, const SizedBox(width: AppDimensions.spacing24)])
          .take(links.length * 2 - 1)
          .toList(),
    );
  }

  Widget _buildFooterLink(BuildContext context, FooterLink link) {
    return InkWell(
      onTap: () => context.go(link.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXS,
          vertical: AppDimensions.paddingXS,
        ),
        child: Text(
          link.title,
          style: AppTextStyles.caption.copyWith(
            color: textColor ?? AppColors.gray400,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

/// Footer link data class
class FooterLink {
  final String title;
  final String route;

  const FooterLink(this.title, this.route);
}

/// Specialized footer for landing pages
class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.responsivePadding(context).horizontal,
        vertical: AppDimensions.paddingXL,
      ),
      decoration: const BoxDecoration(
        color: AppColors.gray900,
      ),
      child: Column(
        children: [
          if (!Responsive.isMobile(context)) ...[
            _buildLandingFooterContent(context),
            const SizedBox(height: AppDimensions.spacing32),
          ],
          const Divider(color: AppColors.gray700),
          const SizedBox(height: AppDimensions.spacing16),
          _buildLandingFooterBottom(context),
        ],
      ),
    );
  }

  Widget _buildLandingFooterContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Center(
                      child: Text(
                        'B',
                        style: AppTextStyles.heading5.copyWith(
                          color: AppColors.primary700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                  Text(
                    'Bock Vote',
                    style: AppTextStyles.heading4.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                'Secure and transparent voting on the blockchain. '
                'Ensuring tamper-proof elections with real-time results.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray300,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacing48),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Links',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              _buildFooterNavLink(context, 'Elections', '/elections'),
              _buildFooterNavLink(context, 'Register to Vote', '/register'),
              _buildFooterNavLink(context, 'Results', '/results'),
              _buildFooterNavLink(context, 'Key Management', '/keys'),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Support',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              _buildFooterNavLink(context, 'Help Center', '/help'),
              _buildFooterNavLink(context, 'Contact Us', '/contact'),
              _buildFooterNavLink(context, 'Privacy Policy', '/privacy'),
              _buildFooterNavLink(context, 'Terms of Service', '/terms'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterNavLink(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing8),
      child: InkWell(
        onTap: () => context.go(route),
        child: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.gray400,
          ),
        ),
      ),
    );
  }

  Widget _buildLandingFooterBottom(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          Text(
            '© ${DateTime.now().year} ${AppConstants.appName}. All rights reserved.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            'Built with security and transparency in mind.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '© ${DateTime.now().year} ${AppConstants.appName}. All rights reserved.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray400,
          ),
        ),
        Text(
          'Built with security and transparency in mind.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}
