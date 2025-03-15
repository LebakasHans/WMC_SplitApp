class SimpleGroup {
  final int id;
  final String groupName;

  SimpleGroup({required this.id, required this.groupName});

  factory SimpleGroup.fromJson(Map<String, dynamic> json) {
    return SimpleGroup(
      id: json['id'] as int,
      groupName: json['groupName'] as String,
    );
  }
}
