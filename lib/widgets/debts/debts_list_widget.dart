import 'package:flutter/material.dart';
import 'package:split_app/models/debt.dart';
import 'package:split_app/widgets/debts/debt_item_widget.dart';

class DebtsListWidget extends StatelessWidget {
  final Future<List<Debt>> debtsFuture;
  final int? currentUserId;

  const DebtsListWidget({
    super.key,
    required this.debtsFuture,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Debt>>(
      future: debtsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading debts: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No debts in this group yet.'),
          );
        } else {
          final debts = snapshot.data!;
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

          return Container(
            height: 170,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: relevantDebts.length,
              itemBuilder: (context, index) {
                final debt = relevantDebts[index];
                return DebtItemWidget(debt: debt, currentUserId: currentUserId);
              },
            ),
          );
        }
      },
    );
  }
}
