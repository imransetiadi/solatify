import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';
import 'package:solatify/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:solatify/features/notifications/presentation/providers/notification_scheduler_provider.dart';

class NotificationHealthScreen extends ConsumerStatefulWidget {
  const NotificationHealthScreen({super.key});

  @override
  ConsumerState<NotificationHealthScreen> createState() =>
      _NotificationHealthScreenState();
}

class _NotificationHealthScreenState
    extends ConsumerState<NotificationHealthScreen> {
  final NotificationService _notificationService = NotificationService();

  NotificationReadiness? _readiness;
  NotificationHistoryEntry _history = const NotificationHistoryEntry();
  List<int> _pendingIds = const [];
  bool _isLoading = true;
  bool _isActionRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshHealth());
  }

  Future<void> _refreshHealth() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final readiness = await _notificationService.getReadinessStatus();
    final pendingIds = await _notificationService.getPendingNotificationIds();
    final history = _notificationService.getNotificationHistory();

    if (!mounted) return;
    setState(() {
      _readiness = readiness;
      _pendingIds = pendingIds;
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    if (_isActionRunning) return;
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);

    setState(() => _isActionRunning = true);
    try {
      await action();
      await _refreshHealth();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (e) {
      debugPrint('Notification health action failed: $e');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l.notificationHealthActionFailed)),
      );
    } finally {
      if (mounted) setState(() => _isActionRunning = false);
    }
  }

  Future<void> _openSystemSettings() async {
    final opened = await _notificationService
        .openPlatformNotificationSettings();
    if (!opened || !mounted) {
      throw StateError('Notification settings could not be opened');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final textSecondary = isDark
        ? const Color(0xFFB8A898)
        : const Color(0xFF6A5B51);
    final accentColor = AppTheme.readableAccent(context);
    final cardOpacity = isDark ? 0.04 : 0.02;

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            child: RefreshIndicator(
              onRefresh: _refreshHealth,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: ResponsiveLayout.pagePadding(context).copyWith(
                  top: ResponsiveLayout.pageTopGap,
                  bottom: ResponsiveLayout.bottomSafeGap,
                ),
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: l.back,
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(Icons.arrow_back, color: textColor),
                      ),
                      Expanded(
                        child: Text(
                          l.notificationHealthTitle,
                          style: TextStyle(
                            color: textColor,
                            fontSize: SolatifyType.pageTitle,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ResponsiveLayout.itemGap),
                  _buildReadinessCard(
                    l: l,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                    opacity: cardOpacity,
                  ),
                  const SizedBox(height: ResponsiveLayout.itemGap),
                  _buildScheduleCard(
                    l: l,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    opacity: cardOpacity,
                  ),
                  const SizedBox(height: ResponsiveLayout.itemGap),
                  _buildActionsCard(
                    l: l,
                    textColor: textColor,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                    opacity: cardOpacity,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadinessCard({
    required AppLocalizations l,
    required Color textColor,
    required Color textSecondary,
    required Color accentColor,
    required double opacity,
  }) {
    final readiness = _readiness;
    final icon = readiness?.status == NotificationReadinessStatus.ready
        ? Icons.verified_outlined
        : Icons.warning_amber_rounded;

    return GlassContainer(
      opacity: opacity,
      borderRadius: 24,
      padding: ResponsiveLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: icon,
            title: l.notificationHealthStatus,
            color: textColor,
            iconColor: accentColor,
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            LinearProgressIndicator(color: accentColor)
          else ...[
            Text(
              readiness?.title ?? l.notificationHealthUnknown,
              style: TextStyle(
                color: textColor,
                fontSize: SolatifyType.sectionTitle,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              readiness?.message ?? l.notificationHealthUnknownMessage,
              style: TextStyle(
                color: textSecondary,
                fontSize: SolatifyType.caption,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
    required AppLocalizations l,
    required Color textColor,
    required Color textSecondary,
    required double opacity,
  }) {
    final lastScheduled = _formatDateTime(_history.lastScheduledAt);
    final lastFailed = _formatDateTime(_history.lastFailedAt);
    final pendingPreview = _pendingIds.take(8).join(', ');

    return GlassContainer(
      opacity: opacity,
      borderRadius: 24,
      padding: ResponsiveLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.schedule_outlined,
            title: l.notificationHealthSchedule,
            color: textColor,
            iconColor: textSecondary,
          ),
          const SizedBox(height: 12),
          _HealthMetricRow(
            label: l.notificationHealthPendingCount,
            value: _isLoading ? '...' : '${_pendingIds.length}',
            textColor: textColor,
            textSecondary: textSecondary,
          ),
          _HealthMetricRow(
            label: l.notificationHealthPendingIds,
            value: _pendingIds.isEmpty ? l.none : pendingPreview,
            textColor: textColor,
            textSecondary: textSecondary,
          ),
          _HealthMetricRow(
            label: l.notificationHealthLastScheduled,
            value: lastScheduled,
            textColor: textColor,
            textSecondary: textSecondary,
          ),
          _HealthMetricRow(
            label: l.notificationHealthScheduledCount,
            value: '${_history.lastScheduledCount}',
            textColor: textColor,
            textSecondary: textSecondary,
          ),
          _HealthMetricRow(
            label: l.notificationHealthLastFailed,
            value: lastFailed,
            textColor: textColor,
            textSecondary: textSecondary,
          ),
          _HealthMetricRow(
            label: l.notificationHealthFailureReason,
            value: _history.lastFailedReason ?? l.none,
            textColor: textColor,
            textSecondary: textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard({
    required AppLocalizations l,
    required Color textColor,
    required Color textSecondary,
    required Color accentColor,
    required double opacity,
  }) {
    return GlassContainer(
      opacity: opacity,
      borderRadius: 24,
      padding: ResponsiveLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            icon: Icons.health_and_safety_outlined,
            title: l.notificationHealthActions,
            color: textColor,
            iconColor: accentColor,
          ),
          const SizedBox(height: 12),
          _HealthActionButton(
            icon: Icons.refresh,
            label: l.notificationHealthRefresh,
            enabled: !_isActionRunning,
            onPressed: _refreshHealth,
          ),
          _HealthActionButton(
            icon: Icons.sync,
            label: l.notificationHealthReschedule,
            enabled: !_isActionRunning,
            onPressed: () => _runAction(
              () => ref
                  .read(notificationSchedulerProvider.notifier)
                  .refreshSchedules(force: true),
              l.notificationHealthRescheduled,
            ),
          ),
          _HealthActionButton(
            icon: Icons.notifications_active_outlined,
            label: l.notificationHealthSendTest,
            enabled: !_isActionRunning,
            onPressed: () => _runAction(
              _notificationService.showTestNotification,
              l.notificationHealthTestSent,
            ),
          ),
          _HealthActionButton(
            icon: Icons.settings_outlined,
            label: l.notificationHealthOpenSystemSettings,
            enabled: !_isActionRunning,
            onPressed: () => _runAction(
              _openSystemSettings,
              l.notificationHealthSystemSettingsOpened,
            ),
          ),
          if (defaultTargetPlatform == TargetPlatform.android)
            _HealthActionButton(
              icon: Icons.alarm_on_outlined,
              label: l.openExactAlarmPermission,
              enabled: !_isActionRunning,
              onPressed: () => _runAction(() async {
                final opened = await _notificationService
                    .openAndroidExactAlarmSettings();
                if (!opened) throw StateError('Exact alarm settings failed');
              }, l.notificationHealthSystemSettingsOpened),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return AppLocalizations.of(context).none;
    final local = value.toLocal();
    final date = local.toIso8601String().split('T').first;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$date $hour:$minute';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: SolatifyIconSize.inline),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: SolatifyType.body,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _HealthMetricRow extends StatelessWidget {
  const _HealthMetricRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.textSecondary,
  });

  final String label;
  final String value;
  final Color textColor;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textSecondary,
                fontSize: SolatifyType.caption,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: textColor,
                fontSize: SolatifyType.caption,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthActionButton extends StatelessWidget {
  const _HealthActionButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: SolatifyIconSize.inline),
        label: Text(label),
      ),
    );
  }
}
