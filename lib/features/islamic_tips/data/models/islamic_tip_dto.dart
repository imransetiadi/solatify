import '../../domain/entities/islamic_tip.dart';

class IslamicTipDto extends IslamicTip {
  const IslamicTipDto({
    required super.id,
    required super.title,
    required super.content,
    required super.reference,
    required super.category,
  });

  factory IslamicTipDto.fromJson(Map<String, dynamic> json) {
    return IslamicTipDto(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      reference: json['reference'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'reference': reference,
      'category': category,
    };
  }
}
