import 'package:flutter/material.dart';
import 'package:split_app/models/simple_group.dart';
import 'package:split_app/resources/user_repository.dart';
import 'package:split_app/widgets/empty_state_widget.dart';
import 'package:split_app/widgets/group_list_item_widget.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late Future<List<SimpleGroup>> _groupsFuture;
  final _repository = UserRepository();

  @override
  void initState() {
    super.initState();
    _refreshGroups();
  }

  void _refreshGroups() {
    setState(() {
      _groupsFuture = UserRepository().getGroups();
    });
  }

  void _createNewGroup() {
    // TODO: Implement group creation logic
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Coming Soon'),
            content: const Text('Group creation will be implemented soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
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
                      // TODO: Navigate to group details
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
