import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';

/// Smallest / largest allowed prayer time correction in minutes.
const int kPrayerOffsetMin = -60;
const int kPrayerOffsetMax = 60;

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

/// Formats an offset as `+5 menit`, `-3 menit` or `0 menit`.
String formatPrayerOffset(AppLocalizations l, int offset) =>
    '${offset > 0 ? '+' : ''}$offset ${l.minutes}';

/// Shows the offset editor and resolves with the new offset, or `null`
/// when cancelled.
Future<int?> showPrayerOffsetDialog({
  required BuildContext context,
  required String title,
  required int initialOffset,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) =>
        PrayerOffsetDialog(title: title, initialOffset: initialOffset),
  );
}

/// Dialog with +/- steppers and a numeric field for a prayer offset.
class PrayerOffsetDialog extends StatefulWidget {
  const PrayerOffsetDialog({
    super.key,
    required this.title,
    required this.initialOffset,
  });

  final String title;
  final int initialOffset;

  @override
  State<PrayerOffsetDialog> createState() => _PrayerOffsetDialogState();
}

class _PrayerOffsetDialogState extends State<PrayerOffsetDialog> {
  late final TextEditingController _controller;

  /// Parsed, in-range value; `null` when the field is invalid.
  int? _value;
  String? _error;

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

  void _validate(String text, AppLocalizations l) {
    final trimmed = text.trim();
    final parsed = int.tryParse(trimmed);
    setState(() {
      if (parsed == null) {
        _value = null;
        _error = l.isEnglish
            ? 'Enter a number of minutes.'
            : 'Masukkan jumlah menit.';
      } else if (parsed < kPrayerOffsetMin || parsed > kPrayerOffsetMax) {
        _value = null;
        _error = l.prayerOffsetLimitHint;
      } else {
        _value = parsed;
        _error = null;
      }
    });
  }

  void _setValue(int next) {
    final clamped = next.clamp(kPrayerOffsetMin, kPrayerOffsetMax).toInt();
    SolatifyHaptics.selection();
    setState(() {
      _value = clamped;
      _error = null;
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
    if (value == null) return;
    Navigator.of(context).pop(value);
  }

  String _effectLabel(AppLocalizations l, int value) {
    if (value == 0) {
      return l.isEnglish
          ? 'Matches the standard time. ${l.offsetNegativeHint}'
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = SolatifyColors.accent(context);
    final muted = SolatifyColors.muted(context);
    final value = _value;
    final canDecrease = (value ?? 0) > kPrayerOffsetMin;
    final canIncrease = (value ?? 0) < kPrayerOffsetMax;

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
          const SizedBox(height: SolatifySpacing.sm),
          Container(
            padding: SolatifySpacing.pill,
            decoration: BoxDecoration(
              color: SolatifyColors.accentSoft(context),
              borderRadius: SolatifyRadius.icon,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.straighten_rounded,
                  size: SolatifyIconSize.inline,
                  color: accent,
                ),
                const SizedBox(width: SolatifySpacing.xs),
                Expanded(
                  child: Text(
                    l.prayerOffsetLimitHint,
                    style: TextStyle(
                      color: SolatifyColors.text(context),
                      fontSize: SolatifyType.caption,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                    errorText: _error,
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
        FilledButton(
          onPressed: value == null ? null : _save,
          child: Text(l.save),
        ),
      ],
    );
  }
}
