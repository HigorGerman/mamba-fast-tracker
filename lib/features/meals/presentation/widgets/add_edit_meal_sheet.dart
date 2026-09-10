import 'package:flutter/material.dart';
import '../../../../core/theme/mamba_theme.dart';
import '../../domain/entities/meal.dart';

class AddEditMealSheet extends StatefulWidget {
  final Meal? initialMeal;
  final Function(String name, int calories) onSubmit;

  const AddEditMealSheet({
    super.key,
    this.initialMeal,
    required this.onSubmit,
  });

  @override
  State<AddEditMealSheet> createState() => _AddEditMealSheetState();
}

class _AddEditMealSheetState extends State<AddEditMealSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialMeal?.name ?? '');
    _caloriesController = TextEditingController(
      text: widget.initialMeal != null ? widget.initialMeal!.calories.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final calories = int.parse(_caloriesController.text.trim());
      widget.onSubmit(name, calories);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialMeal != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'EDITAR REFEIÇÃO' : 'REGISTRAR REFEIÇÃO',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: MambaTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: MambaTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Meal Name Input
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: MambaTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Nome da Refeição',
                hintText: 'ex: Omelete de Frango com Salada',
                filled: true,
                fillColor: MambaTheme.cardSurface,
                prefixIcon: const Icon(Icons.restaurant_menu, color: MambaTheme.neonGold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome da refeição';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Calories Input
            TextFormField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: MambaTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Calorias (kcal)',
                hintText: 'ex: 450',
                filled: true,
                fillColor: MambaTheme.cardSurface,
                prefixIcon: const Icon(Icons.local_fire_department, color: MambaTheme.neonGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe as calorias';
                }
                final numVal = int.tryParse(value.trim());
                if (numVal == null || numVal <= 0) {
                  return 'Informe um número válido e positivo';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MambaTheme.neonGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isEditing ? 'ATUALIZAR REFEIÇÃO' : 'SALVAR REFEIÇÃO',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
