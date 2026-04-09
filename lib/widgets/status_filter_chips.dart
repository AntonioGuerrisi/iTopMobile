import 'package:flutter/material.dart';
import 'package:itop_mobile/l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class StatusFilterChips extends StatelessWidget {
  final Map<String, int> statusCounts;
  final String selectedStatus;
  final ValueChanged<String> onStatusSelected;

  const StatusFilterChips({
    super.key,
    required this.statusCounts,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = statusCounts.values.fold<int>(0, (a, b) => a + b);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildChip(
            context,
            label: AppLocalizations.of(context)!.allStatuses,
            count: totalCount,
            status: 'all',
            color: AppTheme.primaryColor,
          ),
          _buildChip(
            context,
            label: AppLocalizations.of(context)!.newStatus,
            count: statusCounts['new'] ?? 0,
            status: 'new',
            color: AppTheme.statusNew,
          ),
          _buildChip(
            context,
            label: AppLocalizations.of(context)!.assignedStatus,
            count: statusCounts['assigned'] ?? 0,
            status: 'assigned',
            color: AppTheme.statusAssigned,
          ),
          _buildChip(
            context,
            label: AppLocalizations.of(context)!.pendingStatus,
            count: statusCounts['pending'] ?? 0,
            status: 'pending',
            color: AppTheme.statusPending,
          ),
          _buildChip(
            context,
            label: AppLocalizations.of(context)!.resolvedStatus,
            count: statusCounts['resolved'] ?? 0,
            status: 'resolved',
            color: AppTheme.statusResolved,
          ),
          _buildChip(
            context,
            label: AppLocalizations.of(context)!.closedStatus,
            count: statusCounts['closed'] ?? 0,
            status: 'closed',
            color: AppTheme.statusClosed,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required int count,
    required String status,
    required Color color,
  }) {
    final isSelected = selectedStatus == status;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onStatusSelected(status),
        backgroundColor: color.withValues(alpha: 0.1),
        selectedColor: color,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? color : color.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
