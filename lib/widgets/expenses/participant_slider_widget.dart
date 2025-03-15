import 'package:flutter/material.dart';
import 'package:split_app/models/group_member.dart';

class ParticipantSliderWidget extends StatelessWidget {
  final GroupMember member;
  final double share;
  final ValueChanged<double> onChanged;
  final double? amount;

  const ParticipantSliderWidget({
    super.key,
    required this.member,
    required this.share,
    required this.onChanged,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                member.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 5,
              child: Slider(
                value: share,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                label: '${(share * 100).toStringAsFixed(0)}%',
                onChanged: onChanged,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${(share * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        if (amount != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Will pay: ${(share * amount!).toStringAsFixed(2)}€',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        const Divider(),
      ],
    );
  }
}
