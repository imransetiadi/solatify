import '../../domain/entities/asmaul_husna.dart';

class AsmaulHusnaDto extends AsmaulHusna {
  const AsmaulHusnaDto({
    required super.number,
    required super.arabicName,
    required super.latinName,
    required super.meaning,
    required super.description,
  });

  factory AsmaulHusnaDto.fromJson(Map<String, dynamic> json) {
    return AsmaulHusnaDto(
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
