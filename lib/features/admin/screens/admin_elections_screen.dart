import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Core
import '../../../core/theme/colors.dart';
import '../../../core/constants/route_names.dart';

// Shared
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/data_table_widget.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

// Features
import '../navigation/admin_navigation.dart';

// Models

/// Admin Elections Screen
class AdminElectionsScreen extends StatefulWidget {
  const AdminElectionsScreen({super.key});

  @override
  State<AdminElectionsScreen> createState() => _AdminElectionsScreenState();
}

class _AdminElectionsScreenState extends State<AdminElectionsScreen> {
  bool _isLoading = true;
  List<Election> _elections = [];
  String _searchQuery = '';
  ElectionStatus? _filterStatus;
  
  @override
  void initState() {
    super.initState();
    _loadElections();
  }
  
  Future<void> _loadElections() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock election data
    final mockElections = [
      Election(
        id: '1',
        title: 'Student Council Election 2023',
        description: 'Annual election for student council representatives',
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        status: ElectionStatus.active,
        totalVotes: 156,
        candidates: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Election(
        id: '2',
        title: 'Faculty Board Election',
        description: 'Election for faculty board members',
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        status: ElectionStatus.upcoming,
        totalVotes: 0,
        candidates: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Election(
        id: '3',
        title: 'Dormitory Committee Election',
        description: 'Election for dormitory committee representatives',
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
        status: ElectionStatus.completed,
        totalVotes: 89,
        candidates: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Election(
        id: '4',
        title: 'Sports Club Leadership',
        description: 'Election for sports club leadership positions',
        startDate: DateTime.now().subtract(const Duration(days: 20)),
        endDate: DateTime.now().subtract(const Duration(days: 10)),
        status: ElectionStatus.completed,
        totalVotes: 120,
        candidates: 6,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Election(
        id: '5',
        title: 'Student Union President',
        description: 'Election for the student union president',
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        status: ElectionStatus.upcoming,
        totalVotes: 0,
        candidates: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Election(
        id: '6',
        title: 'Library Committee',
        description: 'Election for library committee members',
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 8)),
        status: ElectionStatus.upcoming,
        totalVotes: 0,
        candidates: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Election(
        id: '7',
        title: 'Academic Council',
        description: 'Election for academic council representatives',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        status: ElectionStatus.active,
        totalVotes: 78,
        candidates: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Election(
        id: '8',
        title: 'Cultural Committee',
        description: 'Election for cultural committee members',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().subtract(const Duration(days: 20)),
        status: ElectionStatus.completed,
        totalVotes: 145,
        candidates: 7,
        createdAt: DateTime.now().subtract(const Duration(days: 50)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
    
    setState(() {
      _elections = mockElections;
      _isLoading = false;
    });
  }
  
  List<Election> get _filteredElections {
    return _elections.where((election) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          election.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          election.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Apply status filter
      final matchesStatus = _filterStatus == null || election.status == _filterStatus;
      
      return matchesSearch && matchesStatus;
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: RouteNames.adminElections,
      title: 'Election Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadElections,
        ),
      ],
      child: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                // Navigate to create election screen
                context.go(RouteNames.createElection);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Election'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(),
          const SizedBox(height: 16),
          _buildElectionsTable(),
        ],
      ),
    );
  }
  
  Widget _buildFilters() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CustomTextField(
                  label: 'Search',
                  hintText: 'Search by title or description',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildStatusDropdown(),
              ),
              const SizedBox(width: 16),
              PrimaryButton(
                text: 'Reset',
                icon: Icons.refresh,
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _filterStatus = null;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<ElectionStatus?>(
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      value: _filterStatus,
      onChanged: (ElectionStatus? newValue) {
        setState(() {
          _filterStatus = newValue;
        });
      },
      items: [
        const DropdownMenuItem<ElectionStatus?>(
          value: null,
          child: Text('All Statuses'),
        ),
        ...ElectionStatus.values.map((status) {
          return DropdownMenuItem<ElectionStatus>(
            value: status,
            child: Text(status.displayName),
          );
        }),
      ],
    );
  }
  
  Widget _buildElectionsTable() {
    return Expanded(
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Elections (${_filteredElections.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: ${_elections.length} elections',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DataTableWidget<Election>(
                columns: const [
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Start Date')),
                  DataColumn(label: Text('End Date')),
                  DataColumn(label: Text('Candidates')),
                  DataColumn(label: Text('Votes')),
                  DataColumn(label: Text('Actions')),
                ],
                data: _filteredElections,
                buildRow: (election, index) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              election.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              election.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      DataCell(_buildStatusBadge(election.status)),
                      DataCell(Text(_formatDate(election.startDate))),
                      DataCell(Text(_formatDate(election.endDate))),
                      DataCell(Text('${election.candidates}')),
                      DataCell(Text('${election.totalVotes}')),
                      DataCell(_buildActionButtons(election)),
                    ],
                  );
                },
                emptyMessage: 'No elections found',
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(ElectionStatus status) {
    StatusBadgeType badgeType;
    
    switch (status) {
      case ElectionStatus.active:
        badgeType = StatusBadgeType.success;
        break;
      case ElectionStatus.completed:
        badgeType = StatusBadgeType.neutral;
        break;
      case ElectionStatus.upcoming:
        badgeType = StatusBadgeType.info;
        break;
      case ElectionStatus.cancelled:
        badgeType = StatusBadgeType.error;
        break;
      case ElectionStatus.draft:
        badgeType = StatusBadgeType.warning;
        break;
    }
    
    return StatusBadge(
      text: status.displayName,
      type: badgeType,
    );
  }
  
  Widget _buildActionButtons(Election election) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          tooltip: 'Edit Election',
          onPressed: () => _navigateToEditElection(election),
        ),
        IconButton(
          icon: const Icon(Icons.bar_chart, size: 20),
          tooltip: 'View Results',
          onPressed: () => _navigateToElectionResults(election),
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 20),
          tooltip: 'Delete Election',
          color: BockColors.error,
          onPressed: () => _showDeleteElectionDialog(election),
        ),
      ],
    );
  }
  
  void _navigateToEditElection(Election election) {
    // Navigate to edit election screen
    context.go(RouteNames.editElection.replaceFirst(':id', election.id));
  }
  
  void _navigateToElectionResults(Election election) {
    // Navigate to election results screen
    context.go('${RouteNames.results}/${election.id}');
  }
  
  void _showDeleteElectionDialog(Election election) {
    // Implementation for deleting an election
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Election'),
        content: Text('Are you sure you want to delete "${election.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete election logic
              setState(() {
                _elections.removeWhere((e) => e.id == election.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Election deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BockColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Election Model
class Election {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final ElectionStatus status;
  final int totalVotes;
  final int candidates;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Election({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalVotes,
    required this.candidates,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Election Status
enum ElectionStatus {
  active,
  upcoming,
  completed,
  cancelled,
  draft;

  String get displayName {
    switch (this) {
      case ElectionStatus.active:
        return 'Active';
      case ElectionStatus.upcoming:
        return 'Upcoming';
      case ElectionStatus.completed:
        return 'Completed';
      case ElectionStatus.cancelled:
        return 'Cancelled';
      case ElectionStatus.draft:
        return 'Draft';
    }
  }

  String get value {
    switch (this) {
      case ElectionStatus.active:
        return 'active';
      case ElectionStatus.upcoming:
        return 'upcoming';
      case ElectionStatus.completed:
        return 'completed';
      case ElectionStatus.cancelled:
        return 'cancelled';
      case ElectionStatus.draft:
        return 'draft';
    }
  }

  static ElectionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return ElectionStatus.active;
      case 'upcoming':
        return ElectionStatus.upcoming;
      case 'completed':
        return ElectionStatus.completed;
      case 'cancelled':
        return ElectionStatus.cancelled;
      case 'draft':
        return ElectionStatus.draft;
      default:
        return ElectionStatus.draft;
    }
  }
}