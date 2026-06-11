class Dhikr {
  final int id;
  final String title;
  final String arabicText;
  final String latinText;
  final String meaning;
  final int count; // how many times to repeat
  final String note;

  Dhikr({
    required this.id,
    required this.title,
    required this.arabicText,
    required this.latinText,
    required this.meaning,
    required this.count,
    this.note = "",
  });
}
