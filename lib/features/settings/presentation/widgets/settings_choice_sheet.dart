import 'package:flutter/material.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';

/// One selectable option shown by [showSettingsChoiceSheet].
class SettingsChoice<T> {
  const SettingsChoice({
    required this.value,
    required this.label,
    this.description,
    this.icon,
  });

  final T value;
  final String label;
  final String? description;
  final IconData? icon;
}

/// Shows a themed bottom sheet with a radio list and returns the picked
/// value, or `null` when dismissed. The current selection is highlighted.
Future<T?> showSettingsChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<SettingsChoice<T>> choices,
  required T selected,
  String? description,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _SettingsChoiceSheet<T>(
      title: title,
      description: description,
      choices: choices,
      selected: selected,
    ),
  );
}

class _SettingsChoiceSheet<T> extends StatefulWidget {
  const _SettingsChoiceSheet({
    required this.title,
    required this.choices,
    required this.selected,
    this.description,
  });

  final String title;
  final String? description;
  final List<SettingsChoice<T>> choices;
  final T selected;

  @override
  State<_SettingsChoiceSheet<T>> createState() =>
      _SettingsChoiceSheetState<T>();
}

class _SettingsChoiceSheetState<T> extends State<_SettingsChoiceSheet<T>> {
  late T _selected = widget.selected;
  bool _closing = false;

  void _select(T? value) {
    if (value == null || _closing) return;
    _closing = true;
    SolatifyHaptics.selection();
    // Mark the new choice first so the user sees immediate feedback,
    // then close on the next frame.
    setState(() => _selected = value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.8;
    final accent = SolatifyColors.accent(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          SolatifySpacing.sm,
          0,
          SolatifySpacing.sm,
          SolatifySpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SolatifySpacing.md,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: SolatifyColors.text(context),
                    fontSize: SolatifyType.pageTitle,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (widget.description != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SolatifySpacing.md,
                  4,
                  SolatifySpacing.md,
                  0,
                ),
                child: Text(
                  widget.description!,
                  style: TextStyle(
                    color: SolatifyColors.muted(context),
                    fontSize: SolatifyType.caption,
                    height: 1.35,
                  ),
                ),
              ),
            const SizedBox(height: SolatifySpacing.sm),
            RadioGroup<T>(
              groupValue: _selected,
              onChanged: _select,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final choice in widget.choices)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: RadioListTile<T>(
                        value: choice.value,
                        selected: choice.value == _selected,
                        selectedTileColor: SolatifyColors.accentSoft(context),
                        activeColor: accent,
                        controlAffinity: ListTileControlAffinity.trailing,
                        secondary: choice.icon == null
                            ? null
                            : Icon(choice.icon),
                        title: Text(
                          choice.label,
                          style: TextStyle(
                            color: choice.value == _selected
                                ? accent
                                : SolatifyColors.text(context),
                            fontSize: SolatifyType.body,
                            fontWeight: choice.value == _selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        subtitle: choice.description == null
                            ? null
                            : Text(choice.description!),
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
