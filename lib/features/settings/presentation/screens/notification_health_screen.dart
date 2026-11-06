import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_screen_scaffold.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';
import 'package:solatify/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:solatify/features/notifications/presentation/providers/notification_scheduler_provider.dart';
import 'package:solatify/features/settings/presentation/widgets/settings_tiles.dart';

/// Visual severity of a health row. Always rendered with an icon + text so
/// meaning never depends on color alone.
enum _HealthTone { ok, warning, error, neutral }

class _ToneStyle {
  const _ToneStyle(this.color, this.icon);

  final Color color;
  final IconData icon;

  static _ToneStyle of(BuildContext context, _HealthTone tone) {
    switch (tone) {
      case _HealthTone.ok:
        return _ToneStyle(
          SolatifyColors.success(context),
          Icons.check_circle_rounded,
        );
      case _HealthTone.warning:
        return _ToneStyle(
          SolatifyColors.warning(context),
          Icons.warning_amber_rounded,
        );
      case _HealthTone.error:
        return _ToneStyle(
          SolatifyColors.error(context),
          Icons.error_outline_rounded,
        );
      case _HealthTone.neutral:
        return _ToneStyle(
          SolatifyColors.muted(context),
          Icons.help_outline_rounded,
        );
    }
  }
}

class NotificationHealthScreen extends ConsumerStatefulWidget {
  const NotificationHealthScreen({super.key});

  @override
  ConsumerState<NotificationHealthScreen> createState() =>
      _NotificationHealthScreenState();
}

