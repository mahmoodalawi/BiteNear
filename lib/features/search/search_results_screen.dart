import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/dish_result.dart';
import '../../models/enums.dart';
import '../../providers/location_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/dish_card.dart';
import '../../widgets/dish_preview_sheet.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/results_map.dart';
import '../home/widgets/home_search_bar.dart';
import 'widgets/filter_sheet.dart';

/// Search results with sort chips, filters and a list ⇄ map toggle.
class SearchResultsScreen extends ConsumerStatefulWidget {
  final String initialQuery;
  const SearchResultsScreen({super.key, required this.initialQuery});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late final TextEditingController _searchController;
  bool _mapView = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    // Seed the query provider after the first frame (can't mutate during build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchQueryProvider.notifier).state = widget.initialQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final filters = ref.watch(searchFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: HomeSearchBar(
            controller: _searchController,
            autofocus: widget.initialQuery.isEmpty,
            onSubmitted: (q) =>
                ref.read(searchQueryProvider.notifier).state = q,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Filters',
            icon: Badge(
              isLabelVisible: filters.dietaryTags.isNotEmpty ||
                  filters.priceLevel != PriceLevel.any,
              child: const Icon(Icons.tune_rounded),
            ),
            onPressed: () => FilterSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _SortBar(
            sort: filters.sort,
            onChanged: (s) => ref.read(searchFiltersProvider.notifier).state =
                filters.copyWith(sort: s),
          ),
          Expanded(
            child: results.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    title: 'No dishes found',
                    message:
                        'Try a different term or widen your filters/radius.',
                  );
                }
                return _mapView
                    ? _MapResults(items: items)
                    : _ListResults(items: items);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: results.maybeWhen(
        data: (items) => items.isEmpty
            ? null
            : FloatingActionButton.extended(
                backgroundColor: AppColors.charcoal,
                onPressed: () => setState(() => _mapView = !_mapView),
                icon: Icon(_mapView
                    ? Icons.view_list_rounded
                    : Icons.map_rounded),
                label: Text(_mapView ? 'List' : 'Map'),
              ),
        orElse: () => null,
      ),
    );
  }
}

class _ListResults extends StatelessWidget {
  final List<DishResult> items;
  const _ListResults({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => DishListTile(result: items[i]),
    );
  }
}

class _MapResults extends ConsumerWidget {
  final List<DishResult> items;
  const _MapResults({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final origin = ref.watch(currentLocationProvider).valueOrNull;
    if (origin == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ResultsMap(
      results: items,
      origin: origin,
      onMarkerTap: (r) => DishPreviewSheet.show(context, r),
    );
  }
}

class _SortBar extends StatelessWidget {
  final SortOption sort;
  final ValueChanged<SortOption> onChanged;

  const _SortBar({required this.sort, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Center(child: Text('Sort:', style: AppTextStyles.caption)),
          const SizedBox(width: 8),
          for (final option in SortOption.values) ...[
            ChoiceChip(
              label: Text(option.label),
              selected: sort == option,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: sort == option ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              onSelected: (_) => onChanged(option),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
