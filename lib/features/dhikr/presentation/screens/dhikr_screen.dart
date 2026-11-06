import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_screen_scaffold.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/dhikr/domain/models/dhikr_model.dart';
import 'package:solatify/features/dhikr/presentation/providers/dhikr_provider.dart';

/// Morning & evening dhikr reader with an in-session tap counter per item.
///
/// Counter progress is kept in this screen's state (not persisted) so it
/// survives tab switches and list scrolling while the screen is open.
class DhikrScreen extends ConsumerStatefulWidget {
  const DhikrScreen({super.key});

  @override
  ConsumerState<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends ConsumerState<DhikrScreen> {
  final Map<int, int> _morningCounts = {};
  final Map<int, int> _eveningCounts = {};

  Map<int, int> _countsFor(bool isMorning) =>
      isMorning ? _morningCounts : _eveningCounts;

  void _increment(bool isMorning, Dhikr dhikr) {
    final counts = _countsFor(isMorning);
    final target = _targetOf(dhikr);
    final current = counts[dhikr.id] ?? 0;
    if (current >= target) return;
    final next = current + 1;
    setState(() => counts[dhikr.id] = next);
    if (next >= target) {
      SolatifyHaptics.success();
    } else {
      SolatifyHaptics.selection();
    }
  }

  void _reset(bool isMorning, Dhikr dhikr) {
    final counts = _countsFor(isMorning);
    final previous = counts[dhikr.id] ?? 0;
    if (previous == 0) return;
    SolatifyHaptics.light();
    setState(() => counts.remove(dhikr.id));
    _showUndo(
      message: AppLocalizations.of(context).isEnglish
          ? '${dhikr.title} counter reset'
          : 'Hitungan ${dhikr.title} direset',
      onUndo: () => setState(() => counts[dhikr.id] = previous),
    );
  }

  void _resetAll(bool isMorning) {
    final counts = _countsFor(isMorning);
    if (counts.isEmpty) return;
    final snapshot = Map<int, int>.of(counts);
    SolatifyHaptics.light();
    setState(counts.clear);
    _showUndo(
      message: AppLocalizations.of(context).isEnglish
          ? 'All counters reset'
          : 'Semua hitungan direset',
      onUndo: () => setState(() => counts.addAll(snapshot)),
    );
  }

  void _showUndo({required String message, required VoidCallback onUndo}) {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: l.isEnglish ? 'Undo' : 'Urungkan',
            onPressed: () {
              if (mounted) onUndo();
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: SolatifyScreenScaffold(
        title: l.morningEveningDhikr,
        backRoute: AppRoutes.islamicContent,
        padding: EdgeInsets.zero,
        bottom: TabBar(
          labelColor: SolatifyColors.accent(context),
          unselectedLabelColor: SolatifyColors.muted(context),
          indicatorColor: SolatifyColors.accent(context),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: [
            Tab(
              icon: const Icon(Icons.wb_twilight_outlined, size: 18),
              iconMargin: const EdgeInsets.only(bottom: 2),
              text: l.morningDhikr,
            ),
            Tab(
              icon: const Icon(Icons.nightlight_round, size: 18),
              iconMargin: const EdgeInsets.only(bottom: 2),
              text: l.eveningDhikr,
            ),
          ],
        ),
        child: TabBarView(
          children: <Widget>[
            _DhikrListView(
              dhikrList: ref.watch(morningDhikrProvider),
              counts: _morningCounts,
              onIncrement: (dhikr) => _increment(true, dhikr),
              onReset: (dhikr) => _reset(true, dhikr),
              onResetAll: () => _resetAll(true),
            ),
            _DhikrListView(
              dhikrList: ref.watch(eveningDhikrProvider),
              counts: _eveningCounts,
              onIncrement: (dhikr) => _increment(false, dhikr),
              onReset: (dhikr) => _reset(false, dhikr),
              onResetAll: () => _resetAll(false),
            ),
          ],
        ),
      ),
    );
  }
}

int _targetOf(Dhikr dhikr) => dhikr.count < 1 ? 1 : dhikr.count;

class _DhikrListView extends StatelessWidget {
  const _DhikrListView({
    required this.dhikrList,
    required this.counts,
    required this.onIncrement,
    required this.onReset,
    required this.onResetAll,
  });

