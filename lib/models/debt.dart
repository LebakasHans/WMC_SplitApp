class Debt {
  final UserDto creditor;
  final UserDto debtor;
  final double amount;

  Debt({required this.creditor, required this.debtor, required this.amount});

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      creditor: UserDto.fromJson(json['creditor'] ?? {}),
      debtor: UserDto.fromJson(json['debtor'] ?? {}),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class UserDto {
  final int id;
  final String username;

  UserDto({required this.id, required this.username});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(id: json['id'] ?? 0, username: json['username'] ?? '');
  }
}
