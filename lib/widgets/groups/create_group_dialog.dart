import 'package:flutter/material.dart';
import 'package:split_app/models/user.dart';

class CreateGroupDialog extends StatefulWidget {
  final List<User> friends;
  final Function(String groupName, List<int> selectedFriendIds) onSubmit;

  const CreateGroupDialog({
    super.key,
    required this.friends,
    required this.onSubmit,
  });

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final TextEditingController _groupNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<int> _selectedFriendIds = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Group'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'Enter a name for your group',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Friends to Group:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (widget.friends.isEmpty)
                const Text('You have no friends yet.'),
              ...widget.friends.map(
                (friend) => CheckboxListTile(
                  title: Text(friend.username),
                  value: _selectedFriendIds.contains(friend.id),
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedFriendIds.add(friend.id);
                      } else {
                        _selectedFriendIds.remove(friend.id);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(_groupNameController.text, _selectedFriendIds);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
