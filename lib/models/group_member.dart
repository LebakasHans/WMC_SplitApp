class GroupMember {
  final int id;
  final String username;

  GroupMember({required this.id, required this.username});

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as int,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username};
  }
}
