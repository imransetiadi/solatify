class Surah {
  final int number;
  final String name;
  final String translation;
  final int numberOfVerses;
  final String revelation; // Makkiyah / Madaniyah
  final List<Verse>? verses;

  Surah({
    required this.number,
    required this.name,
    required this.translation,
    required this.numberOfVerses,
    required this.revelation,
    this.verses,
  });

  Surah copyWith({
    int? number,
    String? name,
    String? translation,
    int? numberOfVerses,
    String? revelation,
    List<Verse>? verses,
  }) {
    return Surah(
      number: number ?? this.number,
      name: name ?? this.name,
      translation: translation ?? this.translation,
      numberOfVerses: numberOfVerses ?? this.numberOfVerses,
      revelation: revelation ?? this.revelation,
      verses: verses ?? this.verses,
    );
  }

  factory Surah.fromJson(Map<String, dynamic> json) {
    final rawVerses = json['verses'] ?? json['ayat'];
    List<Verse>? parsedVerses;
    if (rawVerses != null) {
      if (rawVerses is List) {
        parsedVerses = rawVerses
            .map((v) => Verse.fromJson(Map<String, dynamic>.from(v)))
            .toList();
      } else if (rawVerses is Map) {
        parsedVerses = rawVerses.entries
            .map((e) => Verse.fromJson(Map<String, dynamic>.from(e.value)))
            .toList();
      }
    }

    final int num = json['number'] ?? json['nomor'] ?? 0;

    // name parsing:
    String nm = '';
    final nameData = json['name'];
    if (nameData is String) {
      nm = nameData;
    } else if (nameData is Map) {
      nm =
          nameData['transliteration']?['id'] ??
          nameData['transliteration']?['en'] ??
          nameData['short'] ??
          '';
    }

    // translation parsing:
    String trans = '';
    final transData =
        json['translation'] ??
        (nameData is Map ? nameData['translation'] : null);
    if (transData is String) {
      trans = transData;
    } else if (transData is Map) {
      trans = transData['id'] ?? transData['en'] ?? '';
    }

    // revelation parsing:
    String rev = '';
    final revData =
        json['revelation'] ?? json['tempatTurun'] ?? json['tempat_turun'];
    if (revData is String) {
      rev = revData;
    } else if (revData is Map) {
      rev = revData['id'] ?? revData['en'] ?? '';
    }

    return Surah(
      number: num,
      name: nm,
      translation: trans,
      numberOfVerses:
          json['numberOfVerses'] ??
          json['jumlahAyat'] ??
          json['jumlah_ayat'] ??
          0,
      revelation: rev,
      verses: parsedVerses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'translation': translation,
      'numberOfVerses': numberOfVerses,
      'revelation': revelation,
      'verses': verses?.map((v) => v.toJson()).toList(),
    };
  }
}

class Verse {
  final int number;
  final String arabic;
  final String latin;
  final String translation;
  final String audioUrl;

  Verse({
    required this.number,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.audioUrl,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    int num = 0;
    final numData = json['number'];
    if (numData is int) {
      num = numData;
    } else if (numData is Map) {
      num = numData['inSurah'] ?? numData['inQuran'] ?? 0;
    } else if (json['nomorAyat'] != null) {
      num = json['nomorAyat'] as int;
    }

    String ar = '';
    final textData = json['text'] ?? json['teksArab'] ?? json['teks_arab'];
    if (textData is String) {
      ar = textData;
    } else if (textData is Map) {
      ar = textData['arab'] ?? '';
    } else if (json['arabic'] != null) {
      ar = json['arabic'] as String;
    }

    String lat = json['latin'] ?? '';
    if (lat.isEmpty) {
      if (textData is Map) {
        final transData = textData['transliteration'];
        if (transData is Map) {
          lat = transData['id'] ?? transData['en'] ?? '';
        } else if (transData is String) {
          lat = transData;
        }
      }
    }

    String tr = '';
    final transData =
        json['translation'] ?? json['teksIndonesia'] ?? json['teks_indonesia'];
    if (transData is String) {
      tr = transData;
    } else if (transData is Map) {
      tr = transData['id'] ?? transData['en'] ?? '';
    }

    String aud = '';
    final audioData = json['audio'];
    if (audioData is String) {
      aud = audioData;
    } else if (audioData is Map) {
      aud =
          audioData['primary'] ??
          (audioData['secondary'] is List &&
                  (audioData['secondary'] as List).isNotEmpty
              ? audioData['secondary'][0]
              : '') ??
          audioData.values.firstWhere(
                (v) => v is String && v.isNotEmpty,
                orElse: () => '',
              )
              as String;
    } else if (json['audioUrl'] != null) {
      aud = json['audioUrl'] as String;
    }

    return Verse(
      number: num,
      arabic: ar,
      latin: lat,
      translation: tr,
      audioUrl: aud,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'arabic': arabic,
      'latin': latin,
      'translation': translation,
      'audioUrl': audioUrl,
    };
  }
}
