import 'package:flutter/material.dart';
import 'package:split_app/models/debt.dart';
import 'package:split_app/widgets/debts/debt_item_widget.dart';

class DebtsListWidget extends StatelessWidget {
  final List<Debt> debts;
  final int? currentUserId;

  const DebtsListWidget({
    super.key,
    required this.debts,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final relevantDebts =
        debts
            .where(
              (debt) =>
                  debt.creditor.id == currentUserId ||
                  debt.debtor.id == currentUserId,
            )
            .toList();

    if (relevantDebts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No active debts with you in this group.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: relevantDebts.length,
        itemBuilder: (context, index) {
          final debt = relevantDebts[index];
          return DebtItemWidget(debt: debt, currentUserId: currentUserId);
        },
      ),
    );
  }
}
