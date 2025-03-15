class ExpenseDto {
  final String description;
  final double amount;
  final int paidById;
  final List<ParticipantShareDto> participantShares;

  ExpenseDto({
    required this.description,
    required this.amount,
    required this.paidById,
    required this.participantShares,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'paidById': paidById,
      'participantShares':
          participantShares.map((share) => share.toJson()).toList(),
    };
  }
}

class ParticipantShareDto {
  final int participantId;
  final double share;

  ParticipantShareDto({required this.participantId, required this.share});

  Map<String, dynamic> toJson() {
    return {'participantId': participantId, 'share': share};
  }
}
