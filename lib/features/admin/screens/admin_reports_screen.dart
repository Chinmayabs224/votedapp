import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Core
import '../../../core/theme/colors.dart';
import '../../../core/constants/route_names.dart';

// Shared
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/primary_button.dart';

// Features
import '../navigation/admin_navigation.dart';

/// Admin Reports Screen
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  bool _isLoading = true;
  final List<ReportType> _reportTypes = [
    ReportType.userActivity,
    ReportType.electionParticipation,
    ReportType.votingTrends,
    ReportType.systemUsage,
  ];
  ReportType _selectedReportType = ReportType.userActivity;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  List<Map<String, dynamic>> _reportData = [];
  
  @override
  void initState() {
    super.initState();
    _loadReportData();
  }
  
  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate mock data based on selected report type
    final mockData = _generateMockData();
    
    setState(() {
      _reportData = mockData;
      _isLoading = false;
    });
  }
  
  List<Map<String, dynamic>> _generateMockData() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    final data = <Map<String, dynamic>>[];
    
    switch (_selectedReportType) {
      case ReportType.userActivity:
        // Generate user activity data
        final activities = ['Login', 'Registration', 'Profile Update', 'Password Reset'];
        final roles = ['Voter', 'Candidate', 'Admin', 'Moderator'];
        
        for (int i = 0; i < 20; i++) {
          final date = _dateRange.start.add(Duration(
            days: ((_dateRange.duration.inDays) * (i / 19)).round(),
          ));
          
          data.add({
            'date': date,
            'activity': activities[i % activities.length],
            'count': 50 + (random + i * 7) % 100,
            'role': roles[i % roles.length],
          });
        }
        break;
        
      case ReportType.electionParticipation:
        // Generate election participation data
        final elections = [
          'Student Council Election',
          'Faculty Board Election',
          'Dormitory Committee Election',
          'Sports Club Leadership',
          'Student Union President',
        ];
        
        for (int i = 0; i < elections.length; i++) {
          data.add({
            'election': elections[i],
            'eligible_voters': 500 + (random + i * 13) % 500,
            'actual_voters': 300 + (random + i * 11) % 300,
            'participation_rate': (0.5 + (random + i * 3) % 40 / 100).clamp(0.0, 1.0),
            'date': _dateRange.start.add(Duration(days: i * 7)),
          });
        }
        break;
        
      case ReportType.votingTrends:
        // Generate voting trends data
        final timeSlots = ['Morning (6-12)', 'Afternoon (12-18)', 'Evening (18-24)', 'Night (0-6)'];
        final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        
        for (int i = 0; i < timeSlots.length; i++) {
          for (int j = 0; j < weekdays.length; j++) {
            data.add({
              'time_slot': timeSlots[i],
              'weekday': weekdays[j],
              'votes': 20 + (random + i * j * 5) % 80,
            });
          }
        }
        break;
        
      case ReportType.systemUsage:
        // Generate system usage data
        final features = [
          'Voting Page',
          'Results Page',
          'Registration',
          'Dashboard',
          'Profile Page',
          'Admin Panel',
        ];
        
        for (int i = 0; i < 30; i++) {
          final date = _dateRange.start.add(Duration(days: i));
          if (date.isAfter(_dateRange.end)) continue;
          
          final dayData = <String, dynamic>{
            'date': date,
          };
          
          for (final feature in features) {
            dayData[feature] = 50 + (random + i * feature.length) % 200;
          }
          
          data.add(dayData);
        }
        break;
    }
    
    return data;
  }
  
  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: RouteNames.adminReports,
      title: 'Reports & Analytics',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadReportData,
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportControls(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildReportView(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReportControls() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Settings',
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
                child: _buildReportTypeDropdown(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _buildDateRangePicker(),
              ),
              const SizedBox(width: 16),
              PrimaryButton(
                text: 'Generate Report',
                icon: Icons.bar_chart,
                onPressed: _loadReportData,
              ),
              const SizedBox(width: 8),
              PrimaryButton(
                text: 'Export',
                icon: Icons.download,
                onPressed: _exportReport,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildReportTypeDropdown() {
    return DropdownButtonFormField<ReportType>(
      decoration: const InputDecoration(
        labelText: 'Report Type',
        border: OutlineInputBorder(),
      ),
      value: _selectedReportType,
      onChanged: (ReportType? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedReportType = newValue;
          });
        }
      },
      items: _reportTypes.map((type) {
        return DropdownMenuItem<ReportType>(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
    );
  }
  
  Widget _buildDateRangePicker() {
    final dateFormat = DateFormat('MMM d, yyyy');
    final displayText = '${dateFormat.format(_dateRange.start)} - ${dateFormat.format(_dateRange.end)}';
    
    return InkWell(
      onTap: _selectDateRange,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date Range',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(displayText),
      ),
    );
  }
  
  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: BockColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }
  
  void _exportReport() {
    // Implementation for exporting report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report exported successfully')),
    );
  }
  
  Widget _buildReportView() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedReportType.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Data from ${DateFormat('MMM d, yyyy').format(_dateRange.start)} to ${DateFormat('MMM d, yyyy').format(_dateRange.end)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildReportContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReportContent() {
    if (_reportData.isEmpty) {
      return const Center(
        child: Text('No data available for the selected criteria'),
      );
    }
    
    switch (_selectedReportType) {
      case ReportType.userActivity:
        return _buildUserActivityReport();
      case ReportType.electionParticipation:
        return _buildElectionParticipationReport();
      case ReportType.votingTrends:
        return _buildVotingTrendsReport();
      case ReportType.systemUsage:
        return _buildSystemUsageReport();
    }
  }
  
  Widget _buildUserActivityReport() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart placeholder
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('User Activity Chart'),
            ),
          ),
          const SizedBox(height: 16),
          // Data table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Activity')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Count')),
              ],
              rows: _reportData.map((data) {
                return DataRow(
                  cells: [
                    DataCell(Text(DateFormat('MMM d, yyyy').format(data['date']))),
                    DataCell(Text(data['activity'])),
                    DataCell(Text(data['role'])),
                    DataCell(Text(data['count'].toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildElectionParticipationReport() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart placeholder
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Election Participation Chart'),
            ),
          ),
          const SizedBox(height: 16),
          // Data table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Election')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Eligible Voters')),
                DataColumn(label: Text('Actual Voters')),
                DataColumn(label: Text('Participation Rate')),
              ],
              rows: _reportData.map((data) {
                return DataRow(
                  cells: [
                    DataCell(Text(data['election'])),
                    DataCell(Text(DateFormat('MMM d, yyyy').format(data['date']))),
                    DataCell(Text(data['eligible_voters'].toString())),
                    DataCell(Text(data['actual_voters'].toString())),
                    DataCell(Text('${(data['participation_rate'] * 100).toStringAsFixed(1)}%')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVotingTrendsReport() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart placeholder
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Voting Trends Heatmap'),
            ),
          ),
          const SizedBox(height: 16),
          // Data table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Time Slot')),
                const DataColumn(label: Text('Weekday')),
                const DataColumn(label: Text('Votes')),
              ],
              rows: _reportData.map((data) {
                return DataRow(
                  cells: [
                    DataCell(Text(data['time_slot'])),
                    DataCell(Text(data['weekday'])),
                    DataCell(Text(data['votes'].toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSystemUsageReport() {
    // Get all feature names except 'date'
    final features = _reportData.isNotEmpty
        ? _reportData.first.keys.where((key) => key != 'date').toList()
        : <String>[];
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart placeholder
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('System Usage Chart'),
            ),
          ),
          const SizedBox(height: 16),
          // Data table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Date')),
                ...features.map((feature) => DataColumn(label: Text(feature))),
              ],
              rows: _reportData.map((data) {
                return DataRow(
                  cells: [
                    DataCell(Text(DateFormat('MMM d, yyyy').format(data['date']))),
                    ...features.map((feature) => DataCell(Text(data[feature].toString()))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Report Type
enum ReportType {
  userActivity,
  electionParticipation,
  votingTrends,
  systemUsage;

  String get displayName {
    switch (this) {
      case ReportType.userActivity:
        return 'User Activity';
      case ReportType.electionParticipation:
        return 'Election Participation';
      case ReportType.votingTrends:
        return 'Voting Trends';
      case ReportType.systemUsage:
        return 'System Usage';
    }
  }
}