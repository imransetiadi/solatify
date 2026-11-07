import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/localization/islamic_content_localizer.dart';
import 'package:solatify/features/hijri_calendar/data/datasources/hijri_calendar_local_data_source.dart';
import 'package:solatify/features/hijri_calendar/presentation/providers/hijri_calendar_provider.dart';

void main() {
  group('Hijri events', () {
    test('Gregorian dates follow the Umm al-Qura calendar', () {
      final events = buildHijriEvents(DateTime(2026, 3, 1)); // 1447 H
      DateTime dateOf(int year, int month, int day) => events
          .firstWhere(
            (e) =>
                e.hijriYear == year &&
                e.hijriMonth == month &&
                e.hijriDay == day,
          )
          .gregorianDate;

      expect(dateOf(1447, 9, 1), DateTime(2026, 2, 18)); // Ramadhan
      expect(dateOf(1447, 10, 1), DateTime(2026, 3, 20)); // Idul Fitri
      expect(dateOf(1447, 12, 10), DateTime(2026, 5, 27)); // Idul Adha
      expect(dateOf(1448, 1, 1), DateTime(2026, 6, 16)); // 1 Muharram 1448
    });

    test('the upcoming list never runs out', () {
      // Previously the hard-coded list was empty after July 2027.
      for (final today in [
        DateTime(2026, 11, 7),
        DateTime(2027, 8, 1),
        DateTime(2030, 1, 1),
      ]) {
        final upcoming = upcomingHijriEvents(buildHijriEvents(today), today);
        expect(upcoming, isNotEmpty, reason: '$today');
        expect(upcoming.first.gregorianDate.isBefore(today), isFalse);
      }
    });

    test('next event on 7 Nov 2026 is Isra Miraj 1448', () {
      final today = DateTime(2026, 11, 7);
      final upcoming = upcomingHijriEvents(buildHijriEvents(today), today);

      expect(upcoming.first.hijriMonth, 7);
      expect(upcoming.first.hijriDay, 27);
      expect(upcoming.first.gregorianDate, DateTime(2027, 1, 5));
    });

    test('an event stays listed for its whole day', () {
      final events = buildHijriEvents(DateTime(2026, 5, 1));
      final eidAdhaEvening = DateTime(2026, 5, 27, 21, 30);
      final upcoming = upcomingHijriEvents(events, eidAdhaEvening);

      expect(upcoming.first.gregorianDate, DateTime(2026, 5, 27));
    });

    test('ids are unique across years', () {
      final events = buildHijriEvents(DateTime(2026, 11, 7));
      expect(events.map((e) => e.id).toSet().length, events.length);
    });

    test('every event has an English name and description', () {
      const english = AppLocalizations(Locale('en'));
      for (final event in buildHijriEvents(DateTime(2026, 11, 7))) {
        expect(
          english.tr(event.nameId),
          isNot(event.nameId),
          reason: 'Missing translation: ${event.nameId}',
        );
        expect(
          english.tr(event.description),
          isNot(event.description),
          reason: 'Missing translation: ${event.description}',
        );
      }
    });
  });
}
