import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/tracker/domain/services/tracker_share_service.dart';

void main() {
  test('shares tracker progress with native share before fallback', () async {
    final events = <String>[];
    final service = TrackerShareService(
      shareText: (text) async => events.add('share:$text'),
      copyText: (text) async => events.add('copy:$text'),
    );

    final result = await service.shareProgress('Progress Ibadah Mingguan');

    expect(result, TrackerShareResult.shared);
    expect(events, ['share:Progress Ibadah Mingguan']);
  });

  test('falls back to clipboard when native share fails', () async {
    final events = <String>[];
    final service = TrackerShareService(
      shareText: (_) async => throw Exception('share unavailable'),
      copyText: (text) async => events.add('copy:$text'),
    );

    final result = await service.shareProgress('Progress Ibadah Mingguan');

    expect(result, TrackerShareResult.copiedFallback);
    expect(events, ['copy:Progress Ibadah Mingguan']);
  });
}
