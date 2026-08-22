import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/enums.dart';

/// Provider for tracking the current sorting criteria on the Holdings screen.
final sortCriteriaProvider =
    StateProvider<SortCriteria>((ref) => SortCriteria.pnlDesc);

/// Sorting criteria selector bar for the Holdings view.
class SortSelector extends ConsumerWidget {
  const SortSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSort = ref.watch(sortCriteriaProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sort By:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SegmentedButton<SortCriteria>(
            segments: SortCriteria.values
                .map((criteria) => ButtonSegment<SortCriteria>(
                      value: criteria,
                      label: Text(
                        criteria.displayName,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ))
                .toList(),
            selected: {selectedSort},
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.accentBlue.withValues(alpha: 0.2);
                }
                return AppColors.surfaceBackground;
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.accentBlue;
                }
                return AppColors.textSecondary;
              }),
              side: WidgetStateProperty.all(
                const BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            onSelectionChanged: (newSelection) {
              ref.read(sortCriteriaProvider.notifier).state =
                  newSelection.first;
            },
          ),
        ],
      ),
    );
  }
}
