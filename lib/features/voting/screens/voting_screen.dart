import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Core
import '../../../core/theme/colors.dart';
import '../../../core/constants/app_constants.dart';

// Shared
import '../../../shared/layouts/main_layout.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/primary_button.dart';

// Features
import '../../../data/providers/auth_provider.dart';
import '../providers/election_provider.dart';
import '../models/election_model.dart';
import '../models/candidate_model.dart';

class VotingScreen extends StatelessWidget {
  const VotingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the content with AuthProvider consumer to make it available to the widget tree
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return const _VotingScreenContent();
      },
    );
  }
}

class _VotingScreenContent extends StatefulWidget {
  const _VotingScreenContent();

  @override
  State<_VotingScreenContent> createState() => _VotingScreenContentState();
}

class _VotingScreenContentState extends State<_VotingScreenContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
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
    final electionProvider = Provider.of<ElectionProvider>(context, listen: false);
    await electionProvider.fetchElections();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Elections & Voting',
      child: Consumer<ElectionProvider>(
        builder: (context, electionProvider, _) {
          if (electionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (electionProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${electionProvider.error}',
                    style: const TextStyle(color: BockColors.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadElections,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final elections = electionProvider.elections;
          final activeElections = elections.where((e) => e.isActive).toList();
          final upcomingElections = elections.where((e) => e.isUpcoming).toList();
          final completedElections = elections.where((e) => e.isCompleted).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Elections & Voting',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: BockColors.primary700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'View and participate in elections',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Active'),
                        Tab(text: 'Upcoming'),
                        Tab(text: 'Completed'),
                      ],
                      labelColor: BockColors.primary700,
                      unselectedLabelColor: Colors.black54,
                      indicatorColor: BockColors.primary600,
                      indicatorWeight: 3,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildElectionsList(
                      activeElections,
                      'No active elections',
                      showCandidates: true,
                    ),
                    _buildElectionsList(
                      upcomingElections,
                      'No upcoming elections',
                      showCandidates: false,
                    ),
                    _buildElectionsList(
                      completedElections,
                      'No completed elections',
                      showCandidates: false,
                      showResults: true,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildElectionsList(
    List<ElectionModel> elections,
    String emptyMessage, {
    bool showCandidates = false,
    bool showResults = false,
  }) {
    if (elections.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      itemCount: elections.length,
      itemBuilder: (context, index) {
        final election = elections[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildElectionCard(
            election,
            showCandidates: showCandidates,
            showResults: showResults,
          ),
        );
      },
    );
  }

  Widget _buildElectionCard(
    ElectionModel election, {
    bool showCandidates = false,
    bool showResults = false,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      election.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: BockColors.primary700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      election.description,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                text: statusText,
                type: badgeType,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(Icons.calendar_today, 'Start: ${_formatDate(election.startDate)}'),
              const SizedBox(width: 24),
              _buildInfoItem(Icons.event, 'End: ${_formatDate(election.endDate)}'),
            ],
          ),
          if (showCandidates) ...[            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildCandidatesSection(election),
          ] else if (showResults) ...[            
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: PrimaryButton(
                text: 'View Results',
                onPressed: () => context.go('/results/${election.id}'),
                icon: Icons.bar_chart,
              ),
            ),
          ] else ...[            
            const SizedBox(height: 16),
            Text(
              'Starts in ${_getDaysUntil(election.startDate)} days',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: BockColors.warning,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildCandidatesSection(ElectionModel election) {
    return Consumer2<ElectionProvider, AuthProvider>(
      builder: (context, electionProvider, authProvider, _) {
        if (electionProvider.isCandidatesLoading) {
          return const Center(
            heightFactor: 2,
            child: CircularProgressIndicator(),
          );
        }

        final candidates = electionProvider.getCandidatesForElection(election.id);
        final userVote = electionProvider.getUserVoteForElection(
          election.id,
          authProvider.currentUser?.id ?? '',
        );

        if (candidates.isEmpty) {
          return const Center(
            heightFactor: 2,
            child: Text('No candidates available for this election'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Candidates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BockColors.primary700,
                  ),
                ),
                if (userVote != null)
                  StatusBadge(
                    text: 'You have voted',
                    type: StatusBadgeType.success,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: candidates.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final candidate = candidates[index];
                final isSelected = userVote?.candidateId == candidate.id;
                
                return _buildCandidateCard(
                  candidate,
                  election,
                  isSelected: isSelected,
                  isDisabled: userVote != null,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCandidateCard(
    CandidateModel candidate,
    ElectionModel election, {
    bool isSelected = false,
    bool isDisabled = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? BockColors.primary600 : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? BockColors.primary200.withOpacity(0.2) : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () => context.go('/voting/confirm/${election.id}/${candidate.id}'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Candidate photo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: candidate.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            candidate.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey,
                        ),
                ),
                const SizedBox(width: 16),
                // Candidate info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BockColors.primary700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidate.party,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        candidate.biography ?? 'No biography available',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Vote button or indicator
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: BockColors.success,
                    size: 28,
                  )
                else if (!isDisabled)
                  ElevatedButton(
                    onPressed: () =>
                        context.go('/voting/confirm/${election.id}/${candidate.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BockColors.primary600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Vote'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    return date.difference(now).inDays;
  }
}