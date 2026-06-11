class Dua {
  final int id;
  final String title;
  final String category;
  final String arabicText;
  final String latinText;
  final String meaning;
  final String source;

  Dua({
    required this.id,
    required this.title,
    required this.category,
    required this.arabicText,
    required this.latinText,
    required this.meaning,
    required this.source,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      arabicText: json['arabicText'] as String,
      latinText: json['latinText'] as String,
      meaning: json['meaning'] as String,
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'arabicText': arabicText,
      'latinText': latinText,
      'meaning': meaning,
      'source': source,
    };
  }
}
