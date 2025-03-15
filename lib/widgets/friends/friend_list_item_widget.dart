import 'package:flutter/material.dart';
import 'package:split_app/models/user.dart';

class FriendListItem extends StatelessWidget {
  final User friend;
  final Function(User) onRemove;

  const FriendListItem({
    super.key,
    required this.friend,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: const Icon(Icons.person, color: Colors.deepPurple),
        ),
        title: Text(
          friend.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'remove') {
              onRemove(friend);
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem<String>(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remove Friend'),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }
}
