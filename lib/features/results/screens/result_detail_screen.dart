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
import '../../../shared/widgets/secondary_button.dart';

// Features
import '../providers/results_provider.dart';

class ResultDetailScreen extends StatefulWidget {
  final String electionId;

  const ResultDetailScreen({super.key, required this.electionId});

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadElectionResults();
    });
  }

  Future<void> _loadElectionResults() async {
    final resultsProvider = Provider.of<ResultsProvider>(context, listen: false);
    await resultsProvider.fetchElectionResults(widget.electionId);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Election Results',
      child: Consumer<ResultsProvider>(
        builder: (context, resultsProvider, _) {
          if (resultsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (resultsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${resultsProvider.error}',
                    style: const TextStyle(color: BockColors.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadElectionResults,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final resultsData = resultsProvider.resultsData;
          if (resultsData.isEmpty) {
            return const Center(
              child: Text('No results available for this election'),
            );
          }

          final String title = resultsData['title'] ?? 'Election Results';
          final String status = resultsData['status'] ?? 'unknown';
          final int totalVotes = resultsData['totalVotes'] ?? 0;
          final String lastUpdated = resultsData['lastUpdated'] != null
              ? _formatDateTime(DateTime.parse(resultsData['lastUpdated']))
              : 'Unknown';
          final List<dynamic> candidates = resultsData['candidates'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/results'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: BockColors.primary700,
                        ),
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Last updated: $lastUpdated',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Summary section
                _buildSummarySection(totalVotes, candidates),
                const SizedBox(height: 32),
                
                // Candidates results section
                _buildCandidatesSection(candidates),
                const SizedBox(height: 32),
                
                // Demographics section if available
                if (resultsData['demographicData'] != null) ...[                  
                  _buildDemographicsSection(resultsData['demographicData']),
                  const SizedBox(height: 32),
                ],
                
                // Actions section
                _buildActionsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    StatusBadgeType badgeType;
    String statusText;

    switch (status) {
      case 'active':
        badgeType = StatusBadgeType.success;
        statusText = 'Active';
        break;
      case 'upcoming':
        badgeType = StatusBadgeType.warning;
        statusText = 'Upcoming';
        break;
      case 'completed':
        badgeType = StatusBadgeType.neutral;
        statusText = 'Completed';
        break;
      default:
        badgeType = StatusBadgeType.info;
        statusText = 'Unknown';
    }

    return StatusBadge(
      text: statusText,
      type: badgeType,
    );
  }

  Widget _buildSummarySection(int totalVotes, List<dynamic> candidates) {
    // Find winner if election is completed
    final resultsProvider = Provider.of<ResultsProvider>(context, listen: false);
    final resultsData = resultsProvider.resultsData;
    final String status = resultsData['status'] ?? 'unknown';
    
    Map<String, dynamic>? winner;
    if (status == 'completed') {
      for (final candidate in candidates) {
        if (candidate['winner'] == true) {
          winner = candidate;
          break;
        }
      }
      
      // If no explicit winner, find the one with most votes
      if (winner == null && candidates.isNotEmpty) {
        candidates.sort((a, b) => (b['votes'] ?? 0).compareTo(a['votes'] ?? 0));
        winner = candidates.first;
      }
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: BockColors.primary700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Votes',
                  totalVotes.toString(),
                  Icons.how_to_vote,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Candidates',
                  candidates.length.toString(),
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Status',
                  status.toUpperCase(),
                  Icons.info,
                ),
              ),
            ],
          ),
          if (winner != null) ...[            
            const Divider(height: 32),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: BockColors.primary100,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events,
                      color: BockColors.primary700,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Winner',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        winner['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: BockColors.primary700,
                        ),
                      ),
                      Text(
                        '${winner['party'] ?? 'Independent'} · ${winner['votes'] ?? 0} votes (${winner['percentage']?.toStringAsFixed(1) ?? 0}%)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: BockColors.primary600, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: BockColors.primary700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildCandidatesSection(List<dynamic> candidates) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Candidate Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: BockColors.primary700,
            ),
          ),
          const SizedBox(height: 16),
          ...candidates.map((candidate) => _buildCandidateResultItem(candidate)),
        ],
      ),
    );
  }

  Widget _buildCandidateResultItem(Map<String, dynamic> candidate) {
    final String name = candidate['name'] ?? 'Unknown';
    final String party = candidate['party'] ?? 'Independent';
    final int votes = candidate['votes'] ?? 0;
    final double percentage = candidate['percentage'] ?? 0.0;
    final bool isWinner = candidate['winner'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: BockColors.primary100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.substring(0, 1),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: BockColors.primary700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isWinner)
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 20,
                      ),
                  ],
                ),
                Text(
                  party,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$votes votes',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicsSection(Map<String, dynamic> demographicData) {
    final List<dynamic> ageGroups = demographicData['ageGroups'] ?? [];
    final List<dynamic> regions = demographicData['regions'] ?? [];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Demographics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: BockColors.primary700,
            ),
          ),
          const SizedBox(height: 16),
          if (ageGroups.isNotEmpty) ...[            
            const Text(
              'Age Groups',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildAgeGroupsChart(ageGroups),
            const SizedBox(height: 24),
          ],
          if (regions.isNotEmpty) ...[            
            const Text(
              'Regional Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildRegionsChart(regions),
          ],
        ],
      ),
    );
  }

  Widget _buildAgeGroupsChart(List<dynamic> ageGroups) {
    return Column(
      children: ageGroups.map((group) {
        final String ageRange = group['group'] ?? 'Unknown';
        final double percentage = group['percentage'] ?? 0.0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  ageRange,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage / 100,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: BockColors.primary600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRegionsChart(List<dynamic> regions) {
    // Calculate total votes for percentage
    int totalVotes = 0;
    for (final region in regions) {
      totalVotes += (region['votes'] as num?)?.toInt() ?? 0;
    }

    return Column(
      children: regions.map((region) {
        final String name = region['name'] ?? 'Unknown';
        final int votes = (region['votes'] as num?)?.toInt() ?? 0;
        final double percentage = totalVotes > 0 ? (votes / totalVotes) * 100 : 0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage / 100,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: BockColors.primary400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  '$votes (${percentage.toStringAsFixed(1)}%)',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionsSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: BockColors.primary700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Verify My Vote',
                  icon: Icons.verified_user,
                  onPressed: _showVerifyVoteDialog,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SecondaryButton(
                  text: 'Export Results',
                  icon: Icons.download,
                  onPressed: _showExportDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVerifyVoteDialog() {
    final TextEditingController receiptController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Your Vote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your vote receipt code to verify that your vote was correctly recorded.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: receiptController,
              decoration: const InputDecoration(
                labelText: 'Receipt Code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _verifyVote(receiptController.text);
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyVote(String receiptCode) async {
    if (receiptCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a receipt code')),
      );
      return;
    }

    final resultsProvider = Provider.of<ResultsProvider>(context, listen: false);
    final bool isVerified = await resultsProvider.verifyVote(receiptCode);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isVerified
                ? 'Vote verified successfully!'
                : 'Failed to verify vote. Please check your receipt code.',
          ),
          backgroundColor: isVerified ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a format to export the election results:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildExportButton('PDF', Icons.picture_as_pdf, 'pdf'),
                _buildExportButton('CSV', Icons.table_chart, 'csv'),
                _buildExportButton('Excel', Icons.table_view, 'xlsx'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(String label, IconData icon, String format) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _exportResults(format);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BockColors.primary100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: BockColors.primary700, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _exportResults(String format) async {
    final resultsProvider = Provider.of<ResultsProvider>(context, listen: false);
    final String? fileName = await resultsProvider.exportResults(widget.electionId, format);

    if (context.mounted) {
      if (fileName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Results exported as $fileName')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export results'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}