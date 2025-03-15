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
    final bool isCreditor = debt.creditor.id == currentUserId;
    final String otherPersonName =
        isCreditor ? debt.debtor.username : debt.creditor.username;

    final cardColor =
        isCreditor
            ? Theme.of(context).colorScheme.primaryContainer.withAlpha(180)
            : Theme.of(context).colorScheme.errorContainer.withAlpha(180);
    final textColor =
        isCreditor
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      margin: const EdgeInsets.all(4),
      child: Container(
        width: 170,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              otherPersonName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.clip,
            ),
            const SizedBox(height: 6),
            Text(
              isCreditor ? "Owes you" : "You owe",
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            Text(
              "${debt.amount.toStringAsFixed(2)}€",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
