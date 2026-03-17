import 'package:flutter/material.dart';

import '../theme/brand_theme.dart';

class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.maxWidth = 520,
    this.horizontalPaddingCompact = 20,
    this.horizontalPaddingWide = 24,
    this.verticalPadding = 24,
    this.scrollable = true,
  });

  final Widget child;
  final double maxWidth;
  final double horizontalPaddingCompact;
  final double horizontalPaddingWide;
  final double verticalPadding;
  final bool scrollable;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final gradient = theme.extension<BrandGradients>()?.background;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_bgController.value);
          final begin = Alignment.lerp(
            Alignment.topLeft,
            Alignment.topRight,
            t,
          )!;
          final end = Alignment.lerp(
            Alignment.bottomRight,
            Alignment.bottomLeft,
            t,
          )!;

          return DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface,
              gradient: gradient == null
                  ? null
                  : LinearGradient(
                      begin: begin,
                      end: end,
                      colors: gradient.colors,
                      stops: gradient.stops,
                    ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < widget.maxWidth;
                  final horizontalPadding = isCompact
                      ? widget.horizontalPaddingCompact
                      : widget.horizontalPaddingWide;

                  final viewInsets = MediaQuery.viewInsetsOf(context);
                  final basePadding = EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: widget.verticalPadding,
                  );

                  return Center(
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: basePadding.copyWith(
                        bottom: basePadding.bottom + viewInsets.bottom,
                      ),
                      child: widget.scrollable
                          ? SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: widget.maxWidth,
                                ),
                                child: widget.child,
                              ),
                            )
                          : ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: widget.maxWidth,
                                maxHeight:
                                    (constraints.maxHeight -
                                            (widget.verticalPadding * 2) -
                                            viewInsets.bottom)
                                        .clamp(0.0, double.infinity),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.topCenter,
                                child: SizedBox(
                                  width: widget.maxWidth,
                                  child: widget.child,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

enum AuthMode { signIn, register }

class AuthModeToggle extends StatelessWidget {
  const AuthModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AuthMode>(
      segments: const [
        ButtonSegment<AuthMode>(
          value: AuthMode.signIn,
          label: Text('Sign in'),
          icon: Icon(Icons.login),
        ),
        ButtonSegment<AuthMode>(
          value: AuthMode.register,
          label: Text('Register'),
          icon: Icon(Icons.person_add_alt_1),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (selection) {
        if (selection.isEmpty) return;
        onChanged(selection.first);
      },
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.child,
    this.paddingCompact = 24,
    this.paddingWide = 40,
  });

  final Widget child;
  final double paddingCompact;
  final double paddingWide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final padding = isCompact ? paddingCompact : paddingWide;

        return Card(
          child: Padding(padding: EdgeInsets.all(padding), child: child),
        );
      },
    );
  }
}
