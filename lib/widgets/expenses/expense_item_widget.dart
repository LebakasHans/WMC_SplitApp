import 'package:flutter/material.dart';
import 'package:split_app/models/expense.dart';
import 'package:intl/intl.dart';

class ExpenseItemWidget extends StatelessWidget {
  final Expense expense;
  final int? currentUserId;
  final bool showDayMonth;

  const ExpenseItemWidget({
    super.key,
    required this.expense,
    required this.currentUserId,
    this.showDayMonth = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUserPayer = expense.paidById == currentUserId;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: showDayMonth ? _buildDateWidget(context) : null,
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isUserPayer
              ? 'You paid ${expense.amount.toStringAsFixed(2)}€'
              : '${expense.paidByName} paid ${expense.amount.toStringAsFixed(2)}€',
          style: TextStyle(
            color: isUserPayer ? Colors.green : Colors.grey[600],
          ),
        ),
        trailing: Text(
          _formatShare(expense, currentUserId),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: _getShareColor(expense, currentUserId),
          ),
        ),
      ),
    );
  }

  Widget _buildDateWidget(BuildContext context) {
    final day = expense.date.day.toString();
    final month = DateFormat('MMM').format(expense.date);

    return Container(
      width: 45,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            month,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            day,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatShare(Expense expense, int? currentUserId) {
    if (currentUserId == null) return '';
    final userShareOpt = expense.participantShares.where(
      (share) => share.participantId == currentUserId,
    );

    if (userShareOpt.isEmpty) return '';

    final userShare = userShareOpt.first;
    final amount = userShare.share;

    if (amount == 0.0) return '';

    final amountStr = amount.toStringAsFixed(2);
    final isPayer = expense.paidById == currentUserId;

    if (isPayer) {
      return "You get: $amountStr€";
    } else {
      return "You owe: $amountStr€";
    }
  }

  Color _getShareColor(Expense expense, int? currentUserId) {
    if (currentUserId == null) return Colors.grey;

    final isPayer = expense.paidById == currentUserId;

    return isPayer ? Colors.green : Colors.red;
  }
}
