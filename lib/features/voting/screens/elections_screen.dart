import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../models/election_model.dart';
import '../providers/election_provider.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/layouts/main_layout.dart';

/// Screen for displaying available elections
class ElectionsScreen extends StatefulWidget {
  const ElectionsScreen({super.key});

  @override
  State<ElectionsScreen> createState() => _ElectionsScreenState();
}

class _ElectionsScreenState extends State<ElectionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadElections();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadElections() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final provider = Provider.of<ElectionProvider>(context, listen: false);
      await provider.fetchElections();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Elections',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadElections,
          tooltip: 'Refresh',
        ),
      ],
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading elections',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              text: 'Try Again',
              onPressed: _loadElections,
              icon: Icons.refresh,
            ),
          ],
        ),
      );
    }

    return Consumer<ElectionProvider>(
      builder: (context, electionProvider, _) {
        final activeElections = electionProvider.elections.where((e) => e.isActive).toList();
        final upcomingElections = electionProvider.elections.where((e) => e.isUpcoming).toList();
        final completedElections = electionProvider.elections.where((e) => e.isCompleted).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Bar
            Container(
              color: AppColors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary700,
                unselectedLabelColor: AppColors.gray600,
                indicatorColor: AppColors.primary600,
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildElectionsList(
                    activeElections,
                    'No active elections',
                    showVoteButton: true,
                  ),
                  _buildElectionsList(
                    upcomingElections,
                    'No upcoming elections',
                    showVoteButton: false,
                  ),
                  _buildElectionsList(
                    completedElections,
                    'No completed elections',
                    showVoteButton: false,
                    showResultsButton: true,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildElectionsList(
    List<ElectionModel> elections,
    String emptyMessage, {
    bool showVoteButton = false,
    bool showResultsButton = false,
  }) {
    if (elections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.how_to_vote_outlined,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      );
    }

    return Responsive.responsive(
      context: context,
      mobile: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        itemCount: elections.length,
        itemBuilder: (context, index) {
          final election = elections[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
            child: _buildElectionCard(
              election,
              showVoteButton: showVoteButton,
              showResultsButton: showResultsButton,
            ),
          );
        },
      ),
      desktop: GridView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppDimensions.paddingM,
          mainAxisSpacing: AppDimensions.paddingM,
          childAspectRatio: 1.2,
        ),
        itemCount: elections.length,
        itemBuilder: (context, index) {
          final election = elections[index];
          return _buildElectionCard(
            election,
            showVoteButton: showVoteButton,
            showResultsButton: showResultsButton,
          );
        },
      ),
    );
  }

  Widget _buildElectionCard(
    ElectionModel election, {
    bool showVoteButton = false,
    bool showResultsButton = false,
  }) {
    StatusBadgeType badgeType;
    String statusText;

    if (election.isActive) {
      badgeType = StatusBadgeType.success;
      statusText = 'Active';
    } else if (election.isUpcoming) {
      badgeType = StatusBadgeType.warning;
      statusText = 'Upcoming';
    } else {
      badgeType = StatusBadgeType.neutral;
      statusText = 'Completed';
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  election.title,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary700,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(
                text: statusText,
                type: badgeType,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),
          
          // Description
          Text(
            election.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacing16),
          
          // Election details
          _buildInfoRow('Start Date', _formatDate(election.startDate)),
          _buildInfoRow('End Date', _formatDate(election.endDate)),
          _buildInfoRow('Candidates', election.candidateIds.length.toString()),
          
          const Spacer(),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showVoteButton)
                AppButton.primary(
                  text: 'Vote Now',
                  onPressed: () => context.go('/voting/confirm/${election.id}'),
                  icon: Icons.how_to_vote,
                ),
              if (showResultsButton) ...[  
                if (showVoteButton) const SizedBox(width: AppDimensions.spacing8),
                AppButton.secondary(
                  text: 'View Results',
                  onPressed: () => context.go('${RouteNames.results}/${election.id}'),
                  icon: Icons.bar_chart,
                ),
              ],
              if (!showVoteButton && !showResultsButton)
                AppButton.text(
                  text: 'View Details',
                  onPressed: () => context.go('${RouteNames.elections}/${election.id}'),
                  icon: Icons.info_outline,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray700,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}