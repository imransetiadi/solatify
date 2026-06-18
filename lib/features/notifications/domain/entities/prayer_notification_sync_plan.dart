import 'package:solatify/features/notifications/domain/entities/prayer_notification_request.dart';

class PrayerNotificationSyncPlan {
  const PrayerNotificationSyncPlan({
    required this.requestsToSchedule,
    required this.notificationIdsToCancel,
    required this.desiredKeysById,
  });

  final List<PrayerNotificationRequest> requestsToSchedule;
  final List<int> notificationIdsToCancel;
  final Map<int, String> desiredKeysById;
}
