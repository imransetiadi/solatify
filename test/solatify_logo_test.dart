import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/core/widgets/solatify_logo.dart';

void main() {
  testWidgets('SolatifyLogo renders the brand SVG at the requested size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: SolatifyLogo(size: 64, semanticLabel: 'Solatify')),
      ),
    );

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.width, 64);
    expect(svg.height, 64);
    expect(tester.getSize(find.byType(SolatifyLogo)), const Size(64, 64));
    expect(find.bySemanticsLabel('Solatify'), findsOneWidget);
  });

  test('brand surfaces use the new Solatify logo', () {
    const screens = [
      'lib/features/onboarding/presentation/screens/splash_screen.dart',
      'lib/features/onboarding/presentation/screens/onboarding_screen.dart',
      'lib/features/onboarding/presentation/screens/get_started_screen.dart',
      'lib/features/home/presentation/screens/home_screen.dart',
    ];
    for (final path in screens) {
      final source = File(path).readAsStringSync();
      expect(source, contains('SolatifyLogo('), reason: path);
      expect(source, isNot(contains('masjid_nabawi')), reason: path);
    }

    final logo = File(SolatifyLogo.assetPath).readAsStringSync();
    // flutter_svg does not support <mask>; the crescent is a plain path.
    expect(logo, isNot(contains('<mask')));
  });

  test('Android notifications use the monochrome status-bar icon', () {
    final sources = [
      'lib/features/notifications/data/services/notification_service.dart',
      'lib/main.dart',
      'android/app/src/main/kotlin/com/solatify/app/solatify/notifications/PrayerAlarmReceiver.kt',
      'android/app/src/main/kotlin/com/solatify/app/solatify/service/AdhanPlaybackService.kt',
    ].map((path) => File(path).readAsStringSync());

    for (final source in sources) {
      expect(source, contains('ic_stat_solatify'));
      expect(source, isNot(contains('mipmap/ic_launcher')));
      expect(source, isNot(contains('R.mipmap.ic_launcher')));
    }
    expect(
      File(
        'android/app/src/main/res/drawable/ic_stat_solatify.xml',
      ).existsSync(),
      isTrue,
    );
    expect(
      File('android/app/src/main/res/raw/keep.xml').readAsStringSync(),
      contains('@drawable/ic_stat_solatify'),
    );
  });

  test('launch screens show the logo', () {
    expect(
      File(
        'android/app/src/main/res/drawable/launch_background.xml',
      ).readAsStringSync(),
      contains('@drawable/launch_logo'),
    );
    expect(
      File(
        'android/app/src/main/res/drawable-v21/launch_background.xml',
      ).readAsStringSync(),
      contains('@drawable/launch_logo'),
    );
    expect(
      File('ios/Runner/Base.lproj/LaunchScreen.storyboard').readAsStringSync(),
      contains('<image name="LaunchImage" width="112" height="112"/>'),
    );
  });
}
