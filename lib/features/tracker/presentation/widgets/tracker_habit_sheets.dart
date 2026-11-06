import 'package:flutter/material.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_ui_helpers.dart';

class TrackerHabitTemplate {
  const TrackerHabitTemplate({
    required this.name,
    this.target,
    this.unit = 'kali',
  });

  final String name;
  final int? target;
  final String unit;

  bool get hasTarget => target != null;
}

const trackerHabitTemplates = [
  TrackerHabitTemplate(name: 'Shalawat 100x', target: 100, unit: 'kali'),
  TrackerHabitTemplate(name: 'Baca Al-Kahfi'),
  TrackerHabitTemplate(name: 'Sedekah Harian'),
  TrackerHabitTemplate(name: 'Dzikir Pagi'),
  TrackerHabitTemplate(name: 'Tilawah 2 halaman', target: 2, unit: 'halaman'),
  TrackerHabitTemplate(name: 'Murojaah 15 menit', target: 15, unit: 'menit'),
];

typedef TrackerAddHabit =
    void Function(String habitName, int? target, String unit);

void showTrackerAddHabitSheet(
  BuildContext context, {
  required List<String> customHabits,
  required TrackerAddHabit onAddHabit,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        _AddHabitSheet(customHabits: customHabits, onAddHabit: onAddHabit),
  );
}

void showTrackerManageHabitSheet(
  BuildContext context, {
  required List<String> customHabits,
  required void Function(String oldName, String newName) onRenameHabit,
  required ValueChanged<String> onDeleteHabit,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final isEnglish = trackerIsEnglish(sheetContext);
      return TrackerSheetFrame(
        title: isEnglish ? 'Manage Custom Habits' : 'Kelola Habit Custom',
        subtitle: isEnglish
            ? 'Rename or delete the custom habits you created.'
            : 'Ubah nama atau hapus habit custom yang sudah kamu buat.',
        children: [
          for (final habit in customHabits)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(habit),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: isEnglish ? 'Rename $habit' : 'Ubah nama $habit',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _showRenameHabitSheet(
                        context,
                        oldName: habit,
                        onRenameHabit: onRenameHabit,
                      );
                    },
                  ),
                  IconButton(
                    tooltip: isEnglish ? 'Delete $habit' : 'Hapus $habit',
                    icon: Icon(
                      Icons.delete_outline,
                      color: SolatifyColors.error(sheetContext),
                    ),
                    onPressed: () async {
                      final confirmed = await _confirmDelete(
                        sheetContext,
                        habit,
                      );
                      if (!confirmed || !sheetContext.mounted) return;
                      Navigator.of(sheetContext).pop();
                      onDeleteHabit(habit);
                    },
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

Future<bool> _confirmDelete(BuildContext context, String habit) async {
  final isEnglish = trackerIsEnglish(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isEnglish ? 'Delete "$habit"?' : 'Hapus "$habit"?'),
      content: Text(
        isEnglish
            ? 'The habit will be removed from every date.'
            : 'Habit ini akan hilang dari semua tanggal.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(isEnglish ? 'Cancel' : 'Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: SolatifyColors.error(dialogContext),
            foregroundColor: Theme.of(dialogContext).colorScheme.onError,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(isEnglish ? 'Delete' : 'Hapus'),
        ),
      ],
    ),
  );
  return result ?? false;
}

void _showRenameHabitSheet(
  BuildContext context, {
  required String oldName,
  required void Function(String oldName, String newName) onRenameHabit,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        _RenameHabitSheet(oldName: oldName, onRenameHabit: onRenameHabit),
  );
}

class _AddHabitSheet extends StatefulWidget {
  const _AddHabitSheet({required this.customHabits, required this.onAddHabit});

  final List<String> customHabits;
  final TrackerAddHabit onAddHabit;

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _unitController = TextEditingController(text: 'kali');

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _applyTemplate(TrackerHabitTemplate template) {
    _nameController.text = template.name;
    _targetController.text = template.target?.toString() ?? '';
    _unitController.text = template.unit;
  }

  void _submit() {
    final habitName = _nameController.text.trim();
    if (habitName.isEmpty) return;
    final target = int.tryParse(_targetController.text.trim());
    final unit = _unitController.text.trim().isEmpty
        ? 'kali'
        : _unitController.text.trim();
    Navigator.of(context).pop();
    widget.onAddHabit(
      habitName,
      target != null && target > 0 ? target : null,
      unit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);

    return TrackerSheetFrame(
      title: isEnglish ? 'Add Custom Habit' : 'Tambah Habit Custom',
      children: [
        Text(
          isEnglish ? 'Popular Templates' : 'Template Populer',
          style: TextStyle(
            color: SolatifyColors.text(context),
            fontSize: SolatifyType.caption + 1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: SolatifySpacing.xs + 2),
        Wrap(
          spacing: SolatifySpacing.xs + 2,
          runSpacing: SolatifySpacing.xs + 2,
          children: trackerHabitTemplates.map((template) {
            final alreadyExists = widget.customHabits.contains(template.name);
            return ActionChip(
              label: Text(template.name),
              tooltip: alreadyExists
                  ? (isEnglish ? 'Already added' : 'Sudah ditambahkan')
                  : null,
              avatar: Icon(
                alreadyExists
                    ? Icons.check_rounded
                    : template.hasTarget
                    ? Icons.track_changes_outlined
                    : Icons.check_circle_outline,
                size: SolatifyIconSize.inline,
              ),
              onPressed: alreadyExists ? null : () => _applyTemplate(template),
            );
          }).toList(),
        ),
        const SizedBox(height: SolatifySpacing.md),
        TextField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Habit name' : 'Nama habit',
            hintText: isEnglish
                ? 'Example: Read Al-Kahfi'
                : 'Contoh: Baca Al-Kahfi',
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: SolatifySpacing.sm + 2),
        TextField(
          controller: _targetController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Optional target' : 'Target opsional',
            hintText: isEnglish ? 'Example: 100' : 'Contoh: 100',
          ),
        ),
        const SizedBox(height: SolatifySpacing.sm + 2),
        TextField(
          controller: _unitController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Unit' : 'Satuan',
            hintText: isEnglish
                ? 'times, pages, minutes'
                : 'kali, halaman, menit',
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: SolatifySpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.add),
            label: Text(isEnglish ? 'Save Habit' : 'Simpan Habit'),
          ),
        ),
      ],
    );
  }
}

class _RenameHabitSheet extends StatefulWidget {
  const _RenameHabitSheet({required this.oldName, required this.onRenameHabit});

  final String oldName;
  final void Function(String oldName, String newName) onRenameHabit;

  @override
  State<_RenameHabitSheet> createState() => _RenameHabitSheetState();
}

class _RenameHabitSheetState extends State<_RenameHabitSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.oldName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final newName = _controller.text.trim();
    if (newName.isEmpty) return;
    Navigator.of(context).pop();
    widget.onRenameHabit(widget.oldName, newName);
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);

    return TrackerSheetFrame(
      title: isEnglish ? 'Rename Habit' : 'Ubah Nama Habit',
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Habit name' : 'Nama habit',
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: SolatifySpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check),
            label: Text(isEnglish ? 'Save Changes' : 'Simpan Perubahan'),
          ),
        ),
      ],
    );
  }
}
