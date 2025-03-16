import 'package:flutter/material.dart';
import 'package:split_app/models/debt.dart';

class DebtItemWidget extends StatelessWidget {
  final Debt debt;
  final int? currentUserId;

  const DebtItemWidget({
    super.key,
    required this.debt,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isCreditor = debt.creditor.id == currentUserId;
    final isDebtor = debt.debtor.id == currentUserId;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Expanded(
          child: Text(
            isCreditor
                ? '${debt.debtor.username} owes you ${debt.amount.toStringAsFixed(2)}€'
                : isDebtor
                ? 'You owe ${debt.creditor.username} ${debt.amount.toStringAsFixed(2)}€'
                : '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCreditor ? Colors.green : Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
