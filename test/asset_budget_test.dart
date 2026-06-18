import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Asset budgets', () {
    int assetSize(String path) => File(path).lengthSync();

    test('runtime visual assets stay compact', () {
      expect(assetSize('assets/images/masjid_nabawi.svg'), lessThan(8 * 1024));
      expect(assetSize('assets/icon.jpg'), lessThan(64 * 1024));
    });

    test('launcher icon source stays compact', () {
      expect(assetSize('assets/best_logo.png'), lessThan(32 * 1024));
    });

    test('large unused asset remains under temporary review cap', () {
      expect(File('assets/icon_white.png').existsSync(), isTrue);
      expect(assetSize('assets/icon_white.png'), lessThan(192 * 1024));
    });
  });
}
