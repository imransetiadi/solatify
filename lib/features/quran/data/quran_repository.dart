import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/database/hive_service.dart';
import '../domain/models/quran_models.dart';

class QuranRepository {
  QuranRepository({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  /// Without a timeout a captive portal or weak signal could keep the
  /// loading spinner up for minutes before the retry button appears.
  static const Duration _requestTimeout = Duration(seconds: 15);

  static const String _baseUrl = 'https://quran-api-id.vercel.app';

  static const int _surahCount = 114;

  /// Fetch the list of 114 Surahs.
  ///
  /// Uses the Hive cache when it is complete and up to date (stores English
  /// too); otherwise fetches it again. If that fails, an older or partial
  /// cache is still better than nothing.
  Future<List<Surah>> getSurahList() async {
    final box = HiveService.tryGetBox(HiveService.quranIndexBoxName);

    List<Surah>? cached;
    var cacheIsCurrent = false;
    if (box != null && box.isNotEmpty) {
      try {
        final surahs = <Surah>[];
        var current = true;
        for (final key in box.keys) {
          final data = box.get(key);
          if (data == null) continue;
          final decoded = Map<String, dynamic>.from(jsonDecode(data as String));
          current = current && decoded.containsKey('translationEn');
          surahs.add(Surah.fromJson(decoded));
        }
        surahs.sort((a, b) => a.number.compareTo(b.number));
        cached = surahs;
        // A cache written by an interrupted first fetch is incomplete.
        cacheIsCurrent = current && surahs.length == _surahCount;
      } catch (e) {
        debugPrint('Quran index cache is corrupt: $e');
        await box.clear();
      }
    }
    if (cacheIsCurrent) return cached!;

    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/surah'))
          .timeout(_requestTimeout);
      if (response.statusCode != 200) {
        throw QuranLoadException(
          QuranLoadFailure.server,
          'HTTP ${response.statusCode}',
        );
      }
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        throw const QuranLoadException(QuranLoadFailure.format, 'not a map');
      }
      final rawData = body['data'];
      final List<dynamic> list;
      if (rawData is List) {
        list = rawData;
      } else if (rawData is Map) {
        list = rawData.values.toList();
      } else {
        throw QuranLoadException(
          QuranLoadFailure.format,
          'data is ${rawData.runtimeType}',
        );
      }

      final surahs = [
        for (final item in list)
          if (item is Map) Surah.fromJson(Map<String, dynamic>.from(item)),
      ]..sort((a, b) => a.number.compareTo(b.number));

      // One write after the whole list parsed, instead of 114 sequential
      // writes that an app kill could interrupt half-way.
      final cacheBox = HiveService.tryGetBox(HiveService.quranIndexBoxName);
      if (cacheBox != null && surahs.length == _surahCount) {
        try {
          await cacheBox.putAll({
            for (final surah in surahs)
              surah.number.toString(): jsonEncode(surah.toJson()),
          });
        } catch (e) {
          debugPrint('Caching the surah list failed: $e');
        }
      }
      return surahs;
    } catch (e) {
      if (cached != null && cached.isNotEmpty) return cached;
      throw QuranLoadException.from(e);
    }
  }

  /// Fetch the details (verses) of a specific Surah by number.
  /// Tries loading from local Hive cache first.
  Future<Surah> getSurahDetail(int number) async {
    final box = await HiveService.openBoxOnDemand(
      HiveService.quranDetailBoxName,
    );
    final key = number.toString();

    Surah? cached;
    var cacheIsCurrent = false;
    if (box != null && box.containsKey(key)) {
      try {
        final data = box.get(key);
        if (data != null) {
          // Large surahs (Al-Baqarah) are hundreds of KB of JSON: decode off
          // the UI isolate so opening them does not stall the transition.
          final decoded = await compute(_decodeJsonMap, data as String);
          final surah = Surah.fromJson(decoded);
          if (surah.verses?.isNotEmpty ?? false) {
            cached = surah;
            cacheIsCurrent = surah.verses!.first.translationEn.isNotEmpty;
          }
        }
      } catch (e) {
        debugPrint('Surah $number cache is corrupt: $e');
        await box.delete(key);
      }
    }
    if (cacheIsCurrent) return cached!;

    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/surah/$number'))
          .timeout(_requestTimeout);
      if (response.statusCode != 200) {
        throw QuranLoadException(
          QuranLoadFailure.server,
          'HTTP ${response.statusCode}',
        );
      }
      final body = await compute(_decodeJsonMap, response.body);
      final rawDetail = body['data'];
      final Map<String, dynamic> detailMap;
      if (rawDetail is Map) {
        detailMap = Map<String, dynamic>.from(rawDetail);
      } else if (rawDetail is List && rawDetail.isNotEmpty) {
        detailMap = Map<String, dynamic>.from(rawDetail.first as Map);
      } else {
        throw QuranLoadException(
          QuranLoadFailure.format,
          'detail is ${rawDetail.runtimeType}',
        );
      }

      final surah = Surah.fromJson(detailMap);
      // An empty surah would otherwise be served from the cache forever,
      // so "Try again" could never fix it.
      if (surah.verses?.isEmpty ?? true) {
        throw const QuranLoadException(QuranLoadFailure.format, 'no verses');
      }
      if (box != null) {
        try {
          await box.put(key, jsonEncode(surah.toJson()));
        } catch (e) {
          debugPrint('Caching surah $number failed: $e');
        }
      }
      return surah;
    } catch (e) {
      if (cached != null) return cached;
      throw QuranLoadException.from(e);
    }
  }
}

Map<String, dynamic> _decodeJsonMap(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! Map) {
    throw const QuranLoadException(QuranLoadFailure.format, 'not a map');
  }
  return Map<String, dynamic>.from(decoded);
}

enum QuranLoadFailure { offline, timeout, server, format }

/// Why Quran data could not be loaded; the UI turns [failure] into a
/// localised message (see `quranErrorMessage`).
class QuranLoadException implements Exception {
  const QuranLoadException(this.failure, [this.detail]);

  factory QuranLoadException.from(Object error) {
    if (error is QuranLoadException) return error;
    debugPrint('Quran request failed: $error');
    if (error is TimeoutException) {
      return QuranLoadException(QuranLoadFailure.timeout, '$error');
    }
    if (error is SocketException || error is http.ClientException) {
      return QuranLoadException(QuranLoadFailure.offline, '$error');
    }
    if (error is FormatException) {
      return QuranLoadException(QuranLoadFailure.format, '$error');
    }
    return QuranLoadException(QuranLoadFailure.server, '$error');
  }

  final QuranLoadFailure failure;
  final String? detail;

  @override
  String toString() => 'QuranLoadException(${failure.name}: $detail)';
}
