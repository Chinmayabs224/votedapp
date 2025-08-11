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
import '../../voting/providers/election_provider.dart';
import '../../voting/models/election_model.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadElections();
    });
  }

  Future<void> _loadElections() async {
    final electionProvider = Provider.of<ElectionProvider>(context, listen: false);
    await electionProvider.fetchElections();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Election Results',
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
          final completedElections = elections.where((e) => e.isCompleted).toList();
          final activeElections = elections.where((e) => e.isActive).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Election Results',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: BockColors.primary700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'View detailed results for completed and ongoing elections',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                if (completedElections.isNotEmpty) ...[                  
                  const Text(
                    'Completed Elections',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: BockColors.primary700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildElectionsList(completedElections),
                  const SizedBox(height: 32),
                ],
                if (activeElections.isNotEmpty) ...[                  
                  const Text(
                    'Ongoing Elections',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: BockColors.primary700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildElectionsList(activeElections),
                ],
                if (completedElections.isEmpty && activeElections.isEmpty)
                  const Center(
                    heightFactor: 3,
                    child: Text(
                      'No elections with results available',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildElectionsList(List<ElectionModel> elections) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: elections.length,
      itemBuilder: (context, index) {
        final election = elections[index];
        return _buildElectionCard(election);
      },
    );
  }

  Widget _buildElectionCard(ElectionModel election) {
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
      onTap: () => context.go('/results/${election.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  election.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BockColors.primary700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(
                text: statusText,
                type: badgeType,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            election.description,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                election.isCompleted
                    ? 'Ended: ${_formatDate(election.endDate)}'
                    : 'Ends: ${_formatDate(election.endDate)}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              PrimaryButton(
                text: 'View Results',
                onPressed: () => context.go('/results/${election.id}'),
                icon: Icons.bar_chart,
                small: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}