  final List<Dhikr> dhikrList;
  final Map<int, int> counts;
  final ValueChanged<Dhikr> onIncrement;
  final ValueChanged<Dhikr> onReset;
  final VoidCallback onResetAll;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (dhikrList.isEmpty) {
      return Padding(
        padding: ResponsiveLayout.pagePadding(context),
        child: SolatifyStateView.empty(
          title: l.isEnglish ? 'No dhikr yet' : 'Belum ada dzikir',
          description: l.isEnglish
              ? 'Dhikr readings will appear here once available.'
              : 'Bacaan dzikir akan tampil di sini saat tersedia.',
        ),
      );
    }

    final completed = dhikrList
        .where((dhikr) => (counts[dhikr.id] ?? 0) >= _targetOf(dhikr))
        .length;

    return ResponsiveCenter(
      child: ListView.builder(
        padding: ResponsiveLayout.pagePadding(
          context,
        ).copyWith(top: 16, bottom: ResponsiveLayout.bottomSafeGap),
        itemCount: dhikrList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SessionProgressCard(
              completed: completed,
              total: dhikrList.length,
              canReset: counts.isNotEmpty,
              onResetAll: onResetAll,
            );
          }
          final dhikr = dhikrList[index - 1];
          return _DhikrCard(
            dhikr: dhikr,
            count: counts[dhikr.id] ?? 0,
            onIncrement: () => onIncrement(dhikr),
            onReset: () => onReset(dhikr),
          );
        },
      ),
    );
  }
}

class _SessionProgressCard extends StatelessWidget {
  const _SessionProgressCard({
    required this.completed,
    required this.total,
    required this.canReset,
    required this.onResetAll,
  });

  final int completed;
  final int total;
  final bool canReset;
  final VoidCallback onResetAll;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final done = total > 0 && completed >= total;
    final progressColor = done
        ? SolatifyColors.success(context)
        : SolatifyColors.accent(context);
    final label = l.isEnglish
        ? '$completed of $total completed'
        : '$completed dari $total selesai';

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: SolatifySpacing.md),
      borderRadius: SolatifyRadius.md,
      padding: SolatifySpacing.compactCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  done ? Icons.check_circle_rounded : Icons.timelapse_rounded,
                  color: progressColor,
                  size: SolatifyIconSize.cardIcon,
                ),
              ),
              const SizedBox(width: SolatifySpacing.sm),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    done
                        ? (l.isEnglish
                              ? 'All done, may it be accepted'
                              : 'Semua selesai, semoga diterima')
                        : label,
                    style: TextStyle(
                      color: SolatifyColors.text(context),
                      fontWeight: FontWeight.w700,
                      fontSize: SolatifyType.body,
                    ),
                  ),
                ),
              ),
              if (canReset)
                TextButton.icon(
                  onPressed: onResetAll,
                  icon: const Icon(
                    Icons.restart_alt_rounded,
                    size: SolatifyIconSize.inline,
                  ),
                  label: Text(l.isEnglish ? 'Reset' : 'Ulang'),
                ),
            ],
          ),
          const SizedBox(height: SolatifySpacing.xs),
          _AnimatedProgressBar(
            value: total == 0 ? 0 : completed / total,
            color: progressColor,
          ),
        ],
      ),
    );
  }
}

class _DhikrCard extends StatelessWidget {
  const _DhikrCard({
    required this.dhikr,
    required this.count,
    required this.onIncrement,
    required this.onReset,
  });

