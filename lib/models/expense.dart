class Expense {
  final int id;
  final String description;
  final double amount;
  final int paidById;
  final String paidByName;
  final DateTime date;
  final List<ParticipantShare> participantShares;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidById,
    required this.paidByName,
    required this.date,
    required this.participantShares,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paidById: json['paidById'] ?? 0,
      paidByName: json['paidByName'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      participantShares:
          json['participantShares'] != null
              ? (json['participantShares'] as List)
                  .map((share) => ParticipantShare.fromJson(share))
                  .toList()
              : [],
    );
  }
}

class ParticipantShare {
  final int participantId;
  final double share;

  ParticipantShare({required this.participantId, required this.share});

  factory ParticipantShare.fromJson(Map<String, dynamic> json) {
    return ParticipantShare(
      participantId: json['participantId'] ?? 0,
      share: (json['share'] ?? 0).toDouble(),
    );
  }
}
