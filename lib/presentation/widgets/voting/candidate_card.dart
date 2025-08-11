import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../data/models/candidate_model.dart';
import '../common/app_card.dart';
import '../common/app_button.dart';

/// Candidate card widget for displaying candidate information
class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final bool isSelected;
  final bool showVoteButton;
  final bool showResults;
  final int? voteCount;
  final double? votePercentage;
  final VoidCallback? onVote;
  final VoidCallback? onTap;

  const CandidateCard({
    super.key,
    required this.candidate,
    this.isSelected = false,
    this.showVoteButton = false,
    this.showResults = false,
    this.voteCount,
    this.votePercentage,
    this.onVote,
    this.onTap,
  });

  /// Voting card constructor
  const CandidateCard.voting({
    super.key,
    required this.candidate,
    this.isSelected = false,
    this.onVote,
    this.onTap,
  }) : showVoteButton = true,
       showResults = false,
       voteCount = null,
       votePercentage = null;

  /// Results card constructor
  const CandidateCard.results({
    super.key,
    required this.candidate,
    this.voteCount,
    this.votePercentage,
    this.onTap,
  }) : isSelected = false,
       showVoteButton = false,
       showResults = true,
       onVote = null;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      isSelected: isSelected,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCandidateHeader(),
          const SizedBox(height: AppDimensions.spacing12),
          _buildCandidateInfo(),
          if (showResults) ...[
            const SizedBox(height: AppDimensions.spacing16),
            _buildResultsInfo(),
          ],
          if (showVoteButton) ...[
            const SizedBox(height: AppDimensions.spacing16),
            _buildVoteButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildCandidateHeader() {
    return Row(
      children: [
        _buildCandidateAvatar(),
        const SizedBox(width: AppDimensions.spacing16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                candidate.name,
                style: AppTextStyles.heading5.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                candidate.party ?? 'Independent',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
        if (isSelected)
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingXS),
            decoration: BoxDecoration(
              color: AppColors.primary600,
              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.white,
              size: AppDimensions.iconS,
            ),
          ),
      ],
    );
  }

  Widget _buildCandidateAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        image: candidate.photoUrl != null
            ? DecorationImage(
                image: NetworkImage(candidate.photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: candidate.photoUrl == null
          ? Center(
              child: Text(
                candidate.name.substring(0, 1).toUpperCase(),
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCandidateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (candidate.description != null) ...[
          Text(
            candidate.description!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray700,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacing8),
        ],
        if (candidate.experience != null) ...[
          _buildInfoRow(Icons.work, 'Experience', candidate.experience!),
        ],
        if (candidate.education != null) ...[
          _buildInfoRow(Icons.school, 'Education', candidate.education!),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconS,
            color: AppColors.gray500,
          ),
          const SizedBox(width: AppDimensions.spacing8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$label: ',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray700,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Votes Received',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              Text(
                '${voteCount ?? 0}',
                style: AppTextStyles.heading5.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (votePercentage ?? 0) / 100,
                  backgroundColor: AppColors.gray200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary600,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing8),
              Text(
                '${(votePercentage ?? 0).toStringAsFixed(1)}%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton() {
    return SizedBox(
      width: double.infinity,
      child: AppButton.primary(
        text: isSelected ? 'Selected' : 'Vote for ${candidate.name}',
        onPressed: isSelected ? null : onVote,
        icon: isSelected ? Icons.check : Icons.how_to_vote,
      ),
    );
  }
}

/// Compact candidate card for lists
class CompactCandidateCard extends StatelessWidget {
  final Candidate candidate;
  final bool isSelected;
  final VoidCallback? onTap;

  const CompactCandidateCard({
    super.key,
    required this.candidate,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.outlined(
      isSelected: isSelected,
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              image: candidate.photoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(candidate.photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: candidate.photoUrl == null
                ? Center(
                    child: Text(
                      candidate.name.substring(0, 1).toUpperCase(),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.gray600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (candidate.party != null)
                  Text(
                    candidate.party!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle,
              color: AppColors.primary600,
              size: AppDimensions.iconM,
            ),
        ],
      ),
    );
  }
}
