class PrayerGuideSummary {
  const PrayerGuideSummary({required this.title, required this.items});

  final String title;
  final List<String> items;
}

class PrayerGuideStep {
  const PrayerGuideStep({
    required this.number,
    required this.title,
    required this.description,
    required this.arabicText,
    required this.latinText,
    required this.meaning,
    this.note = '',
  });

  final int number;
  final String title;
  final String description;
  final String arabicText;
  final String latinText;
  final String meaning;
  final String note;
}

class PostPrayerDhikr {
  const PostPrayerDhikr({
    required this.title,
    required this.arabicText,
    required this.latinText,
    required this.meaning,
    required this.count,
  });

  final String title;
  final String arabicText;
  final String latinText;
  final String meaning;
  final int count;
}
