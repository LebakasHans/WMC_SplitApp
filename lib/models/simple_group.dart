class SimpleGroup {
  final int id;
  final String groupName;
  final double balance;

  const SimpleGroup({
    required this.id,
    required this.groupName,
    required this.balance,
  });

  SimpleGroup copyWith({int? id, String? groupName, double? balance}) {
    return SimpleGroup(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      balance: balance ?? this.balance,
    );
  }

  factory SimpleGroup.fromJson(Map<String, dynamic> json) {
    return SimpleGroup(
      id: json['id'] ?? 0,
      groupName: json['groupname'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }
}
