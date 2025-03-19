import 'package:flutter/material.dart';
import 'package:split_app/models/expense.dart';
import 'package:split_app/widgets/expenses/expense_item_widget.dart';
import 'package:intl/intl.dart';

class ExpensesListWidget extends StatelessWidget {
  final List<Expense> expenses;
  final int? currentUserId;
  final Future<void> Function() onRefresh;

  const ExpensesListWidget({
    super.key,
    required this.expenses,
    required this.currentUserId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No expenses in this group yet.'));
    }

    final groupedExpenses = <String, List<Expense>>{};
    for (var expense in expenses) {
      final monthYearKey = DateFormat('MMMM yyyy').format(expense.date);
      groupedExpenses.putIfAbsent(monthYearKey, () => []).add(expense);
    }

    final sortedKeys =
        groupedExpenses.keys.toList()..sort((a, b) {
          final aDate = DateFormat('MMMM yyyy').parse(a);
          final bDate = DateFormat('MMMM yyyy').parse(b);
          return bDate.compareTo(aDate);
        });

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final monthYearKey = sortedKeys[index];
        final monthExpenses = groupedExpenses[monthYearKey]!;
        monthExpenses.sort((a, b) => b.date.compareTo(a.date));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  monthYearKey,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            ...monthExpenses.map(
              (expense) => ExpenseItemWidget(
                expense: expense,
                currentUserId: currentUserId,
                showDayMonth: true,
              ),
            ),
          ],
        );
      },
    );
  }
}
