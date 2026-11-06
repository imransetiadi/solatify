import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';

class SolatifyScreenScaffold extends StatelessWidget {
  const SolatifyScreenScaffold({
    super.key,
    required this.title,
    required this.child,
    this.backRoute,
    this.centerTitle = true,
    this.padding,
    this.actions,
    this.bottom,
  });

  final String title;
  final Widget child;
  final String? backRoute;
  final bool centerTitle;
  final EdgeInsetsGeometry? padding;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final appBarColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        leading: backRoute == null
            ? null
            : IconButton(
                tooltip: AppLocalizations.of(context).back,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(backRoute!),
              ),
        title: Semantics(
          header: true,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: centerTitle,
        actions: actions,
        bottom: bottom,
      ),
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: Padding(
            padding: padding ?? ResponsiveLayout.pagePadding(context),
            child: child,
          ),
        ),
      ),
    );
  }
}
