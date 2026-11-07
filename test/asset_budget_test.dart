import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Asset budgets', () {
    int assetSize(String path) => File(path).lengthSync();

    test('runtime visual assets stay compact', () {
      expect(assetSize('assets/images/solatify_logo.svg'), lessThan(4 * 1024));
      // Replaced by the Solatify logo everywhere in the app.
      expect(File('assets/images/masjid_nabawi.svg').existsSync(), isFalse);
      expect(assetSize('assets/icon.jpg'), lessThan(64 * 1024));
    });

    test('launcher icon sources stay compact and are wired up', () {
      const masters = [
        'solatify_icon',
        'android_foreground',
        'android_background',
        'android_monochrome',
      ];
      for (final name in masters) {
        expect(assetSize('assets/brand/$name.svg'), lessThan(4 * 1024));
        expect(assetSize('assets/brand/$name.png'), lessThan(128 * 1024));
      }

      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('image_path: "assets/brand/solatify_icon.png"'));
      expect(
        pubspec,
        contains(
          'adaptive_icon_monochrome: "assets/brand/android_monochrome.png"',
        ),
      );
      expect(File('assets/best_logo.png').existsSync(), isFalse);
    });

    test('large unused asset remains under temporary review cap', () {
      expect(File('assets/icon_white.png').existsSync(), isTrue);
      expect(assetSize('assets/icon_white.png'), lessThan(192 * 1024));
    });
  });
}
