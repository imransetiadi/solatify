import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/prayer_offsets.dart';

export 'package:solatify/features/prayer_schedule/domain/entities/prayer_offsets.dart'
    show kPrayerOffsetMax, kPrayerOffsetMin;

int normalizePrayerOffsetInput(String value) {
  final parsed = int.tryParse(value.trim());
  if (parsed == null) return 0;
  return parsed.clamp(kPrayerOffsetMin, kPrayerOffsetMax).toInt();
}

final prayerOffsetInputFormatter = TextInputFormatter.withFunction((
  oldValue,
  newValue,
) {
  final text = newValue.text;
  if (text.isEmpty || text == '-' || RegExp(r'^-?\d{1,2}$').hasMatch(text)) {
    return newValue;
  }

  if (RegExp(r'^-?60$').hasMatch(text)) return newValue;
  return oldValue;
});

/// Formats a correction as `+5 menit`, `-3 menit` or `0 menit`.
String formatPrayerOffset(AppLocalizations l, int offset) =>
    '${offset > 0 ? '+' : ''}$offset ${l.minutes}';

/// Shows the correction editor and resolves with the new value, or `null`
/// when cancelled.
///
/// [standardTimes] are today's times without any correction; when given,
/// the dialog previews the resulting time and refuses values that would
/// move the prayer past its neighbours ([offsets] holds their corrections).
Future<int?> showPrayerOffsetDialog({
  required BuildContext context,
  required String title,
  required String prayerKey,
  required int initialOffset,
  Map<String, DateTime>? standardTimes,
  Map<String, int> offsets = const {},
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => PrayerOffsetDialog(
      title: title,
      prayerKey: prayerKey,
      initialOffset: initialOffset,
      standardTimes: standardTimes,
      offsets: offsets,
    ),
  );
}

/// Dialog with +/- steppers and a numeric field for a prayer correction.
class PrayerOffsetDialog extends StatefulWidget {
  const PrayerOffsetDialog({
    super.key,
    required this.title,
    required this.initialOffset,
    this.prayerKey = 'subuh',
    this.standardTimes,
    this.offsets = const {},
  });

  final String title;
  final String prayerKey;
  final int initialOffset;
  final Map<String, DateTime>? standardTimes;
  final Map<String, int> offsets;

  @override
  State<PrayerOffsetDialog> createState() => _PrayerOffsetDialogState();
}

class _PrayerOffsetDialogState extends State<PrayerOffsetDialog> {
  late final TextEditingController _controller;

