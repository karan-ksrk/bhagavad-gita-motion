import 'package:flutter/material.dart';
import 'package:moksharan/core/theme/app_tokens.dart';

/// Caps content width on large phones and tablets so lines stay readable.
class ContentWidth extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: child,
      ),
    );
  }
}
