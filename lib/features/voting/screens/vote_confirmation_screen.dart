import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Core
import '../../../core/theme/colors.dart';
import '../../../core/constants/app_constants.dart';

// Shared
import '../../../shared/layouts/main_layout.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';

// Features
import '../../../data/providers/auth_provider.dart';
import '../providers/election_provider.dart';
import '../models/election_model.dart';
import '../models/candidate_model.dart';
import '../models/vote_model.dart';

class VoteConfirmationScreen extends StatefulWidget {
  final String electionId;
  final String candidateId;

  const VoteConfirmationScreen({
    super.key,
    required this.electionId,
    required this.candidateId,
  });

  @override
  State<VoteConfirmationScreen> createState() => _VoteConfirmationScreenState();
}

class _VoteConfirmationScreenState extends State<VoteConfirmationScreen> {
  bool _isConfirming = false;
  bool _isVoteSubmitted = false;
  String? _receiptCode;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final electionProvider = Provider.of<ElectionProvider>(context, listen: false);
    await electionProvider.fetchElections();
    await electionProvider.fetchCandidatesForElection(widget.electionId);
  }

  Future<void> _confirmVote() async {
    setState(() {
      _isConfirming = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final electionProvider = Provider.of<ElectionProvider>(context, listen: false);

    try {
      final userId = authProvider.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final success = await electionProvider.castVote(
        userId,
        widget.electionId,
        widget.candidateId,
      );

      if (success) {
        // Get the vote receipt
        final userVote = electionProvider.getUserVoteForElection(userId, widget.electionId);
        setState(() {
          _isVoteSubmitted = true;
          _receiptCode = userVote?.receiptCode;
        });
      } else {
        throw Exception('Failed to cast vote');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isConfirming = false;
      });
    }
  }

  void _copyReceiptToClipboard() {
    if (_receiptCode != null) {
      Clipboard.setData(ClipboardData(text: _receiptCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt code copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Vote Confirmation',
      child: Consumer2<ElectionProvider, AuthProvider>(
        builder: (context, electionProvider, authProvider, _) {
          if (electionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final election = electionProvider.getElectionById(widget.electionId);
          final candidate = electionProvider.getCandidateById(widget.candidateId);

          if (election == null || candidate == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Error: Election or candidate not found',
                    style: TextStyle(color: BockColors.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/voting'),
                    child: const Text('Back to Elections'),
                  ),
                ],
              ),
            );
          }

          // Check if user already voted in this election
          final userVote = electionProvider.getUserVoteForElection(
            widget.electionId,
            authProvider.currentUser?.id ?? '',
          );

          if (userVote != null && !_isVoteSubmitted) {
            return _buildAlreadyVotedView(userVote, election, candidate);
          }

          return _isVoteSubmitted
              ? _buildVoteSuccessView(election, candidate)
              : _buildConfirmationView(election, candidate);
        },
      ),
    );
  }

  Widget _buildConfirmationView(ElectionModel election, CandidateModel candidate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.how_to_vote,
                size: 64,
                color: BockColors.primary600,
              ),
              const SizedBox(height: 24),
              const Text(
                'Confirm Your Vote',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: BockColors.primary700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please review your selection before confirming your vote',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomCard(
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
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'You are voting for:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
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
                                candidate.position,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[                
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BockColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: BockColors.error),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Error: $_errorMessage',
                          style: const TextStyle(color: BockColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              const Text(
                'Important: Once confirmed, your vote cannot be changed.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: BockColors.warning,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Cancel',
                      onPressed: () => context.go('/voting'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Confirm Vote',
                      onPressed: _confirmVote,
                      isLoading: _isConfirming,
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

  Widget _buildVoteSuccessView(ElectionModel election, CandidateModel candidate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: BockColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: BockColors.success,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Vote Successfully Submitted!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: BockColors.primary700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Thank you for participating in this election',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vote Receipt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: BockColors.primary700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Keep this receipt code to verify your vote later',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _receiptCode ?? 'Receipt code not available',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: _copyReceiptToClipboard,
                            tooltip: 'Copy to clipboard',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vote Details:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Election', election.title),
                    _buildInfoRow('Candidate', candidate.name),
                    _buildInfoRow('Party', candidate.party),
                    _buildInfoRow(
                      'Date',
                      DateTime.now().toString().split(' ')[0],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Return to Dashboard',
                onPressed: () => context.go('/'),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyVotedView(VoteModel vote, ElectionModel election, CandidateModel candidate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: BockColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info,
                  size: 64,
                  color: BockColors.warning,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'You Have Already Voted',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: BockColors.primary700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You have already cast your vote in this election',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Vote',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: BockColors.primary700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Election', election.title),
                    _buildInfoRow('Receipt Code', vote.receiptCode ?? 'Not available'),
                    _buildInfoRow(
                      'Date',
                      vote.timestamp.toString().split(' ')[0],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'View Results',
                      onPressed: () => context.go('/results/${election.id}'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Return to Elections',
                      onPressed: () => context.go('/voting'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}