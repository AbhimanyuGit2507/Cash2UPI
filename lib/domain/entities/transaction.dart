enum TransactionType {
  customerPayment,
  personalExpense,
  businessExpense,
  deposit,
  withdrawal,
  transfer,
  income,
  adjustment,
  unknown
}

enum TransactionSource {
  sms,
  manual,
  voice
}

enum TransactionStatus {
  pending,
  classified,
  synced
}

class TransactionEntity {
  final String id;
  final String date;
  final String time;
  final TransactionType type;
  final String bank;
  final double amount;
  final double cash;
  final double commission;
  final String category;
  final String notes;
  final TransactionSource source;
  final TransactionStatus status;
  final bool isSynced;
  final String? userName;

  TransactionEntity({
    required this.id,
    required this.date,
    required this.time,
    required this.type,
    required this.bank,
    required this.amount,
    required this.cash,
    required this.commission,
    required this.category,
    required this.notes,
    required this.source,
    required this.status,
    required this.isSynced,
    this.userName,
  });

  TransactionEntity copyWith({
    String? id,
    String? date,
    String? time,
    TransactionType? type,
    String? bank,
    double? amount,
    double? cash,
    double? commission,
    String? category,
    String? notes,
    TransactionSource? source,
    TransactionStatus? status,
    bool? isSynced,
    String? userName,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      type: type ?? this.type,
      bank: bank ?? this.bank,
      amount: amount ?? this.amount,
      cash: cash ?? this.cash,
      commission: commission ?? this.commission,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
      userName: userName ?? this.userName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'type': type.name,
      'bank': bank,
      'amount': amount,
      'cash': cash,
      'commission': commission,
      'category': category,
      'notes': notes,
      'source': source.name,
      'status': status.name,
      'is_synced': isSynced ? 1 : 0,
      'user_name': userName,
    };
  }

  factory TransactionEntity.fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map['id'],
      date: map['date'],
      time: map['time'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.unknown,
      ),
      bank: map['bank'],
      amount: map['amount'],
      cash: map['cash'],
      commission: map['commission'],
      category: map['category'],
      notes: map['notes'],
      source: TransactionSource.values.firstWhere(
        (e) => e.name == map['source'],
        orElse: () => TransactionSource.manual,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.pending,
      ),
      isSynced: map['is_synced'] == 1,
      userName: map['user_name'],
    );
  }
}
