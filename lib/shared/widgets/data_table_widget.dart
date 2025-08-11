import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// A custom data table widget for displaying tabular data
class DataTableWidget<T> extends StatelessWidget {
  final List<DataColumn> columns;
  final List<T> data;
  final DataRow Function(T item, int index) buildRow;
  final bool isLoading;
  final String emptyMessage;
  final Function(int)? onSort;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.data,
    required this.buildRow,
    this.isLoading = false,
    this.emptyMessage = 'No data available',
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: BockColors.gray600,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: columns,
          rows: List.generate(
            data.length,
            (index) => buildRow(data[index], index),
          ),
          headingRowColor: WidgetStateProperty.all(BockColors.gray100),
          dataRowMinHeight: 56,
          dataRowMaxHeight: 56,
          columnSpacing: 24,
          horizontalMargin: 16,
          showCheckboxColumn: false,
          dividerThickness: 1,
          decoration: BoxDecoration(
            border: Border.all(color: BockColors.gray200),
            borderRadius: BorderRadius.circular(8),
          ),
          headingTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: BockColors.gray800,
              ),
          dataTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BockColors.gray800,
              ),
        ),
      ),
    );
  }
}