import 'package:flutter/material.dart';
import 'package:split_app/models/expense.dart';
import 'package:split_app/widgets/expenses/expense_item_widget.dart';

class ExpensesListWidget extends StatelessWidget {
  final Future<List<Expense>> expensesFuture;
  final int? currentUserId;
  final Future<void> Function() onRefresh;

  const ExpensesListWidget({
    super.key,
    required this.expensesFuture,
    required this.currentUserId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Expense>>(
      future: expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No expenses in this group yet.'));
        } else {
          final expenses = snapshot.data!;
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ExpenseItemWidget(
                  expense: expense,
                  currentUserId: currentUserId,
                );
              },
            ),
          );
        }
      },
    );
  }
}
