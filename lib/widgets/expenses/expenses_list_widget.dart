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

    // Group expenses by month and year
    final groupedExpenses = <String, List<Expense>>{};
    for (var expense in expenses) {
      final monthYearKey = DateFormat(
        'MMMM yyyy',
      ).format(expense.date); // e.g. "January 2025"
      groupedExpenses.putIfAbsent(monthYearKey, () => []).add(expense);
    }

    // Sort the keys (month-year) in descending order (most recent first)
    final sortedKeys =
        groupedExpenses.keys.toList()..sort((a, b) {
          // Parse the month-year strings and compare dates
          final aDate = DateFormat('MMMM yyyy').parse(a);
          final bDate = DateFormat('MMMM yyyy').parse(b);
          return bDate.compareTo(aDate); // Descending order
        });

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final monthYearKey = sortedKeys[index];
          final monthExpenses = groupedExpenses[monthYearKey]!;

          // Sort expenses within the month in descending order (newest first)
          monthExpenses.sort((a, b) => b.date.compareTo(a.date));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month and Year Header
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
              // List of expenses for this month
              ...monthExpenses.map(
                (expense) => ExpenseItemWidget(
                  expense: expense,
                  currentUserId: currentUserId,
                  showDayMonth:
                      true, // Enable showing day and month on each expense
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