class _NotificationHealthScreenState
    extends ConsumerState<NotificationHealthScreen>
    with WidgetsBindingObserver {
  final NotificationService _notificationService = NotificationService();

  NotificationReadiness? _readiness;
  NotificationHistoryEntry _history = const NotificationHistoryEntry();
  List<int> _pendingIds = const [];
  bool _isLoading = true;
  bool _isActionRunning = false;

  /// Label of the action currently running, used to show a spinner on it.
  String? _runningAction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshHealth());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _refreshHealth();
  }

  Future<void> _refreshHealth() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final readiness = await _notificationService.getReadinessStatus();
      final pendingIds = await _notificationService.getPendingNotificationIds();
      final history = _notificationService.getNotificationHistory();

      if (!mounted) return;
      setState(() {
        _readiness = readiness;
        _pendingIds = pendingIds;
        _history = history;
      });
    } catch (e) {
      // Keep the previous snapshot; the status card falls back to "unknown".
      debugPrint('Notification health refresh failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _runAction(
    String label,
    Future<void> Function() action,
    String successMessage,
  ) async {
    if (_isActionRunning) return;
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);

    setState(() {
      _isActionRunning = true;
      _runningAction = label;
    });
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
      if (mounted) {
        setState(() {
          _isActionRunning = false;
          _runningAction = null;
        });
      }
    }
  }

  Future<void> _openSystemSettings() async {
    final opened = await _notificationService
        .openPlatformNotificationSettings();
    if (!opened || !mounted) {
      throw StateError('Notification settings could not be opened');
    }
  }

  Future<void> _openExactAlarmSettings() async {
    final opened = await _notificationService.openAndroidExactAlarmSettings();
    if (!opened) throw StateError('Exact alarm settings failed');
  }

  void _reschedule(AppLocalizations l) => _runAction(
    l.notificationHealthReschedule,
    () => ref
        .read(notificationSchedulerProvider.notifier)
        .refreshSchedules(force: true),
    l.notificationHealthRescheduled,
  );

  void _sendTest(AppLocalizations l) => _runAction(
    l.notificationHealthSendTest,
    _notificationService.showTestNotification,
    l.notificationHealthTestSent,
  );

  void _openSettings(AppLocalizations l) => _runAction(
    l.notificationHealthOpenSystemSettings,
    _openSystemSettings,
    l.notificationHealthSystemSettingsOpened,
  );

  void _openExactAlarm(AppLocalizations l) => _runAction(
    l.openExactAlarmPermission,
    _openExactAlarmSettings,
    l.notificationHealthSystemSettingsOpened,
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final busy = _isLoading || _isActionRunning;

    return SolatifyScreenScaffold(
      title: l.notificationHealthTitle,
      backRoute: AppRoutes.settings,
      padding: EdgeInsets.zero,
      actions: [
        IconButton(
          tooltip: l.notificationHealthRefresh,
          onPressed: busy ? null : _refreshHealth,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: _refreshHealth,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: ResponsiveLayout.pagePadding(context).copyWith(
            top: ResponsiveLayout.itemGap,
            bottom: ResponsiveLayout.bottomSafeGap,
          ),
          children: [
            _buildReadinessCard(l),
            const SizedBox(height: ResponsiveLayout.sectionGap),
            SettingsSectionHeader(
              title: l.notificationHealthSchedule.toUpperCase(),
              icon: Icons.schedule_outlined,
            ),
            const SizedBox(height: ResponsiveLayout.itemGap),
            _buildScheduleCard(l),
            const SizedBox(height: ResponsiveLayout.sectionGap),
            SettingsSectionHeader(
              title: l.notificationHealthActions.toUpperCase(),
              icon: Icons.health_and_safety_outlined,
            ),
            const SizedBox(height: ResponsiveLayout.itemGap),
            _buildActionsCard(l),
          ],
        ),
      ),
    );
  }

  _HealthTone _readinessTone(NotificationReadiness? readiness) {
    switch (readiness?.status) {
      case NotificationReadinessStatus.ready:
        return _HealthTone.ok;
      case NotificationReadinessStatus.needsNotificationPermission:
        return _HealthTone.error;
      case NotificationReadinessStatus.inexactScheduling:
        return _HealthTone.warning;
      case NotificationReadinessStatus.unknown:
      case null:
        return _HealthTone.neutral;
    }
  }

  String _toneLabel(AppLocalizations l, _HealthTone tone) {
    switch (tone) {
      case _HealthTone.ok:
        return l.isEnglish ? 'Healthy' : 'Sehat';
      case _HealthTone.warning:
        return l.isEnglish ? 'Needs attention' : 'Perlu perhatian';
      case _HealthTone.error:
        return l.isEnglish ? 'Action required' : 'Perlu tindakan';
      case _HealthTone.neutral:
        return l.isEnglish ? 'Unknown' : 'Belum diketahui';
    }
  }

  Widget _buildReadinessCard(AppLocalizations l) {
    final readiness = _readiness;
    final tone = _readinessTone(readiness);
    final style = _ToneStyle.of(context, tone);
    final duration = SolatifyMotion.of(context, SolatifyMotion.medium);
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    Widget? fixAction;
    if (!_isLoading && readiness != null) {
      // One clear call-to-action that fixes the detected issue.
      if (readiness.status == NotificationReadinessStatus.inexactScheduling &&
          isAndroid) {
        fixAction = _HealthActionButton(
          primary: true,
          icon: Icons.alarm_on_outlined,
          label: l.openExactAlarmPermission,
          busy: _runningAction == l.openExactAlarmPermission,
          enabled: !_isActionRunning,
          onPressed: () => _openExactAlarm(l),
        );
      } else if (readiness.needsPermissionAction) {
        fixAction = _HealthActionButton(
          primary: true,
          icon: Icons.notifications_active_outlined,
          label: l.notificationHealthOpenSystemSettings,
          busy: _runningAction == l.notificationHealthOpenSystemSettings,
          enabled: !_isActionRunning,
          onPressed: () => _openSettings(l),
        );
      }
    }

    return GlassContainer(
      borderRadius: SolatifyRadius.lg,
      borderColor: readiness == null
          ? null
          : style.color.withValues(alpha: 0.45),
      padding: ResponsiveLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              l.notificationHealthStatus,
              style: TextStyle(
                color: SolatifyColors.muted(context),
                fontSize: SolatifyType.caption,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: SolatifySpacing.sm),
          AnimatedSwitcher(
            duration: duration,
            child: _isLoading && readiness == null
                ? Semantics(
                    key: const ValueKey('loading'),
                    label: l.notificationHealthRefresh,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: SolatifySpacing.lg,
                      ),
                      child: LinearProgressIndicator(),
                    ),
                  )
                : Semantics(
                    key: ValueKey(tone),
                    liveRegion: true,
                    container: true,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingsIconBox(icon: style.icon, color: style.color),
                        const SizedBox(width: SolatifySpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatusPill(
                                label: _toneLabel(l, tone),
                                color: style.color,
                                icon: style.icon,
                              ),
                              const SizedBox(height: SolatifySpacing.xs),
                              Text(
                                readiness?.title ?? l.notificationHealthUnknown,
                                style: TextStyle(
                                  color: SolatifyColors.text(context),
                                  fontSize: SolatifyType.sectionTitle,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                readiness?.message ??
                                    l.notificationHealthUnknownMessage,
                                style: TextStyle(
                                  color: SolatifyColors.muted(context),
                                  fontSize: SolatifyType.caption,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          if (_isLoading && readiness != null) ...[
            const SizedBox(height: SolatifySpacing.sm),
            const LinearProgressIndicator(),
          ],
          if (fixAction != null) ...[
            const SizedBox(height: SolatifySpacing.lg),
            fixAction,
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard(AppLocalizations l) {
    final lastScheduled = _formatDateTime(_history.lastScheduledAt);
    final lastFailed = _formatDateTime(_history.lastFailedAt);
    final pendingPreview = _pendingIds.take(8).join(', ');
    final hasFailure =
        _history.lastFailedAt != null || _history.lastFailedReason != null;

    return GlassContainer(
      borderRadius: SolatifyRadius.lg,
      padding: ResponsiveLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HealthMetricRow(
            icon: Icons.pending_actions_outlined,
            label: l.notificationHealthPendingCount,
            value: _isLoading ? '...' : '${_pendingIds.length}',
          ),
          _HealthMetricRow(
            icon: Icons.tag_rounded,
            label: l.notificationHealthPendingIds,
            value: _pendingIds.isEmpty ? l.none : pendingPreview,
          ),
          _HealthMetricRow(
            icon: Icons.event_available_outlined,
            label: l.notificationHealthLastScheduled,
            value: lastScheduled,
          ),
          _HealthMetricRow(
            icon: Icons.format_list_numbered_rounded,
            label: l.notificationHealthScheduledCount,
            value: '${_history.lastScheduledCount}',
          ),
          _HealthMetricRow(
            icon: Icons.history_rounded,
            label: l.notificationHealthLastFailed,
            value: lastFailed,
            tone: hasFailure ? _HealthTone.error : _HealthTone.ok,
          ),
          _HealthMetricRow(
            icon: Icons.report_outlined,
            label: l.notificationHealthFailureReason,
            value: _history.lastFailedReason ?? l.none,
            tone: _history.lastFailedReason != null
                ? _HealthTone.error
                : _HealthTone.ok,
          ),
          if (hasFailure) ...[
            const SizedBox(height: SolatifySpacing.sm),
            _HealthActionButton(
              primary: true,
              icon: Icons.sync_rounded,
              label: l.notificationHealthReschedule,
              busy: _runningAction == l.notificationHealthReschedule,
              enabled: !_isActionRunning,
              onPressed: () => _reschedule(l),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsCard(AppLocalizations l) {
    return GlassContainer(
      borderRadius: SolatifyRadius.lg,
      padding: ResponsiveLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HealthActionButton(
            icon: Icons.refresh_rounded,
            label: l.notificationHealthRefresh,
            busy: _isLoading && !_isActionRunning,
            enabled: !_isActionRunning && !_isLoading,
            onPressed: _refreshHealth,
          ),
          _HealthActionButton(
            icon: Icons.sync_rounded,
            label: l.notificationHealthReschedule,
            busy: _runningAction == l.notificationHealthReschedule,
            enabled: !_isActionRunning,
            onPressed: () => _reschedule(l),
          ),
          _HealthActionButton(
            icon: Icons.notifications_active_outlined,
            label: l.notificationHealthSendTest,
            busy: _runningAction == l.notificationHealthSendTest,
            enabled: !_isActionRunning,
            onPressed: () => _sendTest(l),
          ),
          _HealthActionButton(
            icon: Icons.settings_outlined,
            label: l.notificationHealthOpenSystemSettings,
            busy: _runningAction == l.notificationHealthOpenSystemSettings,
            enabled: !_isActionRunning,
            onPressed: () => _openSettings(l),
          ),
          if (defaultTargetPlatform == TargetPlatform.android)
            _HealthActionButton(
              icon: Icons.alarm_on_outlined,
              label: l.openExactAlarmPermission,
              busy: _runningAction == l.openExactAlarmPermission,
              enabled: !_isActionRunning,
              onPressed: () => _openExactAlarm(l),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(child: Icon(icon, size: 13, color: color)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: SolatifyType.eyebrow,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthMetricRow extends StatelessWidget {
  const _HealthMetricRow({
    required this.icon,
    required this.label,
    required this.value,
    this.tone,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Optional status; adds a colored status icon next to the value.
  final _HealthTone? tone;

  @override
  Widget build(BuildContext context) {
    final muted = SolatifyColors.muted(context);
    final toneStyle = tone == null ? null : _ToneStyle.of(context, tone!);

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(icon, size: SolatifyIconSize.inline, color: muted),
            ),
            const SizedBox(width: SolatifySpacing.xs),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: muted, fontSize: SolatifyType.caption),
              ),
            ),
            const SizedBox(width: SolatifySpacing.sm),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (toneStyle != null) ...[
                    ExcludeSemantics(
                      child: Icon(
                        toneStyle.icon,
                        size: SolatifyIconSize.inline,
                        color: toneStyle.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: toneStyle?.color ?? SolatifyColors.text(context),
                        fontSize: SolatifyType.caption,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    this.busy = false,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final bool busy;
  final bool primary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final iconWidget = busy
        ? const SizedBox.square(
            dimension: SolatifyIconSize.inline,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon, size: SolatifyIconSize.inline);
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
      alignment: AlignmentDirectional.centerStart,
    );
    final text = Text(label, maxLines: 2, overflow: TextOverflow.ellipsis);

    return Padding(
      padding: const EdgeInsets.only(bottom: SolatifySpacing.sm),
      child: primary
          ? FilledButton.icon(
              style: style,
              onPressed: enabled ? onPressed : null,
              icon: iconWidget,
              label: text,
            )
          : OutlinedButton.icon(
              style: style,
              onPressed: enabled ? onPressed : null,
              icon: iconWidget,
              label: text,
            ),
    );
  }
}
