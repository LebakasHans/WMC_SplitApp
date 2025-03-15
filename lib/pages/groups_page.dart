import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:split_app/models/simple_group.dart';
import 'package:split_app/models/user.dart';
import 'package:split_app/resources/friends_repository.dart';
import 'package:split_app/resources/groups_repository.dart';
import 'package:split_app/widgets/groups/create_group_dialog.dart';
import 'package:split_app/widgets/shared/empty_state_widget.dart';
import 'package:split_app/widgets/groups/group_list_item_widget.dart';
import 'package:split_app/pages/group_detail_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late Future<List<SimpleGroup>> _groupsFuture;
  final _groupsRepository = GroupsRepository();
  final _friendsRepository = FriendsRepository();

  @override
  void initState() {
    super.initState();
    _refreshGroups();
  }

  void _refreshGroups() {
    setState(() {
      _groupsFuture = _groupsRepository.getGroups();
    });
  }

  void _createNewGroup() async {
    List<User> friends = [];
    try {
      friends = await _friendsRepository.getFriends();
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error loading friends: ${e.toString()}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => CreateGroupDialog(
            friends: friends,
            onSubmit: (groupName, selectedFriendIds) async {
              Navigator.pop(context);

              try {
                final result = await _groupsRepository.createGroup(
                  groupName,
                  selectedFriendIds,
                );

                if (result.isSuccess) {
                  Fluttertoast.showToast(
                    msg: 'Group created successfully!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                  _refreshGroups();
                } else {
                  Fluttertoast.showToast(
                    msg: 'Error: ${result.errorMessage ?? "Unknown error"}',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              } catch (e) {
                Fluttertoast.showToast(
                  msg: 'Error creating group: ${e.toString()}',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshGroups();
        },
        child: FutureBuilder<List<SimpleGroup>>(
          future: _groupsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.group_add,
                title: 'No Groups Yet',
                message:
                    'Create new groups with your friends to track shared expenses and split bills easily.',
                actionButton: ElevatedButton.icon(
                  onPressed: _createNewGroup,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Group'),
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
              final groups = snapshot.data!;
              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return GroupListItem(
                    group: group,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupDetailPage(group: group),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewGroup,
        child: const Icon(Icons.add),
      ),
    );
  }
}
