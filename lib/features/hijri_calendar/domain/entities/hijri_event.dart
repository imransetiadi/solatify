class HijriEvent {
  const HijriEvent({
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

  final int id;
  final String nameAr;
  final String nameId;
  final DateTime gregorianDate;
  final int hijriYear;
  final int hijriMonth;
  final int hijriDay;
  final String description;
  final bool isImportant;
}
