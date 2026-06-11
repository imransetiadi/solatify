class AsmaulHusna {
  final int number;
  final String arabicName;
  final String latinName;
  final String meaning;
  final String description;

  AsmaulHusna({
    required this.number,
    required this.arabicName,
    required this.latinName,
    required this.meaning,
    required this.description,
  });

  factory AsmaulHusna.fromJson(Map<String, dynamic> json) {
    return AsmaulHusna(
      number: json['number'] as int,
      arabicName: json['arabicName'] as String,
      latinName: json['latinName'] as String,
      meaning: json['meaning'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'arabicName': arabicName,
      'latinName': latinName,
      'meaning': meaning,
      'description': description,
    };
  }
}
