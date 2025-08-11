import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Core
import '../../../core/constants/route_names.dart';
import '../../../core/theme/colors.dart';

// Shared
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/data_table_widget.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';

// Features
import '../providers/admin_provider.dart';
import '../models/admin_dashboard_model.dart';
import '../navigation/admin_navigation.dart';

/// Admin Dashboard Screen
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.fetchDashboardData();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: RouteNames.adminDashboard,
      title: 'Admin Dashboard',
      actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadDashboardData();
            },
          ),
        ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
    );
  }
  
  Widget _buildDashboardContent() {
    return Consumer<AdminProvider>(builder: (context, adminProvider, _) {
      if (adminProvider.error != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: BockColors.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: ${adminProvider.error}',
                style: const TextStyle(color: BockColors.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final dashboardData = adminProvider.dashboardData;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCards(dashboardData),
            const SizedBox(height: 24),
            _buildRecentActivitySection(dashboardData),
            const SizedBox(height: 24),
            _buildQuickActionsSection(),
          ],
        ),
      );
    });
  }

  Widget _buildStatCards(AdminDashboardModel dashboardData) {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Total Users',
          value: dashboardData.totalUsers.toString(),
          icon: Icons.people,
          color: BockColors.primary600,
        ),
        _buildStatCard(
          title: 'Total Elections',
          value: dashboardData.totalElections.toString(),
          icon: Icons.how_to_vote,
          color: BockColors.info,
        ),
        _buildStatCard(
          title: 'Active Elections',
          value: dashboardData.activeElections.toString(),
          icon: Icons.event_available,
          color: BockColors.success,
        ),
        _buildStatCard(
          title: 'Total Votes',
          value: dashboardData.totalVotes.toString(),
          icon: Icons.ballot,
          color: BockColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: BockColors.success, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(AdminDashboardModel dashboardData) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DataTableWidget<ActivityItem>(
            columns: const [
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Description')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Status')),
            ],
            data: dashboardData.recentActivity,
            buildRow: (item, index) {
              return DataRow(
                cells: [
                  DataCell(_getActivityTypeIcon(item.type)),
                  DataCell(Text(item.title)),
                  DataCell(Text(_formatDate(item.timestamp))),
                  DataCell(_getActivityStatusBadge(item.type)),
                ],
              );
            },
            emptyMessage: 'No recent activity',
          ),
        ],
      ),
    );
  }

  Widget _getActivityTypeIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'election_created':
        icon = Icons.add_circle;
        color = BockColors.success;
        break;
      case 'election_started':
        icon = Icons.play_circle_filled;
        color = BockColors.primary600;
        break;
      case 'election_ended':
        icon = Icons.stop_circle;
        color = BockColors.warning;
        break;
      case 'user_registered':
        icon = Icons.person_add;
        color = BockColors.info;
        break;
      default:
        icon = Icons.info;
        color = BockColors.gray600;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(_formatActivityType(type)),
      ],
    );
  }

  String _formatActivityType(String type) {
    return type.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  Widget _getActivityStatusBadge(String type) {
    StatusBadgeType badgeType;
    String statusText;

    switch (type) {
      case 'election_created':
        badgeType = StatusBadgeType.info;
        statusText = 'Created';
        break;
      case 'election_started':
        badgeType = StatusBadgeType.success;
        statusText = 'Started';
        break;
      case 'election_ended':
        badgeType = StatusBadgeType.neutral;
        statusText = 'Ended';
        break;
      case 'user_registered':
        badgeType = StatusBadgeType.warning;
        statusText = 'New';
        break;
      default:
        badgeType = StatusBadgeType.info;
        statusText = 'Info';
    }

    return StatusBadge(
      text: statusText,
      type: badgeType,
    );
  }

  Widget _buildQuickActionsSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.verified_user,
                  label: 'Verify Users',
                  onPressed: () => context.go(RouteNames.adminUsers),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.how_to_vote,
                  label: 'Manage Elections',
                  onPressed: () => context.go(RouteNames.adminElections),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.bar_chart,
                  label: 'View Stats',
                  onPressed: () => context.go(RouteNames.adminReports),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.play_circle_filled,
                  label: 'Start Election',
                  onPressed: () => context.go(RouteNames.createElection),
                  isPrimary: true,
                ),
              ),
              const Expanded(child: SizedBox()),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    if (isPrimary) {
      return PrimaryButton(
        text: label,
        icon: icon,
        onPressed: onPressed,
        isFullWidth: true,
      );
    }
    
    return SecondaryButton(
      text: label,
      icon: icon,
      onPressed: onPressed,
      isFullWidth: true,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}