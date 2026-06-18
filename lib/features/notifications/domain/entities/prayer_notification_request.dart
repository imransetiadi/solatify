class PrayerNotificationRequest {
  const PrayerNotificationRequest({
    required this.prayerKey,
    required this.prayerTime,
    required this.notificationTime,
    required this.notificationId,
    this.isReminder = false,
  });

  final String prayerKey;
  final DateTime prayerTime;
  final DateTime notificationTime;
  final int notificationId;
  final bool isReminder;
}