  final Dhikr dhikr;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = SolatifyColors.accent(context);
    final textColor = SolatifyColors.text(context);
    final muted = SolatifyColors.muted(context);
    final target = _targetOf(dhikr);
    final done = count >= target;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: SolatifySpacing.md),
      borderRadius: SolatifyRadius.lg,
      borderColor: done ? SolatifyColors.success(context) : null,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(
                header: true,
                child: Text(
                  dhikr.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SolatifyType.sectionTitle,
                    height: 1.25,
                    color: textColor,
                  ),
                ),
              ),
              if (dhikr.count > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: SolatifyColors.accentSoft(context),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    l.isEnglish
                        ? 'Read ${dhikr.count}x'
                        : 'Dibaca ${dhikr.count}x',
                    style: TextStyle(
                      color: accent,
                      fontSize: SolatifyType.caption,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            key: const Key('dhikr_arabic_text_block'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: SolatifyColors.accentSoft(context),
              borderRadius: SolatifyRadius.compactCard,
              border: Border.all(color: SolatifyColors.border(context)),
            ),
            child: Text(
              dhikr.arabicText,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              softWrap: true,
              style: TextStyle(color: textColor, fontSize: 24, height: 2.0),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            dhikr.latinText,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: muted,
              fontSize: SolatifyType.body,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            dhikr.meaning,
            style: TextStyle(
              color: textColor,
              fontSize: SolatifyType.body,
              height: 1.5,
            ),
          ),
          if (dhikr.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SolatifyColors.raisedSurface(context),
                borderRadius: SolatifyRadius.icon,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: SolatifyIconSize.inline,
                      color: muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dhikr.note,
                      style: TextStyle(
                        fontSize: SolatifyType.caption,
                        height: 1.45,
                        color: muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          _DhikrCounter(
            title: dhikr.title,
            count: count,
            target: target,
            onIncrement: onIncrement,
            onReset: onReset,
          ),
        ],
      ),
    );
  }
}

/// Large, thumb-friendly counter: the whole pill is the tap target.
class _DhikrCounter extends StatelessWidget {
  const _DhikrCounter({
    required this.title,
    required this.count,
    required this.target,
    required this.onIncrement,
    required this.onReset,
  });

  final String title;
  final int count;
  final int target;
  final VoidCallback onIncrement;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final done = count >= target;
    final accent = SolatifyColors.accent(context);
    final success = SolatifyColors.success(context);
    final color = done ? success : accent;
    final hint = done
        ? (l.isEnglish ? 'Completed' : 'Selesai')
        : (l.isEnglish ? 'Tap to count' : 'Ketuk untuk menghitung');
    final semanticsValue = l.isEnglish
        ? '$count of $target${done ? ', completed' : ''}'
        : '$count dari $target${done ? ', selesai' : ''}';

    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            enabled: !done,
            liveRegion: true,
            label: l.isEnglish ? 'Count $title' : 'Hitung $title',
            value: semanticsValue,
            excludeSemantics: true,
            onTap: done ? null : onIncrement,
            child: Material(
              color: done
                  ? success.withValues(alpha: 0.12)
                  : SolatifyColors.accentSoft(context),
              shape: RoundedRectangleBorder(
                borderRadius: SolatifyRadius.compactCard,
                side: BorderSide(color: color.withValues(alpha: 0.45)),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: done ? null : onIncrement,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SolatifySpacing.md,
                      vertical: SolatifySpacing.sm,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              done
                                  ? Icons.check_circle_rounded
                                  : Icons.touch_app_rounded,
                              color: color,
                              size: SolatifyIconSize.heroIcon,
                            ),
                            const SizedBox(width: SolatifySpacing.sm),
                            Expanded(
                              child: Text(
                                hint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: SolatifyType.body,
                                ),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: SolatifyMotion.of(
                                context,
                                SolatifyMotion.fast,
                              ),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.85,
                                      end: 1,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  ),
                              child: Text(
                                '$count / $target',
                                key: ValueKey<int>(count),
                                style: TextStyle(
                                  color: SolatifyColors.text(context),
                                  fontWeight: FontWeight.w800,
                                  fontSize: SolatifyType.heroTitle,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: SolatifySpacing.xs),
                        _AnimatedProgressBar(
                          value: count / target,
                          color: color,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: SolatifySpacing.xs),
        IconButton(
          tooltip: l.isEnglish ? 'Reset counter' : 'Reset hitungan',
          constraints: const BoxConstraints(
            minWidth: SolatifyTapTarget.min,
            minHeight: SolatifyTapTarget.min,
          ),
          onPressed: count == 0 ? null : onReset,
          icon: const Icon(Icons.restart_alt_rounded),
        ),
      ],
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: value.clamp(0, 1).toDouble()),
        duration: SolatifyMotion.of(context, SolatifyMotion.medium),
        curve: SolatifyMotion.curve,
        builder: (context, animated, _) => ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: animated,
            minHeight: 6,
            color: color,
            backgroundColor: SolatifyColors.raisedSurface(context),
          ),
        ),
      ),
    );
  }
}
