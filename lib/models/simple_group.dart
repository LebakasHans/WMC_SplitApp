class SimpleGroup {
  final int id;
  final String groupName;
  final double balance;

  SimpleGroup({
    required this.id,
    required this.groupName,
    required this.balance,
  });

  factory SimpleGroup.fromJson(Map<String, dynamic> json) {
    return SimpleGroup(
      id: json['id'] as int,
      groupName: json['groupname'] as String,
      balance: json['balance'] as double,
    );
  }
}
