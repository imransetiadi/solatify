import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/utils/location_service.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';

Future<void> showManualLocationDialog({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  // Resolve the messenger up-front so the confirmation can still be shown
  // after the dialog route has been popped.
  final messenger = ScaffoldMessenger.maybeOf(context);
  await showDialog<void>(
    context: context,
    builder: (_) => _ManualLocationDialog(ref: ref, messenger: messenger),
  );
}

/// Size of the dialog body that never overflows on 320px screens or when the
/// software keyboard is open.
Size manualLocationDialogBodySize(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final keyboard = MediaQuery.viewInsetsOf(context).bottom;
  // 20px inset on each side + 24px content padding on each side.
  final width = math.min(560.0, math.max(0.0, size.width - 88));
  final height = ((size.height - keyboard) * 0.55).clamp(180.0, 520.0);
  return Size(width, height);
}

class _ManualLocationDialog extends StatefulWidget {
  const _ManualLocationDialog({required this.ref, required this.messenger});

  final WidgetRef ref;
  final ScaffoldMessengerState? messenger;

  @override
  State<_ManualLocationDialog> createState() => _ManualLocationDialogState();
}

class _ManualLocationDialogState extends State<_ManualLocationDialog> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  OfflineCity? _saving;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _select(OfflineCity city) async {
    if (_saving != null) return;
    SolatifyHaptics.selection();
    setState(() => _saving = city);
    try {
      await widget.ref.read(locationProvider.notifier).setManualCity(city);
    } catch (error) {
      debugPrint('Manual location update failed: $error');
    }
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    Navigator.pop(context);
    widget.messenger?.showSnackBar(
      SnackBar(
        content: Text(
          l.isEnglish
              ? 'Location changed to ${city.name}, ${city.country}'
              : 'Lokasi diubah ke ${city.name}, ${city.country}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = SolatifyColors.accent(context);
    final muted = SolatifyColors.muted(context);
    final current = widget.ref.read(locationProvider);
    final query = _query.toLowerCase().trim();
    final cities = LocationService.defaultCities.where((city) {
      if (query.isEmpty) return true;
      return city.name.toLowerCase().contains(query) ||
          city.country.toLowerCase().contains(query);
    }).toList();
    final bodySize = manualLocationDialogBodySize(context);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: SolatifySpacing.xl,
      ),
      title: Semantics(
        header: true,
        child: Text(
          l.isEnglish ? 'Change Location Manually' : 'Ubah Lokasi Manual',
        ),
      ),
      content: SizedBox(
        width: bodySize.width,
        height: bodySize.height,
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l.isEnglish
                    ? 'Search city or province...'
                    : 'Cari kota atau provinsi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l.isEnglish
                            ? 'Clear search'
                            : 'Hapus pencarian',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: SolatifySpacing.sm),
            Expanded(
              child: AnimatedSwitcher(
                duration: SolatifyMotion.of(context, SolatifyMotion.fast),
                child: cities.isEmpty
                    ? SingleChildScrollView(
                        key: const ValueKey('no-city'),
                        child: SolatifyStateView.empty(
                          compact: true,
                          icon: Icons.location_off_outlined,
                          title: l.isEnglish
                              ? 'City not found'
                              : 'Kota tidak ditemukan',
                          description: l.isEnglish
                              ? 'Try another city or province name.'
                              : 'Coba nama kota atau provinsi lain.',
                        ),
                      )
                    : ListView.separated(
                        key: const ValueKey('city-list'),
                        itemCount: cities.length,
                        separatorBuilder: (_, _) => Divider(
                          color: SolatifyColors.border(context),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final city = cities[index];
                          final isCurrent =
                              city.name == current.city &&
                              city.country == current.country;
                          final isSaving = identical(_saving, city);
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            selected: isCurrent,
                            enabled: _saving == null || isSaving,
                            leading: Icon(
                              isCurrent
                                  ? Icons.my_location_rounded
                                  : Icons.location_city_rounded,
                              color: accent,
                            ),
                            title: Text(
                              city.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: SolatifyColors.text(context),
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              isCurrent
                                  ? '${city.country} • '
                                        '${l.isEnglish ? 'Current' : 'Saat ini'}'
                                  : city.country,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: muted,
                                fontSize: SolatifyType.caption,
                              ),
                            ),
                            trailing: isSaving
                                ? SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: accent,
                                    ),
                                  )
                                : Icon(
                                    isCurrent
                                        ? Icons.check_circle_rounded
                                        : Icons.chevron_right_rounded,
                                    color: isCurrent ? accent : muted,
                                  ),
                            onTap: () => _select(city),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
      ],
    );
  }
}
