import 'package:flutter/material.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/features/reader/dialogue_labels.dart';

/// Manga-style text for one dialogue line.
///
/// Spoken lines render as an ivory speech bubble with a tail; narration
/// renders as a rectangular caption box. Both carry the kind label, so
/// creative retelling is never mistaken for scripture.
class SpeechBubble extends StatelessWidget {
  const new({required this.line, required this.language, super.key});

  final Dialogue line;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return line.type == DialogueType.narration
        ? _NarrationBox(line: line, language: language)
        : _Bubble(line: line, language: language);
  }
}

class _KindTag extends StatelessWidget {
  const new({required this.line, required this.dark});

  final Dialogue line;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final isVerse = line.type.requiresSourceRef;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isVerse
            ? AppColors.celestialMuted
            : (dark ? AppColors.outline : AppColors.goldMuted),
        borderRadius: AppRadius.badge,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        child: Text(
          DialogueLabels.kind(line),
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.ivory),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const new({required this.line, required this.language});

  final Dialogue line;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CustomPaint(
      painter: const _BubblePainter(),
      child: Padding(
        // Extra top padding leaves room for the tail.
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md + _BubblePainter.tailHeight,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  DialogueLabels.speaker(line.speaker),
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.goldMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _KindTag(line: line, dark: false),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              DialogueLabels.text(line, language),
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.midnight,
                fontStyle: line.type.requiresSourceRef
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded ivory bubble with a tail at the top left pointing up toward
/// the speaker in the panel.
class _BubblePainter extends CustomPainter {
  const new();

  static const tailHeight = 14.0;
  static final Paint _fill = Paint()..color = AppColors.ivory;
  static final Paint _stroke = Paint()
    ..color = AppColors.goldMuted
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, tailHeight, size.width, size.height - tailHeight),
      const Radius.circular(18),
    );
    final path = Path()
      ..addRRect(body)
      ..moveTo(36, tailHeight + 1)
      ..lineTo(48, 0)
      ..lineTo(60, tailHeight + 1)
      ..close();
    canvas
      ..drawPath(path, _fill)
      ..drawRRect(body, _stroke);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => false;
}

class _NarrationBox extends StatelessWidget {
  const new({required this.line, required this.language});

  final Dialogue line;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.midnight.withValues(alpha: 0.88),
        border: Border.all(color: AppColors.gold),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _KindTag(line: line, dark: true),
            const SizedBox(height: AppSpacing.xs),
            Text(
              DialogueLabels.text(line, language),
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
