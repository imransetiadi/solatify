class NotificationHistoryEntry {
  const NotificationHistoryEntry({
    this.lastScheduledAt,
    this.lastScheduledCount = 0,
    this.lastFailedAt,
    this.lastFailedReason,
    this.lastPermissionStatus,
  });

  factory NotificationHistoryEntry.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return const NotificationHistoryEntry();
    return NotificationHistoryEntry(
      lastScheduledAt: _readDate(json['lastScheduledAt']),
      lastScheduledCount: json['lastScheduledCount'] is int
          ? json['lastScheduledCount'] as int
          : 0,
      lastFailedAt: _readDate(json['lastFailedAt']),
      lastFailedReason: json['lastFailedReason']?.toString(),
      lastPermissionStatus: json['lastPermissionStatus']?.toString(),
    );
  }

  final DateTime? lastScheduledAt;
  final int lastScheduledCount;
  final DateTime? lastFailedAt;
  final String? lastFailedReason;
  final String? lastPermissionStatus;

  NotificationHistoryEntry copyWith({
    DateTime? lastScheduledAt,
    int? lastScheduledCount,
    DateTime? lastFailedAt,
    String? lastFailedReason,
    String? lastPermissionStatus,
  }) {
    return NotificationHistoryEntry(
      lastScheduledAt: lastScheduledAt ?? this.lastScheduledAt,
      lastScheduledCount: lastScheduledCount ?? this.lastScheduledCount,
      lastFailedAt: lastFailedAt ?? this.lastFailedAt,
      lastFailedReason: lastFailedReason ?? this.lastFailedReason,
      lastPermissionStatus: lastPermissionStatus ?? this.lastPermissionStatus,
    );
  }

  static DateTime? _readDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  Map<String, Object?> toJson() {
    return {
      'lastScheduledAt': lastScheduledAt?.toIso8601String(),
      'lastScheduledCount': lastScheduledCount,
      'lastFailedAt': lastFailedAt?.toIso8601String(),
      'lastFailedReason': lastFailedReason,
      'lastPermissionStatus': lastPermissionStatus,
    };
  }
}
