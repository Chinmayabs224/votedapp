import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/election_provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

/// Home screen for the Bockvote application
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      final electionProvider = Provider.of<ElectionProvider>(context, listen: false);
      electionProvider.loadElections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoggedIn) {
          return _buildDashboard(context);
        } else {
          return _buildLandingPage(context);
        }
      },
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return AppLayout(
      title: 'Dashboard',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context),
            const SizedBox(height: AppDimensions.spacing32),
            _buildQuickStats(context),
            const SizedBox(height: AppDimensions.spacing32),
            _buildRecentElections(context),
            const SizedBox(height: AppDimensions.spacing32),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLandingPage(BuildContext context) {
    return AppLayout.landing(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildFeaturesSection(context),
            _buildCallToActionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary600, AppColors.primary700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user?.name ?? 'User'}!',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      'Ready to participate in secure blockchain voting?',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary100,
                      ),
                    ),
                  ],
                ),
              ),
              if (!Responsive.isMobile(context))
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  ),
                  child: const Icon(
                    Icons.how_to_vote,
                    size: 48,
                    color: AppColors.white,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<ElectionProvider>(
      builder: (context, electionProvider, _) {
        final activeElections = electionProvider.activeElections.length;
        final upcomingElections = electionProvider.upcomingElections.length;
        final completedElections = electionProvider.completedElections.length;

        return Responsive.responsive(
          context: context,
          mobile: Column(
            children: [
              StatCard(
                value: activeElections.toString(),
                label: 'Active Elections',
                icon: Icons.how_to_vote,
                color: AppColors.success,
              ),
              const SizedBox(height: AppDimensions.spacing16),
              StatCard(
                value: upcomingElections.toString(),
                label: 'Upcoming Elections',
                icon: Icons.schedule,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppDimensions.spacing16),
              StatCard(
                value: completedElections.toString(),
                label: 'Completed Elections',
                icon: Icons.check_circle,
                color: AppColors.primary600,
              ),
            ],
          ),
          desktop: Row(
            children: [
              Expanded(
                child: StatCard(
                  value: activeElections.toString(),
                  label: 'Active Elections',
                  icon: Icons.how_to_vote,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: StatCard(
                  value: upcomingElections.toString(),
                  label: 'Upcoming Elections',
                  icon: Icons.schedule,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: StatCard(
                  value: completedElections.toString(),
                  label: 'Completed Elections',
                  icon: Icons.check_circle,
                  color: AppColors.primary600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentElections(BuildContext context) {
    return Consumer<ElectionProvider>(
      builder: (context, electionProvider, _) {
        final elections = electionProvider.elections.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Elections',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            if (elections.isEmpty)
              AppCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingXL),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.ballot,
                          size: 48,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(height: AppDimensions.spacing16),
                        Text(
                          'No elections available',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...elections.map((election) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
                child: AppCard(
                  onTap: () => context.go('${RouteNames.elections}/${election.id}'),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 60,
                        decoration: BoxDecoration(
                          color: election.isActive 
                              ? AppColors.success 
                              : election.isUpcoming 
                                  ? AppColors.warning 
                                  : AppColors.gray400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              election.title,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacing4),
                            Text(
                              election.status.displayName,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: AppDimensions.iconS,
                        color: AppColors.gray400,
                      ),
                    ],
                  ),
                ),
              )),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing16),
        Responsive.responsive(
          context: context,
          mobile: Column(
            children: [
              _buildActionCard(
                context,
                'View Elections',
                'Browse all available elections',
                Icons.how_to_vote,
                () => context.go(RouteNames.elections),
              ),
              const SizedBox(height: AppDimensions.spacing12),
              _buildActionCard(
                context,
                'View Results',
                'Check election results',
                Icons.bar_chart,
                () => context.go(RouteNames.results),
              ),
            ],
          ),
          desktop: Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  'View Elections',
                  'Browse all available elections',
                  Icons.how_to_vote,
                  () => context.go(RouteNames.elections),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: _buildActionCard(
                  context,
                  'View Results',
                  'Check election results',
                  Icons.bar_chart,
                  () => context.go(RouteNames.results),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              icon,
              color: AppColors.primary600,
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
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
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
          const Icon(
            Icons.arrow_forward_ios,
            size: AppDimensions.iconS,
            color: AppColors.gray400,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.responsivePadding(context).horizontal,
        vertical: AppDimensions.paddingXXL,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
        child: Column(
          children: [
            Text(
              'Secure Blockchain Voting',
              style: Responsive.responsiveValue(
                context: context,
                mobile: AppTextStyles.heading2,
                desktop: AppTextStyles.heading1,
              ).copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing24),
            Text(
              'Experience transparent, tamper-proof elections with real-time results',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.gray300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing48),
            Responsive.responsive(
              context: context,
              mobile: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.primary(
                      text: 'Register to Vote',
                      onPressed: () => context.go(RouteNames.voterRegistration),
                      size: AppButtonSize.large,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.secondary(
                      text: 'View Elections',
                      onPressed: () => context.go(RouteNames.elections),
                      size: AppButtonSize.large,
                    ),
                  ),
                ],
              ),
              desktop: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton.primary(
                    text: 'Register to Vote',
                    onPressed: () => context.go(RouteNames.voterRegistration),
                    size: AppButtonSize.large,
                  ),
                  const SizedBox(width: AppDimensions.spacing16),
                  AppButton.secondary(
                    text: 'View Elections',
                    onPressed: () => context.go(RouteNames.elections),
                    size: AppButtonSize.large,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.responsivePadding(context).horizontal,
        vertical: AppDimensions.paddingXXL,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
        child: Column(
          children: [
            Text(
              'Why Choose Bock Vote?',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing48),
            Responsive.responsive(
              context: context,
              mobile: Column(
                children: _buildFeatureCards(),
              ),
              desktop: Row(
                children: _buildFeatureCards()
                    .map((card) => Expanded(child: card))
                    .expand((widget) => [widget, const SizedBox(width: AppDimensions.spacing24)])
                    .take(_buildFeatureCards().length * 2 - 1)
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureCards() {
    return [
      _buildFeatureCard(
        'Secure & Transparent',
        'Blockchain technology ensures tamper-proof voting',
        Icons.security,
      ),
      _buildFeatureCard(
        'Real-time Results',
        'View election results as they happen',
        Icons.speed,
      ),
      _buildFeatureCard(
        'Easy to Use',
        'Simple and intuitive voting interface',
        Icons.touch_app,
      ),
    ];
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return AppCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppColors.primary600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          Text(
            title,
            style: AppTextStyles.heading5.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCallToActionSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.responsivePadding(context).horizontal,
        vertical: AppDimensions.paddingXXL,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary600,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
        child: Column(
          children: [
            Text(
              'Ready to Get Started?',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Join thousands of voters using secure blockchain technology',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary100,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing32),
            AppButton(
              text: 'Get Started Now',
              onPressed: () => context.go(RouteNames.login),
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary600,
              size: AppButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }
}
