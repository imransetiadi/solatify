import '../../domain/entities/prayer_log_entity.dart';

class PrayerLogDto extends PrayerLogEntity {
  const PrayerLogDto({
    required super.date,
    required super.prayers,
    super.prayerStatuses,
  });

  factory PrayerLogDto.fromEntity(PrayerLogEntity entity) {
    return PrayerLogDto(
      date: entity.date,
      prayers: entity.prayers,
      prayerStatuses: entity.prayerStatuses,
    );
  }

  factory PrayerLogDto.fromJson(Map<String, dynamic> json) {
    final rawStatuses = Map<String, dynamic>.from(
      (json['prayerStatuses'] as Map?) ?? const {},
    );

    return PrayerLogDto(
      date: DateTime.parse(json['date'] as String),
      prayers: Map<String, bool>.from(json['prayers'] as Map),
      prayerStatuses: rawStatuses.map(
        (key, value) => MapEntry(
          key,
          PrayerStatus.fromName(value as String?) ?? PrayerStatus.onTime,
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'prayers': prayers,
      'prayerStatuses': prayerStatuses.map(
        (key, value) => MapEntry(key, value.name),
      ),
    };
  }
}
