import 'package:timezone/data/latest_all.dart' as tzdata;

/// Loads the IANA timezone database once for the whole app.
///
/// `initializeTimeZones()` decodes the full database (~445 KB) and resets
/// `tz.local` every time it runs; prayer calculation and notifications each
/// used to call it with their own guard, so it ran twice during startup.
class TimezoneDatabase {
  TimezoneDatabase._();

  static bool _initialized = false;

  static void ensureInitialized() {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    _initialized = true;
  }
}
