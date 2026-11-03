import 'package:flutter/material.dart';
import 'package:moksharan/core/theme/app_tokens.dart';

/// Standard bordered card. Tappable when [onTap] is set.
class AppCard extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}
