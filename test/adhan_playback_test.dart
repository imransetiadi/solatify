import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/features/notifications/data/services/adhan_playback_service.dart';
import 'package:solatify/features/notifications/presentation/providers/adhan_playback_provider.dart';
import 'package:solatify/features/notifications/presentation/widgets/adhan_now_playing_bar.dart';

const _channel = MethodChannel('solatify/ios_adhan');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<String> calls;
  late Map<String, Object?> nativeState;

  setUp(() {
    calls = [];
    nativeState = {'playing': false};
    messenger.setMockMethodCallHandler(_channel, (call) async {
      calls.add(call.method);
      switch (call.method) {
        case 'getState':
          return nativeState;
        case 'stop':
          nativeState = {'playing': false};
          return true;
      }
      return null;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(_channel, null));

  /// Simulates the native player reporting a state change.
  Future<void> emitFromNative(Map<String, Object?> state) async {
    await messenger.handlePlatformMessage(
      _channel.name,
      const StandardMethodCodec().encodeMethodCall(
        MethodCall('adhanStateChanged', state),
      ),
      (_) {},
    );
  }

  AdhanPlaybackService iosService() =>
      AdhanPlaybackService(platform: TargetPlatform.iOS);

  group('AdhanPlaybackState.fromPlatform', () {
    test('reads playing state and prayer', () {
      expect(
        AdhanPlaybackState.fromPlatform({
          'playing': true,
          'prayerKey': 'subuh',
        }),
        const AdhanPlaybackState(isPlaying: true, prayerKey: 'subuh'),
      );
    });

    test('drops the prayer when stopped and tolerates bad input', () {
      expect(
        AdhanPlaybackState.fromPlatform({
          'playing': false,
          'prayerKey': 'subuh',
        }),
        const AdhanPlaybackState(),
      );
      expect(AdhanPlaybackState.fromPlatform(null), const AdhanPlaybackState());
    });
  });

  group('AdhanPlaybackNotifier', () {
    test('picks up an adhan that started before it listened', () async {
      nativeState = {'playing': true, 'prayerKey': 'magrib'};
      var started = 0;
      final notifier = AdhanPlaybackNotifier(
        iosService(),
        onAdhanStarted: () => started++,
      );
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.isPlaying, isTrue);
      expect(notifier.state.prayerKey, 'magrib');
      expect(started, 1);
      notifier.dispose();
    });

    test('follows native start/finish and reports each start once', () async {
      var started = 0;
      final notifier = AdhanPlaybackNotifier(
        iosService(),
        onAdhanStarted: () => started++,
      );
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state.isPlaying, isFalse);

      await emitFromNative({'playing': true, 'prayerKey': 'isya'});
      await emitFromNative({'playing': true, 'prayerKey': 'isya'});
      expect(notifier.state.isPlaying, isTrue);
      expect(started, 1);

      await emitFromNative({'playing': false});
      expect(notifier.state.isPlaying, isFalse);
      notifier.dispose();
    });

    test('stop asks the native player to stop', () async {
      nativeState = {'playing': true, 'prayerKey': 'ashar'};
      final notifier = AdhanPlaybackNotifier(iosService());
      await Future<void>.delayed(Duration.zero);

      await notifier.stop();

      expect(calls, contains('stop'));
      expect(notifier.state.isPlaying, isFalse);
      notifier.dispose();
    });

    test('does nothing on platforms without the native player', () async {
      final notifier = AdhanPlaybackNotifier(
        AdhanPlaybackService(platform: TargetPlatform.android),
      );
      await Future<void>.delayed(Duration.zero);
      await notifier.stop();

      expect(calls, isEmpty);
      expect(notifier.state.isPlaying, isFalse);
      notifier.dispose();
    });
  });

  group('AdhanNowPlayingBar', () {
    Future<void> pumpBar(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adhanPlaybackServiceProvider.overrideWithValue(iosService()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: AdhanNowPlayingBar(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('is hidden when no adhan is playing', (tester) async {
      await pumpBar(tester);

      expect(find.byIcon(Icons.stop_circle_rounded), findsNothing);
    });

    testWidgets('shows the prayer and stops the adhan', (tester) async {
      nativeState = {'playing': true, 'prayerKey': 'subuh'};
      await pumpBar(tester);

      expect(find.text('Adzan Subuh'), findsOneWidget);
      expect(find.text('Sedang diputar'), findsOneWidget);

      await tester.tap(find.byTooltip('Hentikan adzan'));
      await tester.pumpAndSettle();

      expect(calls, contains('stop'));
      expect(find.byIcon(Icons.stop_circle_rounded), findsNothing);
    });
  });
}
