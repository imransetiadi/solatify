import 'package:flutter/material.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';

/// Progress dots for first-run flows.
///
/// Announced to screen readers as a single "Step X of Y" label instead of
/// a set of meaningless decorative shapes.
class OnboardingStepIndicator extends StatelessWidget {
  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.stepCount,
  });

  final int currentStep;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final step = currentStep + 1;
    final label = l.isEnglish
        ? 'Step $step of $stepCount'
        : 'Langkah $step dari $stepCount';
    final accent = SolatifyColors.accent(context);
    final inactive = SolatifyColors.muted(context).withValues(alpha: 0.35);
    final duration = SolatifyMotion.of(context, SolatifyMotion.medium);

    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(stepCount, (index) {
            final isActive = index == currentStep;
            return AnimatedContainer(
              duration: duration,
              curve: SolatifyMotion.curve,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? accent : inactive,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Scrollable, vertically-centred slide body so step content never overflows
/// on short screens or with large text scale.
class OnboardingSlideFrame extends StatelessWidget {
  const OnboardingSlideFrame({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ??
        const EdgeInsets.symmetric(
          horizontal: SolatifySpacing.lg,
          vertical: SolatifySpacing.sm,
        );
    return LayoutBuilder(
      builder: (context, constraints) {
        final verticalPadding = effectivePadding
            .resolve(Directionality.of(context))
            .vertical;
        return SingleChildScrollView(
          padding: effectivePadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - verticalPadding).clamp(
                0.0,
                double.infinity,
              ),
            ),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}
