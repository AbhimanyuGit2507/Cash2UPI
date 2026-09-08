class AppSettingEntity {
  final String key;
  final String value;

  AppSettingEntity({
    required this.key,
    required this.value,
  });

  AppSettingEntity copyWith({
    String? key,
    String? value,
  }) {
    return AppSettingEntity(
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
    };
  }

  factory AppSettingEntity.fromMap(Map<String, dynamic> map) {
    return AppSettingEntity(
      key: map['key'],
      value: map['value'],
    );
  }
}
