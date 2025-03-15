import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:split_app/models/user.dart';
import 'package:split_app/resources/user_repository.dart';
import 'package:split_app/widgets/empty_state_widget.dart';
import 'package:split_app/widgets/friend_list_item_widget.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late Future<List<User>> _friendsFuture;
  final TextEditingController _friendUsernameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshFriends();
  }

  @override
  void dispose() {
    _friendUsernameController.dispose();
    super.dispose();
  }

  void _refreshFriends() {
    setState(() {
      _friendsFuture = UserRepository().getFriends();
    });
  }

  Future<void> _handleAddFriend() async {
    final friendUsername = _friendUsernameController.text;
    if (friendUsername.isEmpty) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    _friendUsernameController.clear();

    if (mounted) {
      Navigator.pop(context);
    }

    final result = await UserRepository().addFriend(friendUsername);

    Fluttertoast.showToast(
      msg:
          result.isSuccess
              ? 'Friend added successfully'
              : 'Failed to add friend: ${result.errorMessage}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: result.isSuccess ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    if (result.isSuccess && mounted) {
      _refreshFriends();
    }
  }

  Future<void> _removeFriend(User friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Friend'),
            content: Text(
              'Are you sure you want to remove ${friend.username} from your friends?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final result = await UserRepository().removeFriend(friend.id);

    Fluttertoast.showToast(
      msg:
          result.isSuccess
              ? 'Friend removed successfully'
              : 'Failed to remove friend: ${result.errorMessage}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: result.isSuccess ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    if (result.isSuccess && mounted) {
      _refreshFriends();
    }
  }

  void _addNewFriend() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Friend'),
            content: TextField(
              controller: _friendUsernameController,
              decoration: const InputDecoration(
                labelText: 'Friend\'s Username',
                hintText: 'Enter your friend\'s username',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(onPressed: _handleAddFriend, child: const Text('Add')),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshFriends();
        },
        child: FutureBuilder<List<User>>(
          future: _friendsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.person_add,
                title: 'No Friends Yet',
                message:
                    'Add friends to create groups and split expenses together.',
                actionButton: ElevatedButton.icon(
                  onPressed: _addNewFriend,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Friend'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              );
            } else {
              final friends = snapshot.data!;
              return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return FriendListItem(
                    friend: friend,
                    onRemove: _removeFriend,
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewFriend,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
