import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/enums.dart';
import '../../../providers/search_provider.dart';
import '../../../services/catalog_service.dart';
import '../../../widgets/primary_button.dart';

/// Bottom sheet for tuning radius / price / dietary filters.
class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const FilterSheet(),
    );
  }

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late SearchFilters _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(searchFiltersProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Filters', style: AppTextStyles.headline),
          const SizedBox(height: 20),

          // Radius
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Distance', style: AppTextStyles.subtitle),
              Text('${_draft.radiusKm.toStringAsFixed(0)} km',
                  style: AppTextStyles.caption),
            ],
          ),
          Slider(
            value: _draft.radiusKm,
            min: AppConstants.minRadiusKm,
            max: AppConstants.maxRadiusKm,
            divisions: 24,
            activeColor: AppColors.primary,
            label: '${_draft.radiusKm.toStringAsFixed(0)} km',
            onChanged: (v) =>
                setState(() => _draft = _draft.copyWith(radiusKm: v)),
          ),
          const SizedBox(height: 12),

          // Price
          Text('Price', style: AppTextStyles.subtitle),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: PriceLevel.values.map((p) {
              final selected = _draft.priceLevel == p;
              return ChoiceChip(
                label: Text(p.label),
                selected: selected,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: AppColors.primary,
                onSelected: (_) =>
                    setState(() => _draft = _draft.copyWith(priceLevel: p)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Dietary tags
          Text('Dietary', style: AppTextStyles.subtitle),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.dietaryTags.map((tag) {
              final selected = _draft.dietaryTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: selected,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: AppColors.primary,
                onSelected: (on) {
                  final tags = {..._draft.dietaryTags};
                  on ? tags.add(tag) : tags.remove(tag);
                  setState(() => _draft = _draft.copyWith(dietaryTags: tags));
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => setState(
                      () => _draft = const SearchFilters()),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Apply filters',
                  onPressed: () {
                    ref.read(searchFiltersProvider.notifier).state = _draft;
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
