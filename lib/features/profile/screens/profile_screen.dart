import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../core/constants/route_names.dart';

// Features
import '../../../data/providers/auth_provider.dart';

// Presentation
import '../../../presentation/widgets/layout/app_layout.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

/// Profile screen for viewing and editing user profile information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return AppLayout(
      title: 'Profile',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => authProvider.refreshUser(),
          tooltip: 'Refresh Profile',
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.padding),
            _buildProfileHeader(user),
            const SizedBox(height: AppDimensions.padding * 2),
            _buildProfileDetails(user),
            const SizedBox(height: AppDimensions.padding * 2),
            _buildActions(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(dynamic user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.padding),
          Text(
            user.name,
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: AppDimensions.padding / 2),
          Text(
            user.email,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.padding / 2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.padding,
              vertical: AppDimensions.padding / 4,
            ),
            decoration: BoxDecoration(
              color: user.isAdmin ? AppColors.success.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            child: Text(
              user.isAdmin ? 'Administrator' : 'Voter',
              style: AppTextStyles.caption.copyWith(
                color: user.isAdmin ? AppColors.success : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileDetails(dynamic user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: AppTextStyles.heading3,
            ),
            const Divider(),
            const SizedBox(height: AppDimensions.padding),
            _buildInfoRow('User ID', user.id),
            _buildInfoRow('Name', user.name),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Role', user.isAdmin ? 'Administrator' : 'Voter'),
            if (user.voterId != null && user.voterId.isNotEmpty)
              _buildInfoRow('Voter ID', user.voterId),
            _buildInfoRow('Account Created', _formatDate(user.createdAt)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Actions',
              style: AppTextStyles.heading3,
            ),
            const Divider(),
            const SizedBox(height: AppDimensions.padding),
            AppButton(
              text: 'Edit Profile',
              icon: Icons.edit,
              onPressed: () => Navigator.of(context).pushNamed(RouteNames.editProfile),
              type: AppButtonType.secondary,
              isFullWidth: true,
            ),
            const SizedBox(height: AppDimensions.padding),
            AppButton(
              text: 'Change Password',
              icon: Icons.lock_outline,
              onPressed: () => Navigator.of(context).pushNamed(RouteNames.changePassword),
              type: AppButtonType.secondary,
              isFullWidth: true,
            ),
            const SizedBox(height: AppDimensions.padding),
            AppButton(
              text: 'Logout',
              icon: Icons.logout,
              onPressed: _handleLogout,
              type: AppButtonType.text,
              isFullWidth: true,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    
    try {
      final DateTime dateTime = date is DateTime 
          ? date 
          : DateTime.parse(date.toString());
      
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }
  
  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(RouteNames.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}