import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/database/hive_service.dart';
import '../domain/models/quran_models.dart';

class QuranRepository {
  final http.Client _client;

  QuranRepository({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://quran-api-id.vercel.app';

  /// Fetch the list of 114 Surahs.
  /// Tries loading from Hive cache first; falls back to API.
  Future<List<Surah>> getSurahList() async {
    final box = HiveService.tryGetBox(HiveService.quranIndexBoxName);

    // If cache has entries, load from cache
    if (box != null && box.isNotEmpty) {
      try {
        final List<Surah> surahs = [];
        for (var key in box.keys) {
          final data = box.get(key);
          if (data != null) {
            final decoded = jsonDecode(data as String);
            surahs.add(Surah.fromJson(Map<String, dynamic>.from(decoded)));
          }
        }
        // Sort by surah number
        surahs.sort((a, b) => a.number.compareTo(b.number));
        return surahs;
      } catch (e) {
        // Cache is invalid/corrupt, clear it and fall back to API
        await box.clear();
      }
    }

    // Otherwise, fetch from API
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/surah'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is! Map<String, dynamic>) {
          throw Exception('Format respons tidak valid (bukan JSON Map)');
        }

        final rawData = body['data'];
        final List<dynamic> list;
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map) {
          list = rawData.values.toList();
        } else {
          throw Exception(
            'Data surah tidak valid (tipe: ${rawData.runtimeType})',
          );
        }

        final List<Surah> surahs = [];
        for (var item in list) {
          if (item is! Map) continue;
          final surahMap = Map<String, dynamic>.from(item);
          final surah = Surah.fromJson(surahMap);
          surahs.add(surah);

          // Save to Hive index box
          final cacheBox = HiveService.tryGetBox(HiveService.quranIndexBoxName);
          if (cacheBox != null) {
            await cacheBox.put(surah.number.toString(), jsonEncode(surah.toJson()));
          }
        }

        return surahs;
      } else {
        throw Exception(
          'Gagal memuat daftar Surah: Kode status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal menghubungi server Al-Qur\'an. Pastikan koneksi internet aktif. ($e)',
      );
    }
  }

  /// Fetch the details (verses) of a specific Surah by number.
  /// Tries loading from local Hive cache first.
  Future<Surah> getSurahDetail(int number) async {
    final box = HiveService.tryGetBox(HiveService.quranDetailBoxName);
    final key = number.toString();

    // Check local cache
    if (box != null && box.containsKey(key)) {
      try {
        final data = box.get(key);
        if (data != null) {
          final decoded = jsonDecode(data as String);
          return Surah.fromJson(Map<String, dynamic>.from(decoded));
        }
      } catch (e) {
        await box.delete(key);
      }
    }

    // Fetch from API
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/surah/$number'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is! Map<String, dynamic>) {
          throw Exception('Format respons tidak valid (bukan JSON Map)');
        }

        final rawDetail = body['data'];
        final Map<String, dynamic> detailMap;
        if (rawDetail is Map) {
          detailMap = Map<String, dynamic>.from(rawDetail);
        } else if (rawDetail is List && rawDetail.isNotEmpty) {
          detailMap = Map<String, dynamic>.from(rawDetail.first);
        } else {
          throw Exception(
            'Format data surah detail tidak valid (tipe: ${rawDetail.runtimeType})',
          );
        }

        final surah = Surah.fromJson(detailMap);

        // Cache detail map locally
        final cacheBox = HiveService.tryGetBox(HiveService.quranDetailBoxName);
        if (cacheBox != null) {
          await cacheBox.put(key, jsonEncode(surah.toJson()));
        }
        return surah;
      } else {
        throw Exception(
          'Gagal memuat ayat Surah: Kode status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal menghubungi server Al-Qur\'an. Pastikan koneksi internet aktif. ($e)',
      );
    }
  }
}