  /// Parsed, in-range value; `null` when the field is invalid.
  int? _value;
  String? _inputError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialOffset
        .clamp(kPrayerOffsetMin, kPrayerOffsetMax)
        .toInt();
    _value = initial;
    _controller = TextEditingController(text: initial.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasStandardTimes {
    final times = widget.standardTimes;
    return times != null && times.containsKey(widget.prayerKey);
  }

  PrayerOffsetCheck? _check(int value) {
    if (!_hasStandardTimes) return null;
    return checkPrayerOffset(
      prayerKey: widget.prayerKey,
      minutes: value,
      standardTimes: widget.standardTimes!,
      offsets: widget.offsets,
    );
  }

  void _validate(String text, AppLocalizations l) {
    final parsed = int.tryParse(text.trim());
    setState(() {
      if (parsed == null) {
        _value = null;
        _inputError = l.isEnglish
            ? 'Enter a number of minutes.'
            : 'Masukkan jumlah menit.';
      } else if (parsed < kPrayerOffsetMin || parsed > kPrayerOffsetMax) {
        _value = null;
        _inputError = l.prayerOffsetLimitHint;
      } else {
        _value = parsed;
        _inputError = null;
      }
    });
  }

  void _setValue(int next) {
    final clamped = next.clamp(kPrayerOffsetMin, kPrayerOffsetMax).toInt();
    SolatifyHaptics.selection();
    setState(() {
      _value = clamped;
      _inputError = null;
      _controller.value = TextEditingValue(
        text: clamped.toString(),
        selection: TextSelection.collapsed(offset: clamped.toString().length),
      );
    });
  }

  void _step(int delta) {
    final base = _value ?? normalizePrayerOffsetInput(_controller.text);
    _setValue(base + delta);
  }

  void _save() {
    final value = _value;
    if (value == null || !(_check(value)?.keepsPrayerOrder ?? true)) return;
    Navigator.of(context).pop(value);
  }

  String? _orderError(AppLocalizations l, PrayerOffsetCheck? check) {
    if (check == null || check.keepsPrayerOrder) return null;
    final name = l.prayerName(widget.prayerKey);
    final after = check.mustStayAfter;
    if (after != null) {
      final other = l.prayerName(after);
      return l.isEnglish
          ? '$name would no longer come after $other.'
          : '$name akan jatuh sebelum atau bersamaan dengan $other.';
    }
    final other = l.prayerName(check.mustStayBefore!);
    return l.isEnglish
        ? '$name would no longer come before $other.'
        : '$name akan jatuh setelah atau bersamaan dengan $other.';
  }

  String _effectLabel(AppLocalizations l, int value) {
    if (value == 0) {
      return l.isEnglish
          ? 'Same as the standard time. ${l.offsetNegativeHint}'
          : 'Sama dengan waktu standar. ${l.offsetNegativeHint}';
    }
    final minutes = value.abs();
    if (value > 0) {
      return l.isEnglish
          ? '$minutes ${l.minutes} later than standard.'
          : '$minutes ${l.minutes} lebih lambat dari standar.';
    }
    return l.isEnglish
        ? '$minutes ${l.minutes} earlier than standard.'
        : '$minutes ${l.minutes} lebih awal dari standar.';
  }

  String _cautionText(AppLocalizations l) {
    final name = l.prayerName(widget.prayerKey);
    final isMagrib = widget.prayerKey == 'magrib';
    if (l.isEnglish) {
      return isMagrib
          ? 'The adhan will sound before the standard $name time, which is '
                'also when the fast ends. Only do this to match your local '
                'mosque.'
          : 'The adhan will sound before the standard $name time, which also '
                'marks the start of the fast. Only do this to match your '
                'local mosque.';
    }
    return isMagrib
        ? 'Adzan akan berbunyi sebelum waktu $name standar, yang juga waktu '
              'berbuka puasa. Lakukan hanya untuk menyamakan dengan masjid '
              'setempat.'
        : 'Adzan akan berbunyi sebelum waktu $name standar, yang juga batas '
              'mulai puasa. Lakukan hanya untuk menyamakan dengan masjid '
              'setempat.';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = SolatifyColors.accent(context);
    final muted = SolatifyColors.muted(context);
    final value = _value;
    final check = value == null ? null : _check(value);
    final orderError = _orderError(l, check);
    final canSave = value != null && orderError == null;
    final canDecrease = (value ?? 0) > kPrayerOffsetMin;
    final canIncrease = (value ?? 0) < kPrayerOffsetMax;
    final timeFormat = DateFormat('HH:mm');

    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: SolatifySpacing.lg,
        vertical: SolatifySpacing.xl,
      ),
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.adjustOffsetHint,
            style: TextStyle(color: muted, height: 1.35),
          ),
          if (_hasStandardTimes) ...[
            const SizedBox(height: SolatifySpacing.sm),
            Semantics(
              liveRegion: true,
              child: Container(
                padding: SolatifySpacing.pill,
                decoration: BoxDecoration(
                  color: SolatifyColors.accentSoft(context),
                  borderRadius: SolatifyRadius.icon,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: SolatifyIconSize.inline,
                      color: accent,
                    ),
                    const SizedBox(width: SolatifySpacing.xs),
                    Expanded(
                      child: Text(
                        l.isEnglish
                            ? 'Today: standard '
                                  '${timeFormat.format(widget.standardTimes![widget.prayerKey]!)}'
                                  '${check == null ? '' : ', becomes ${timeFormat.format(check.correctedTime)}'}'
                            : 'Hari ini: standar '
                                  '${timeFormat.format(widget.standardTimes![widget.prayerKey]!)}'
                                  '${check == null ? '' : ', menjadi ${timeFormat.format(check.correctedTime)}'}',
                        style: TextStyle(
                          color: SolatifyColors.text(context),
                          fontSize: SolatifyType.caption,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: SolatifySpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: IconButton.filledTonal(
                  tooltip: l.isEnglish
                      ? 'Earlier by 1 minute'
                      : 'Majukan 1 menit',
                  onPressed: canDecrease ? () => _step(-1) : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
              ),
              const SizedBox(width: SolatifySpacing.sm),
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [prayerOffsetInputFormatter],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SolatifyType.heroTitle,
                    fontWeight: FontWeight.w800,
                    color: SolatifyColors.text(context),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: l.minutes,
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    helperText: l.prayerOffsetLimitHint,
                    helperMaxLines: 2,
                    errorText: _inputError ?? orderError,
                    errorMaxLines: 3,
                  ),
                  onChanged: (text) => _validate(text, l),
                  onSubmitted: (_) => _save(),
                ),
              ),
              const SizedBox(width: SolatifySpacing.sm),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: IconButton.filledTonal(
                  tooltip: l.isEnglish
                      ? 'Later by 1 minute'
                      : 'Mundurkan 1 menit',
                  onPressed: canIncrease ? () => _step(1) : null,
                  icon: const Icon(Icons.add_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: SolatifySpacing.sm),
          AnimatedSwitcher(
            duration: SolatifyMotion.of(context, SolatifyMotion.fast),
            child: Semantics(
              key: ValueKey<int?>(value),
              liveRegion: true,
              child: Text(
                value == null ? '' : _effectLabel(l, value),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: SolatifyType.caption,
                  height: 1.35,
                ),
              ),
            ),
          ),
          if (value != null &&
              value < 0 &&
              prayersSensitiveToEarlierCorrection.contains(
                widget.prayerKey,
              )) ...[
            const SizedBox(height: SolatifySpacing.sm),
            Container(
              padding: SolatifySpacing.pill,
              decoration: BoxDecoration(
                color: SolatifyColors.warning(context).withValues(alpha: 0.12),
                borderRadius: SolatifyRadius.icon,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: SolatifyIconSize.inline,
                    color: SolatifyColors.warning(context),
                  ),
                  const SizedBox(width: SolatifySpacing.xs),
                  Expanded(
                    child: Text(
                      _cautionText(l),
                      style: TextStyle(
                        color: SolatifyColors.text(context),
                        fontSize: SolatifyType.caption,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (value != 0) ...[
            const SizedBox(height: SolatifySpacing.xs),
            Center(
              child: TextButton.icon(
                onPressed: () => _setValue(0),
                icon: const Icon(
                  Icons.restart_alt_rounded,
                  size: SolatifyIconSize.inline,
                ),
                label: Text(l.isEnglish ? 'Reset to 0' : 'Kembalikan ke 0'),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: canSave ? _save : null, child: Text(l.save)),
      ],
    );
  }
}
