import 'package:flutter/material.dart';
import 'package:split_app/models/simple_group.dart';

class GroupListItem extends StatelessWidget {
  final SimpleGroup group;
  final VoidCallback? onTap;

  const GroupListItem({super.key, required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    final double balance = group.balance;
    final bool isPositive = balance >= 0;
    final String balanceText =
        isPositive
            ? 'You get ${balance.abs().toStringAsFixed(2)}€'
            : 'You owe ${balance.abs().toStringAsFixed(2)}€';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.group)),
        title: Text(
          group.groupName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          balanceText,
          style: TextStyle(
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
