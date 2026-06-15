import '../../domain/entities/hijri_event.dart';

class HijriEventDto extends HijriEvent {
  const HijriEventDto({
    required super.id,
    required super.nameAr,
    required super.nameId,
    required super.gregorianDate,
    required super.hijriYear,
    required super.hijriMonth,
    required super.hijriDay,
    required super.description,
    required super.isImportant,
  });

  factory HijriEventDto.fromJson(Map<String, dynamic> json) {
    return HijriEventDto(
      id: json['id'] as int,
      nameAr: json['nameAr'] as String,
      nameId: json['nameId'] as String,
      gregorianDate: DateTime.parse(json['gregorianDate'] as String),
      hijriYear: json['hijriYear'] as int,
      hijriMonth: json['hijriMonth'] as int,
      hijriDay: json['hijriDay'] as int,
      description: json['description'] as String,
      isImportant: json['isImportant'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameId': nameId,
      'gregorianDate': gregorianDate.toIso8601String(),
      'hijriYear': hijriYear,
      'hijriMonth': hijriMonth,
      'hijriDay': hijriDay,
      'description': description,
      'isImportant': isImportant,
    };
  }
}
