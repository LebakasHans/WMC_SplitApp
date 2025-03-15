import 'package:flutter/material.dart';
import 'package:split_app/models/expense.dart';

class ExpenseItemWidget extends StatelessWidget {
  final Expense expense;
  final int? currentUserId;

  const ExpenseItemWidget({
    super.key,
    required this.expense,
    required this.currentUserId,
  });

  String _getUserParticipationText(Expense expense, int? currentUserId) {
    if (currentUserId == null) return "Loading...";

    bool isUserPayer = expense.paidById == currentUserId;
    double userShare = 0;
    bool isParticipant = false;

    for (var share in expense.participantShares) {
      if (share.participantId == currentUserId) {
        userShare = share.share;
        isParticipant = true;
        break;
      }
    }

    if (isUserPayer && isParticipant) {
      double netAmount = expense.amount - userShare;
      return "You paid ${expense.amount.toStringAsFixed(2)}€ and owe ${userShare.toStringAsFixed(2)}€ (You get ${netAmount.toStringAsFixed(2)}€)";
    } else if (isUserPayer) {
      return "You paid ${expense.amount.toStringAsFixed(2)}€ (You get ${expense.amount.toStringAsFixed(2)}€)";
    } else if (isParticipant) {
      return "You owe ${userShare.toStringAsFixed(2)}€";
    } else {
      return "You have no part in this expense";
    }
  }

  @override
  Widget build(BuildContext context) {
    final participationText = _getUserParticipationText(expense, currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${expense.amount.toStringAsFixed(2)}€ • ${expense.date.toLocal().toString().split(' ')[0]}",
            ),
            Text(
              participationText,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color:
                    participationText.contains("get")
                        ? Colors.green
                        : participationText.contains("owe")
                        ? Colors.red
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
