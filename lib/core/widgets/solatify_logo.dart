import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Solatify brand mark: a mihrab arch with a crescent under the five
/// daily prayers on the sun's path, on the green app-icon tile.
///
/// Same artwork as the launcher icon (`assets/brand/solatify_icon.svg`), so
/// the app and the home screen show one logo.
class SolatifyLogo extends StatelessWidget {
  const SolatifyLogo({this.size = 48, this.semanticLabel, super.key});

  static const String assetPath = 'assets/images/solatify_logo.svg';

  final double size;

  /// Announced by screen readers; the logo is decorative when null.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final logo = SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
    return SizedBox.square(dimension: size, child: logo);
  }
}
