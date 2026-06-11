class HijriEvent {
  final int id;
  final String nameAr;
  final String nameId;
  final DateTime gregorianDate;
  final int hijriYear;
  final int hijriMonth;
  final int hijriDay;
  final String description;
  final bool isImportant;

  HijriEvent({
    required this.id,
    required this.nameAr,
    required this.nameId,
    required this.gregorianDate,
    required this.hijriYear,
    required this.hijriMonth,
    required this.hijriDay,
    required this.description,
    required this.isImportant,
  });

  factory HijriEvent.fromJson(Map<String, dynamic> json) {
    return HijriEvent(
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
