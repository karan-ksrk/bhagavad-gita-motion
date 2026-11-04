import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/scene_art_frame.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/features/reader/speech_bubble.dart';

/// Manga scene: panels one at a time. Each tap reveals the panel's next
/// line; after its last line, the next panel appears with the panel's
/// transition (fade, slide, none; none with reduced motion).
class MangaPanelRenderer extends ConsumerStatefulWidget {
  const new({required this.scene, required this.paths, super.key});

  final Scene scene;
  final Map<String, String> paths;

  @override
  ConsumerState<MangaPanelRenderer> createState() => _MangaPanelRendererState();
}

class _MangaPanelRendererState extends ConsumerState<MangaPanelRenderer> {
  late final List<Panel> _panels = [...widget.scene.panels]
    ..sort((a, b) => a.order.compareTo(b.order));
  int _panel = 0;
  int _line = 0;

  List<Dialogue> _lines(Panel p) =>
      [...p.dialogues]..sort((a, b) => a.revealOrder.compareTo(b.revealOrder));

  bool get _atEnd =>
      _panel == _panels.length - 1 &&
      _line >= _lines(_panels[_panel]).length - 1;

  void _advance() {
    if (_panels.isEmpty) return;
    setState(() {
      if (_line < _lines(_panels[_panel]).length - 1) {
        _line++;
      } else if (_panel < _panels.length - 1) {
        _panel++;
        _line = 0;
      } else {
        _panel = 0;
        _line = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_panels.isEmpty) {
      return const ColoredBox(color: AppColors.midnight);
    }
    final language = ref.watch(settingsProvider.select((s) => s.language));
    final reduceMotion =
        ref.watch(settingsProvider.select((s) => s.reducedMotion)) ||
        MediaQuery.disableAnimationsOf(context);
    final panel = _panels[_panel];
    final lines = _lines(panel);
    final line = lines.isEmpty ? null : lines[_line];
    final textTheme = Theme.of(context).textTheme;

    final image = _PanelImage(
      key: ValueKey(panel.panelId),
      path: widget.paths[panel.imageAssetId],
      altText: panel.altText.en ?? panel.altText.hi ?? '',
    );

    final duration = reduceMotion || panel.transition == PanelTransition.none
        ? Duration.zero
        : const Duration(milliseconds: 450);

    return Semantics(
      button: true,
      label: _atEnd ? 'Restart panels' : 'Next',
      onTap: _advance,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _advance,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SceneArtFrame(
              backdropAsset: widget.paths[panel.imageAssetId],
              child: AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, animation) =>
                    panel.transition == PanelTransition.slide
                    ? SlideTransition(
                        position: Tween(
                          begin: const Offset(0.15, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      )
                    : FadeTransition(opacity: animation, child: child),
                child: image,
              ),
            ),
            // Bottom scrim keeps captions and the panel counter readable.
            const IgnorePointer(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xB3000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.lg,
              child: ReadableWidth(
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.scene.title.en ??
                            widget.scene.title.hi ??
                            widget.scene.sceneId,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.ivoryMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (line != null)
                        AnimatedSwitcher(
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 300),
                          child: SizedBox(
                            key: ValueKey(line.dialogueId),
                            width: double.infinity,
                            child: SpeechBubble(line: line, language: language),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          for (var i = 0; i < _panels.length; i++)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == _panel
                                    ? AppColors.gold
                                    : AppColors.ivoryMuted.withValues(
                                        alpha: 0.4,
                                      ),
                              ),
                            ),
                          const Spacer(),
                          Text(
                            'Panel ${_panel + 1} / ${_panels.length}  ·  '
                            '${_atEnd ? 'Tap to restart' : 'Tap to continue'}',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.ivory,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelImage extends StatelessWidget {
  const new({required this.path, required this.altText, super.key});

  final String? path;
  final String altText;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: altText,
      child: path == null
          ? const ColoredBox(color: AppColors.midnight)
          : Image.asset(
              path!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: AppColors.midnight),
            ),
    );
  }
}
