typedef ShareTextAction = Future<void> Function(String text);

enum TrackerShareResult { shared, copiedFallback }

class TrackerShareService {
  const TrackerShareService({required this.shareText, required this.copyText});

  final ShareTextAction shareText;
  final ShareTextAction copyText;

  Future<TrackerShareResult> shareProgress(String summary) async {
    try {
      await shareText(summary);
      return TrackerShareResult.shared;
    } catch (_) {
      await copyText(summary);
      return TrackerShareResult.copiedFallback;
    }
  }
}
