import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/features/reader/dialogue_labels.dart';
import 'package:moksharan/features/reader/dialogue_reveal_controller.dart';

/// Bottom-of-scene dialogue card. One line at a time; tap the card or
/// "Next" to continue. Labels every line so creative retelling is never
/// mistaken for scripture.
class DialogueOverlay extends ConsumerStatefulWidget {
  const new({required this.dialogues, super.key, this.title});

  final List<Dialogue> dialogues;
  final String? title;

  @override
  ConsumerState<DialogueOverlay> createState() => _DialogueOverlayState();
}

class _DialogueOverlayState extends ConsumerState<DialogueOverlay> {
  late final DialogueRevealController _controller = DialogueRevealController(
    widget.dialogues,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _advance() {
    if (!_controller.next()) _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(settingsProvider.select((s) => s.language));
    final reduceMotion =
        ref.watch(settingsProvider.select((s) => s.reducedMotion)) ||
        MediaQuery.disableAnimationsOf(context);
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final line = _controller.current;
        return Semantics(
          container: true,
          liveRegion: true,
          child: GestureDetector(
            onTap: line == null ? null : _advance,
            behavior: HitTestBehavior.opaque,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.midnight.withValues(alpha: 0.78),
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.title != null) ...[
                      Text(
                        widget.title!,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.ivoryMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    AnimatedSwitcher(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 350),
                      child: line == null
                          ? const SizedBox.shrink()
                          : _Line(
                              key: ValueKey(line.dialogueId),
                              line: line,
                              language: language,
                            ),
                    ),
                    if (line != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Text(
                            'Line ${_controller.revealedCount} / '
                            '${_controller.lines.length}',
                            style: textTheme.bodySmall,
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _advance,
                            icon: Icon(
                              _controller.isComplete
                                  ? Icons.replay
                                  : Icons.chevron_right,
                            ),
                            label: Text(
                              _controller.isComplete ? 'Start over' : 'Next',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Line extends StatelessWidget {
  const new({required this.line, required this.language, super.key});

  final Dialogue line;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final text = DialogueLabels.text(line, language);
    final isVerse = line.type.requiresSourceRef;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              DialogueLabels.speaker(line.speaker),
              style: textTheme.titleMedium?.copyWith(color: AppColors.gold),
            ),
            const SizedBox(width: AppSpacing.sm),
            DecoratedBox(
              decoration: BoxDecoration(
                color: isVerse ? AppColors.celestialMuted : AppColors.outline,
                borderRadius: AppRadius.badge,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                child: Text(
                  DialogueLabels.kind(line),
                  style: textTheme.labelSmall?.copyWith(color: AppColors.ivory),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          text,
          style: textTheme.bodyLarge?.copyWith(
            fontStyle: isVerse ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
