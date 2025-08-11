import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Core
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routes/route_names.dart';

// Widgets
import '../widgets/custom_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/date_time_picker.dart';

// Features
import '../layouts/admin_layout.dart';

// Models
import '../models/election_type.dart';

// Providers
import '../../../features/election/providers/election_provider.dart';
import '../../../features/election/models/election_create_request.dart';

/// Admin Create Election Screen
class AdminCreateElectionScreen extends StatefulWidget {
  const AdminCreateElectionScreen({super.key});

  @override
  State<AdminCreateElectionScreen> createState() => _AdminCreateElectionScreenState();
}

class _AdminCreateElectionScreenState extends State<AdminCreateElectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  ElectionType _selectedType = ElectionType.general;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createElection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      setState(() {
        _errorMessage = 'Please select a start date';
      });
      return;
    }

    if (_endDate == null) {
      setState(() {
        _errorMessage = 'Please select an end date';
      });
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      setState(() {
        _errorMessage = 'End date must be after start date';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final electionProvider = Provider.of<ElectionProvider>(context, listen: false);
      
      final request = ElectionCreateRequest(
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        type: _selectedType,
      );

      final success = await electionProvider.createElection(request);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Election created successfully')),
          );
          context.go(RouteNames.adminElections);
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to create election';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: RouteNames.createElection,
      title: 'Create Election',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomCard(
                      title: 'Election Details',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            controller: _titleController,
                            label: 'Election Title',
                            hintText: 'Enter election title',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _descriptionController,
                            label: 'Description',
                            hintText: 'Enter election description',
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Election Type',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<ElectionType>(
                            value: _selectedType,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: ElectionType.values.map((type) {
                              return DropdownMenuItem<ElectionType>(
                                value: type,
                                child: Text(type.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomCard(
                      title: 'Election Schedule',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DateTimePicker(
                            label: 'Start Date',
                            selectedDate: _startDate,
                            onDateSelected: (date) {
                              setState(() {
                                _startDate = date;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DateTimePicker(
                            label: 'End Date',
                            selectedDate: _endDate,
                            onDateSelected: (date) {
                              setState(() {
                                _endDate = date;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_errorMessage != null) ...[  
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.go(RouteNames.adminElections),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        PrimaryButton(
                          text: 'Create Election',
                          onPressed: _createElection,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}