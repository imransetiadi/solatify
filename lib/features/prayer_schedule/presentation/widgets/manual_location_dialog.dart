import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/location_service.dart';
import '../location_provider.dart';

Future<void> showManualLocationDialog({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      String searchQuery = '';
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = isDark ? Colors.white : const Color(0xFF241A12);
          final mutedColor = isDark
              ? const Color(0xFFC8B8A8)
              : const Color(0xFF5D4E47);
          final borderColor = isDark
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.black12;
          final bgColor = isDark ? const Color(0xFF2A1B12) : Colors.white;
          final accent = isDark
              ? const Color(0xFFC78A4C)
              : const Color(0xFF0E4D31);
          final cities = LocationService.defaultCities.where((city) {
            final query = searchQuery.toLowerCase().trim();
            if (query.isEmpty) return true;
            return city.name.toLowerCase().contains(query) ||
                city.country.toLowerCase().contains(query);
          }).toList();

          return AlertDialog(
            backgroundColor: bgColor,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(
              'Ubah Lokasi Manual',
              style: TextStyle(color: textColor),
            ),
            content: SizedBox(
              width: (MediaQuery.sizeOf(context).width - 40).clamp(
                320.0,
                560.0,
              ),
              height: MediaQuery.sizeOf(context).height * 0.62,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Cari kota atau provinsi...',
                      hintStyle: TextStyle(color: mutedColor),
                      prefixIcon: Icon(Icons.search, color: mutedColor),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFF3FBF6),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: accent, width: 1.4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onChanged: (value) =>
                        setDialogState(() => searchQuery = value),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: cities.isEmpty
                        ? Center(
                            child: Text(
                              'Kota tidak ditemukan',
                              style: TextStyle(color: mutedColor),
                            ),
                          )
                        : ListView.separated(
                            itemCount: cities.length,
                            separatorBuilder: (_, _) =>
                                Divider(color: borderColor, height: 1),
                            itemBuilder: (context, index) {
                              final city = cities[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.location_city,
                                  color: accent,
                                ),
                                title: Text(
                                  city.name,
                                  style: TextStyle(color: textColor),
                                ),
                                subtitle: Text(
                                  city.country,
                                  style: TextStyle(
                                    color: mutedColor,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: mutedColor,
                                ),
                                onTap: () async {
                                  await ref
                                      .read(locationProvider.notifier)
                                      .setManualCity(city);
                                  if (context.mounted) Navigator.pop(context);
                                  if (dialogContext.mounted) {
                                    ScaffoldMessenger.of(
                                      dialogContext,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Lokasi diubah ke ${city.name}, ${city.country}',
                                        ),
                                        backgroundColor: const Color(
                                          0xFF0E4D31,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal', style: TextStyle(color: mutedColor)),
              ),
            ],
          );
        },
      );
    },
  );
}
