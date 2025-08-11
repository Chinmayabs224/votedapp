import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../navigation/admin_navigation.dart';

/// Admin Users Screen
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = true;
  List<User> _users = [];
  String _searchQuery = '';
  UserRole? _filterRole;
  UserStatus? _filterStatus;
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock user data
    final mockUsers = [
      User(
        id: '1',
        email: 'admin@example.com',
        name: 'Admin User',
        role: UserRole.admin,
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      User(
        id: '2',
        email: 'voter1@example.com',
        name: 'John Doe',
        role: UserRole.voter,
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 50)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      User(
        id: '3',
        email: 'voter2@example.com',
        name: 'Jane Smith',
        role: UserRole.voter,
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      User(
        id: '4',
        email: 'candidate1@example.com',
        name: 'Robert Johnson',
        role: UserRole.candidate,
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      User(
        id: '5',
        email: 'candidate2@example.com',
        name: 'Emily Davis',
        role: UserRole.candidate,
        status: UserStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      User(
        id: '6',
        email: 'moderator@example.com',
        name: 'Michael Wilson',
        role: UserRole.moderator,
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      User(
        id: '7',
        email: 'inactive@example.com',
        name: 'Sarah Brown',
        role: UserRole.voter,
        status: UserStatus.inactive,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      User(
        id: '8',
        email: 'suspended@example.com',
        name: 'David Miller',
        role: UserRole.voter,
        status: UserStatus.suspended,
        createdAt: DateTime.now().subtract(const Duration(days: 80)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
    
    setState(() {
      _users = mockUsers;
      _isLoading = false;
    });
  }
  
  List<User> get _filteredUsers {
    return _users.where((user) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Apply role filter
      final matchesRole = _filterRole == null || user.role == _filterRole;
      
      // Apply status filter
      final matchesStatus = _filterStatus == null || user.status == _filterStatus;
      
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: RouteNames.adminUsers,
      title: 'User Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadUsers,
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
            child: FloatingActionButton(
              onPressed: () {
                // Show dialog to add new user
                _showAddUserDialog();
              },
              child: const Icon(Icons.add),
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
          _buildUsersTable(),
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
                  hintText: 'Search by name or email',
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
                child: _buildRoleDropdown(),
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
                    _filterRole = null;
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
  
  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<UserRole?>(
      decoration: const InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(),
      ),
      value: _filterRole,
      onChanged: (UserRole? newValue) {
        setState(() {
          _filterRole = newValue;
        });
      },
      items: [
        const DropdownMenuItem<UserRole?>(
          value: null,
          child: Text('All Roles'),
        ),
        ...UserRole.values.map((role) {
          return DropdownMenuItem<UserRole>(
            value: role,
            child: Text(role.displayName),
          );
        }),
      ],
    );
  }
  
  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<UserStatus?>(
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      value: _filterStatus,
      onChanged: (UserStatus? newValue) {
        setState(() {
          _filterStatus = newValue;
        });
      },
      items: [
        const DropdownMenuItem<UserStatus?>(
          value: null,
          child: Text('All Statuses'),
        ),
        ...UserStatus.values.map((status) {
          return DropdownMenuItem<UserStatus>(
            value: status,
            child: Text(status.displayName),
          );
        }),
      ],
    );
  }
  
  Widget _buildUsersTable() {
    return Expanded(
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Users (${_filteredUsers.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: ${_users.length} users',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DataTableWidget<User>(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Created')),
                  DataColumn(label: Text('Actions')),
                ],
                data: _filteredUsers,
                buildRow: (user, index) {
                  return DataRow(
                    cells: [
                      DataCell(Text(user.name)),
                      DataCell(Text(user.email)),
                      DataCell(Text(user.role.displayName)),
                      DataCell(_buildStatusBadge(user.status)),
                      DataCell(Text(_formatDate(user.createdAt))),
                      DataCell(_buildActionButtons(user)),
                    ],
                  );
                },
                emptyMessage: 'No users found',
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(UserStatus status) {
    StatusBadgeType badgeType;
    
    switch (status) {
      case UserStatus.active:
        badgeType = StatusBadgeType.success;
        break;
      case UserStatus.inactive:
        badgeType = StatusBadgeType.neutral;
        break;
      case UserStatus.suspended:
        badgeType = StatusBadgeType.error;
        break;
      case UserStatus.pending:
        badgeType = StatusBadgeType.warning;
        break;
    }
    
    return StatusBadge(
      text: status.displayName,
      type: badgeType,
    );
  }
  
  Widget _buildActionButtons(User user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          tooltip: 'Edit User',
          onPressed: () => _showEditUserDialog(user),
        ),
        IconButton(
          icon: const Icon(Icons.block, size: 20),
          tooltip: user.status == UserStatus.suspended
              ? 'Unsuspend User'
              : 'Suspend User',
          color: user.status == UserStatus.suspended
              ? BockColors.warning
              : null,
          onPressed: () => _toggleUserSuspension(user),
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 20),
          tooltip: 'Delete User',
          color: BockColors.error,
          onPressed: () => _showDeleteUserDialog(user),
        ),
      ],
    );
  }
  
  void _showAddUserDialog() {
    // Implementation for adding a new user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: const Text('User creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add user logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User added successfully')),
              );
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }
  
  void _showEditUserDialog(User user) {
    // Implementation for editing a user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Text('Edit form for ${user.name} would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Edit user logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User updated successfully')),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
  
  void _toggleUserSuspension(User user) {
    final newStatus = user.status == UserStatus.suspended
        ? UserStatus.active
        : UserStatus.suspended;
    
    // Implementation for toggling user suspension
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          user.status == UserStatus.suspended
              ? 'Unsuspend User'
              : 'Suspend User',
        ),
        content: Text(
          user.status == UserStatus.suspended
              ? 'Are you sure you want to unsuspend ${user.name}?'
              : 'Are you sure you want to suspend ${user.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Toggle suspension logic
              setState(() {
                final index = _users.indexWhere((u) => u.id == user.id);
                if (index != -1) {
                  _users[index] = user.copyWith(status: newStatus);
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User ${newStatus.value} successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.status == UserStatus.suspended
                  ? BockColors.success
                  : BockColors.error,
            ),
            child: Text(
              user.status == UserStatus.suspended ? 'Unsuspend' : 'Suspend',
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteUserDialog(User user) {
    // Implementation for deleting a user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete user logic
              setState(() {
                _users.removeWhere((u) => u.id == user.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted successfully')),
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