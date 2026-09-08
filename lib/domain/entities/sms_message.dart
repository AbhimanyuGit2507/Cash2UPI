class SmsMessageEntity {
  final String id;
  final String sender;
  final String body;
  final int timestamp;
  final bool isProcessed;

  SmsMessageEntity({
    required this.id,
    required this.sender,
    required this.body,
    required this.timestamp,
    required this.isProcessed,
  });

  SmsMessageEntity copyWith({
    String? id,
    String? sender,
    String? body,
    int? timestamp,
    bool? isProcessed,
  }) {
    return SmsMessageEntity(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'body': body,
      'timestamp': timestamp,
      'is_processed': isProcessed ? 1 : 0,
    };
  }

  factory SmsMessageEntity.fromMap(Map<String, dynamic> map) {
    return SmsMessageEntity(
      id: map['id'].toString(),
      sender: map['sender'],
      body: map['body'],
      timestamp: map['timestamp'],
      isProcessed: map['is_processed'] == 1,
    );
  }
}
