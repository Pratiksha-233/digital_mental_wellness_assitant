import 'package:flutter/material.dart';

class AppSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final double radius;

  const AppSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.gradient,
    this.radius = 20,
  });

  static LinearGradient gradientFromScheme(
    ColorScheme cs, {
    Color? a,
    Color? b,
    double aAlpha = 0.75,
    double bAlpha = 0.55,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        (a ?? cs.surfaceContainerHighest).withValues(alpha: aAlpha),
        (b ?? cs.surface).withValues(alpha: bAlpha),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: margin,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient ?? gradientFromScheme(cs)),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
