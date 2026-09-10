import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/mamba_theme.dart';
import '../../domain/entities/meal.dart';
import '../cubit/meals_cubit.dart';
import '../cubit/meals_state.dart';
import '../widgets/add_edit_meal_sheet.dart';

class MealsPage extends StatelessWidget {
  const MealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant, color: MambaTheme.neonGreen, size: 22),
            SizedBox(width: 8),
            Text('REFEIÇÕES & CALORIAS'),
          ],
        ),
      ),
      body: BlocConsumer<MealsCubit, MealsState>(
        listener: (context, state) {
          if (state is MealsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: MambaTheme.alertRed,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MealsLoading && state.meals.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: MambaTheme.neonGreen),
            );
          }

          final selectedDate = state.selectedDate;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Date Navigator Bar
                _DateNavigator(
                  selectedDate: selectedDate,
                  onDateChanged: (newDate) {
                    context.read<MealsCubit>().changeDate(newDate);
                  },
                ),

                const SizedBox(height: 20),

                // 2. Daily Calorie Summary Progress Card
                _CalorieSummaryCard(
                  totalCalories: state.totalCalories,
                  dailyGoal: state.dailyGoal,
                  progress: state.calorieProgress,
                  remaining: state.remainingCalories,
                  onEditGoal: () => _showEditGoalDialog(context, state.dailyGoal),
                ),

                const SizedBox(height: 28),

                // 3. Header & Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Refeições do Dia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MambaTheme.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddMealSheet(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('ADICIONAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MambaTheme.neonGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 4. Meals List
                if (state.meals.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: MambaTheme.cardSurface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.no_meals, color: MambaTheme.textMuted.withValues(alpha: 0.5), size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Nenhuma refeição registrada hoje',
                          style: TextStyle(color: MambaTheme.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.meals.length,
                    itemBuilder: (context, index) {
                      final meal = state.meals[index];
                      return _MealCardTile(
                        meal: meal,
                        onEdit: () => _showEditMealSheet(context, meal),
                        onDelete: () => context.read<MealsCubit>().deleteMeal(meal.id),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddMealSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MambaTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => AddEditMealSheet(
        onSubmit: (name, calories) {
          context.read<MealsCubit>().addMeal(name: name, calories: calories);
        },
      ),
    );
  }

  void _showEditMealSheet(BuildContext context, Meal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MambaTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => AddEditMealSheet(
        initialMeal: meal,
        onSubmit: (name, calories) {
          final updatedMeal = meal.copyWith(name: name, calories: calories);
          context.read<MealsCubit>().updateMeal(updatedMeal);
        },
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, int currentGoal) {
    final controller = TextEditingController(text: currentGoal.toString());
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: MambaTheme.cardSurface,
        title: const Text('Meta Calórica Diária'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: MambaTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Calorias (kcal)',
            suffixText: 'kcal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR', style: TextStyle(color: MambaTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final newGoal = int.tryParse(controller.text.trim());
              if (newGoal != null && newGoal > 0) {
                context.read<MealsCubit>().updateDailyGoal(newGoal);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('SALVAR', style: TextStyle(color: MambaTheme.neonGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DateNavigator({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd/MM/yyyy');
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: MambaTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: MambaTheme.textPrimary),
            onPressed: () {
              onDateChanged(selectedDate.subtract(const Duration(days: 1)));
            },
          ),
          Row(
            children: [
              Text(
                dateFormat.format(selectedDate.toLocal()),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: MambaTheme.textPrimary,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: MambaTheme.neonGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'HOJE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: MambaTheme.neonGreen,
                    ),
                  ),
                ),
              ],
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: MambaTheme.textPrimary),
            onPressed: () {
              onDateChanged(selectedDate.add(const Duration(days: 1)));
            },
          ),
        ],
      ),
    );
  }
}

class _CalorieSummaryCard extends StatelessWidget {
  final int totalCalories;
  final int dailyGoal;
  final double progress;
  final int remaining;
  final VoidCallback onEditGoal;

  const _CalorieSummaryCard({
    required this.totalCalories,
    required this.dailyGoal,
    required this.progress,
    required this.remaining,
    required this.onEditGoal,
  });

  @override
  Widget build(BuildContext context) {
    final percentageText = '${(progress * 100).toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MambaTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MambaTheme.neonGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_fire_department, color: MambaTheme.neonGreen, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'TOTAL CALÓRICO DIÁRIO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: MambaTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: MambaTheme.textMuted),
                onPressed: onEditGoal,
                tooltip: 'Editar Meta',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$totalCalories',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: MambaTheme.textPrimary,
                ),
              ),
              Text(
                ' / $dailyGoal kcal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MambaTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                percentageText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MambaTheme.neonGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: MambaTheme.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(MambaTheme.neonGreen),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Restante para a meta: $remaining kcal',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MambaTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCardTile extends StatelessWidget {
  final Meal meal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MealCardTile({
    required this.meal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: MambaTheme.neonGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.fastfood, color: MambaTheme.neonGreen, size: 20),
        ),
        title: Text(
          meal.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: MambaTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          timeFormat.format(meal.createdAt.toLocal()),
          style: const TextStyle(fontSize: 12, color: MambaTheme.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: MambaTheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${meal.calories} kcal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: MambaTheme.neonGold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: MambaTheme.textSecondary),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: MambaTheme.alertRed),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
