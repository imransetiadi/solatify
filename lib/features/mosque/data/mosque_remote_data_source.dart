import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:solatify/features/mosque/data/mosque_search_utils.dart';

/// Finds mosques near a point from OpenStreetMap data.
///
/// Photon is the primary source: it answers in about a second. The public
/// Overpass servers are kept only as a fallback because they regularly need
/// 30s or more under load, or time out altogether.
class MosqueRemoteDataSource {
  MosqueRemoteDataSource({http.Client? client}) : _client = client;

  final http.Client? _client;

  static const searchRadiusMeters = 5000;
  static const _userAgent = 'Solatify/1.0 mosque-search';

  static const _photonTimeout = Duration(seconds: 8);

  static const _overpassRadiiMeters = [5000, 2500];
  // Slightly above the query's server-side [timeout:25] so the server can
  // answer first.
  static const _overpassTimeout = Duration(seconds: 30);
  static const _overpassEndpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
  ];

  /// Nearest first. Throws when every source fails.
  Future<List<MosqueItem>> searchNearby({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final mosques = await _searchPhoton(
        latitude: latitude,
        longitude: longitude,
      );
      if (mosques.isNotEmpty) return mosques;
      debugPrint('Photon found no mosques; falling back to Overpass.');
    } catch (error) {
      debugPrint('Photon mosque search failed, falling back: $error');
    }
    return _searchOverpass(latitude: latitude, longitude: longitude);
  }

  Future<http.Response> _get(Uri uri) {
    final headers = {'Accept': 'application/json', 'User-Agent': _userAgent};
    final client = _client;
    return client != null
        ? client.get(uri, headers: headers)
        : http.get(uri, headers: headers);
  }

  Future<http.Response> _post(Uri uri, Map<String, String> body) {
    final headers = {'Accept': 'application/json', 'User-Agent': _userAgent};
    final client = _client;
    return client != null
        ? client.post(uri, headers: headers, body: body)
        : http.post(uri, headers: headers, body: body);
  }

  Future<List<MosqueItem>> _searchPhoton({
    required double latitude,
    required double longitude,
  }) async {
    final uris = buildPhotonMosqueUris(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: searchRadiusMeters,
    );

    // A single failed request only narrows the result; all failing is an
    // error.
    Object? lastError;
    final responses = await Future.wait(
      uris.map((uri) async {
        try {
          final response = await _get(uri).timeout(_photonTimeout);
          if (response.statusCode != 200) {
            throw http.ClientException(
              'Photon returned HTTP ${response.statusCode}',
              uri,
            );
          }
          final decoded = jsonDecode(response.body);
          if (decoded is! Map<String, dynamic>) {
            throw const FormatException('Invalid Photon response.');
          }
          return decoded;
        } catch (error) {
          lastError = error;
          return null;
        }
      }),
    );

    final successful = responses.nonNulls.toList(growable: false);
    if (successful.isEmpty) {
      throw lastError ?? Exception('Photon did not respond.');
    }

    return parsePhotonMosqueFeatures(
      responses: successful,
      originLatitude: latitude,
      originLongitude: longitude,
      radiusMeters: searchRadiusMeters,
    );
  }

  Future<List<MosqueItem>> _searchOverpass({
    required double latitude,
    required double longitude,
  }) async {
    Object? lastError;

    // For each radius, query all endpoints concurrently and take the first
    // useful answer instead of waiting through sequential timeouts.
    for (final radius in _overpassRadiiMeters) {
      final futures = _overpassEndpoints
          .map(
            (endpoint) => _fetchOverpassEndpoint(
              endpoint: endpoint,
              radiusMeters: radius,
              latitude: latitude,
              longitude: longitude,
            ),
          )
          .toList();
      try {
        return await _firstNonEmptyResult(futures);
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError ?? Exception('Every Overpass endpoint failed.');
  }

  /// Completes with the first non-empty result. Overloaded servers sometimes
  /// answer quickly with an empty list, so an empty answer only wins once
  /// every other endpoint has finished without data. Fails only when every
  /// endpoint fails.
  Future<List<MosqueItem>> _firstNonEmptyResult(
    List<Future<List<MosqueItem>>> futures,
  ) {
    final completer = Completer<List<MosqueItem>>();
    var remaining = futures.length;
    var anySucceeded = false;
    Object? lastError;

    void settleIfDone() {
      remaining--;
      if (remaining > 0 || completer.isCompleted) return;
      if (anySucceeded) {
        completer.complete(const []);
      } else {
        completer.completeError(
          lastError ?? Exception('Every Overpass endpoint failed.'),
        );
      }
    }

    for (final future in futures) {
      future
          .then((mosques) {
            anySucceeded = true;
            if (mosques.isNotEmpty && !completer.isCompleted) {
              completer.complete(mosques);
            }
            settleIfDone();
          })
          .catchError((Object error) {
            lastError = error;
            settleIfDone();
          });
    }

    return completer.future;
  }

  Future<List<MosqueItem>> _fetchOverpassEndpoint({
    required String endpoint,
    required int radiusMeters,
    required double latitude,
    required double longitude,
  }) async {
    final query = buildMosqueOverpassQuery(
      radiusMeters: radiusMeters,
      latitude: latitude,
      longitude: longitude,
    );
    final response = await _post(Uri.parse(endpoint), {
      'data': query,
    }).timeout(_overpassTimeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid Overpass response.');
      }
      return parseMosqueOverpassElements(
        data: decoded,
        originLatitude: latitude,
        originLongitude: longitude,
      );
    }

    debugPrint(
      'Overpass mosque search failed at $endpoint with status '
      '${response.statusCode}: '
      '${response.body.substring(0, math.min(response.body.length, 160))}',
    );
    throw Exception('Overpass failed at $endpoint');
  }
}
