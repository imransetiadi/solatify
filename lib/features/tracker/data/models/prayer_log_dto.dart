import '../../domain/entities/prayer_log_entity.dart';

class PrayerLogDto extends PrayerLogEntity {
  const PrayerLogDto({
    required super.date,
    required super.prayers,
  });

  factory PrayerLogDto.fromEntity(PrayerLogEntity entity) {
    return PrayerLogDto(
      date: entity.date,
      prayers: entity.prayers,
    );
  }

  factory PrayerLogDto.fromJson(Map<String, dynamic> json) {
    return PrayerLogDto(
      date: DateTime.parse(json['date'] as String),
      prayers: Map<String, bool>.from(json['prayers'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'prayers': prayers,
    };
  }
}
