import '../../domain/entities/dua.dart';

class DuaDto extends Dua {
  const DuaDto({
    required super.id,
    required super.title,
    required super.category,
    required super.arabicText,
    required super.latinText,
    required super.meaning,
    required super.source,
  });

  factory DuaDto.fromJson(Map<String, dynamic> json) {
    return DuaDto(
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
