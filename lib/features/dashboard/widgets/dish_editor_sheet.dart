import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/dish.dart';
import '../../../models/enums.dart';
import '../../../services/mock_data.dart';
import '../../../widgets/primary_button.dart';

/// Add/edit form for a menu item. Returns the composed [Dish] on save.
class DishEditorSheet extends StatefulWidget {
  final String restaurantId;
  final Dish? existing;

  const DishEditorSheet({super.key, required this.restaurantId, this.existing});

  static Future<Dish?> show(
    BuildContext context, {
    required String restaurantId,
    Dish? existing,
  }) {
    return showModalBottomSheet<Dish>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          DishEditorSheet(restaurantId: restaurantId, existing: existing),
    );
  }

  @override
  State<DishEditorSheet> createState() => _DishEditorSheetState();
}

class _DishEditorSheetState extends State<DishEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late DishCategory _category;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _price = TextEditingController(text: e?.price.toStringAsFixed(2) ?? '');
    _category = e?.category ?? DishCategory.food;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final dish = Dish(
      id: widget.existing?.id ?? 'new',
      restaurantId: widget.restaurantId,
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: double.tryParse(_price.text) ?? 0,
      imageUrl: widget.existing?.imageUrl ??
          'https://source.unsplash.com/600x600/?food,${_name.text}',
      category: _category,
      dietaryTags: widget.existing?.dietaryTags ?? const [],
    );
    Navigator.of(context).pop(dish);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? 'Edit dish' : 'Add dish',
                style: AppTextStyles.headline),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(hintText: 'Dish name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Price',
                prefixText: '\$ ',
              ),
              validator: (v) =>
                  (double.tryParse(v ?? '') == null) ? 'Enter a price' : null,
            ),
            const SizedBox(height: 16),
            Text('Category', style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: DishCategory.values.map((c) {
                final selected = _category == c;
                return ChoiceChip(
                  label: Text(c.label),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _category = c),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
                label: isEdit ? 'Save changes' : 'Add to menu',
                onPressed: _save),
          ],
        ),
      ),
    );
  }
}

/// Helper exposing the demo restaurant a dashboard user manages.
String demoOwnedRestaurantId() => MockData.restaurants.first.id;
