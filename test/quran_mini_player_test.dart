import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/features/quran/presentation/quran_provider.dart';
import 'package:solatify/features/quran/presentation/widgets/quran_mini_player.dart';

/// Starts in a fixed state and records control calls instead of playing.
class _FakeAudioNotifier extends QuranAudioNotifier {
  _FakeAudioNotifier(super.initial) : super.withoutPlayer();

  final calls = <String>[];

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> resume() async => calls.add('resume');

  @override
  Future<void> stop() async {
    calls.add('stop');
    state = QuranAudioState();
  }

  @override
  bool get canRetry => true;

  @override
  Future<void> retryAfterFailure() async => calls.add('retry');

  /// Simulates a recitation that failed to load.
  void fail() => state = QuranAudioState(failureCount: state.failureCount + 1);
}

void main() {
  Future<_FakeAudioNotifier> pumpPlayer(
    WidgetTester tester,
    QuranAudioState initial,
  ) async {
    final notifier = _FakeAudioNotifier(initial);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [quranAudioProvider.overrideWith((ref) => notifier)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: QuranMiniPlayer(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return notifier;
  }

  testWidgets('is hidden when no recitation is loaded', (tester) async {
    await pumpPlayer(tester, QuranAudioState());

    expect(find.textContaining('QS.'), findsNothing);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('shows the playing surah and verse with a pause button', (
    tester,
  ) async {
    final notifier = await pumpPlayer(
      tester,
      QuranAudioState(
        playingSurah: 18,
        playingSurahName: 'Al-Kahf',
        playingVerse: 10,
        isPlaying: true,
      ),
    );

    expect(find.text('QS. Al-Kahf'), findsOneWidget);
    expect(find.textContaining('Ayat 10'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pause_circle_filled_rounded));
    expect(notifier.calls, ['pause']);
  });

  testWidgets('resumes when paused and closes with stop', (tester) async {
    final notifier = await pumpPlayer(
      tester,
      QuranAudioState(
        playingSurah: 1,
        playingSurahName: 'Al-Fatihah',
        playingVerse: 3,
      ),
    );

    await tester.tap(find.byIcon(Icons.play_circle_fill_rounded));
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(notifier.calls, ['resume', 'stop']);
    expect(find.text('QS. Al-Fatihah'), findsNothing);
  });

  testWidgets('reports a failed recitation with a retry action', (
    tester,
  ) async {
    final notifier = await pumpPlayer(
      tester,
      QuranAudioState(
        playingSurah: 18,
        playingSurahName: 'Al-Kahf',
        playingVerse: 40,
        isPlaying: true,
      ),
    );

    notifier.fail();
    await tester.pumpAndSettle();

    expect(
      find.text('Murotal gagal dimuat. Periksa koneksi internet.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Coba lagi'));
    expect(notifier.calls, ['retry']);
  });
}
