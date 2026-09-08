class AccountEntity {
  final String id;
  final String bankName;
  final double currentBalance;

  AccountEntity({
    required this.id,
    required this.bankName,
    required this.currentBalance,
  });

  AccountEntity copyWith({
    String? id,
    String? bankName,
    double? currentBalance,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bank_name': bankName,
      'current_balance': currentBalance,
    };
  }

  factory AccountEntity.fromMap(Map<String, dynamic> map) {
    return AccountEntity(
      id: map['id'],
      bankName: map['bank_name'],
      currentBalance: map['current_balance'],
    );
  }
}
