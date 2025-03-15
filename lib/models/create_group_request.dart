class CreateGroupRequest {
  final String groupname;
  final List<int> memberIds;

  CreateGroupRequest({required this.groupname, this.memberIds = const []});

  Map<String, dynamic> toJson() {
    return {'groupname': groupname, 'memberIds': memberIds};
  }
}
