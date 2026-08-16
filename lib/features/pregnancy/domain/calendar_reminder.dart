class CalendarReminder {
  final String id;
  final String accountId;
  final String relatedTable;
  final String relatedId;
  final String fieldName;
  final DateTime reminderDate;
  final String? label;
  final bool syncedToDeviceCalendar;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CalendarReminder({
    required this.id,
    required this.accountId,
    required this.relatedTable,
    required this.relatedId,
    required this.fieldName,
    required this.reminderDate,
    this.label,
    this.syncedToDeviceCalendar = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'related_table': relatedTable,
      'related_id': relatedId,
      'field_name': fieldName,
      'reminder_date': reminderDate.toIso8601String().split('T').first,
      'label': label,
      'synced_to_device_calendar': syncedToDeviceCalendar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CalendarReminder.fromJson(Map<String, dynamic> json) {
    return CalendarReminder(
      id: json['id'] as String? ?? '',
      accountId: json['account_id'] as String? ?? '',
      relatedTable: json['related_table'] as String? ?? '',
      relatedId: json['related_id'] as String? ?? '',
      fieldName: json['field_name'] as String? ?? '',
      reminderDate: json['reminder_date'] != null
          ? DateTime.tryParse(json['reminder_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      label: json['label'] as String?,
      syncedToDeviceCalendar: json['synced_to_device_calendar'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
