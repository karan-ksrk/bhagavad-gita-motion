import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/app_card.dart';
import 'package:moksharan/data/asset_packs/asset_pack_providers.dart';
import 'package:moksharan/domain/entities/asset_pack.dart';
import 'package:moksharan/features/downloads/pack_status_text.dart';

/// Download status and actions for a chapter whose media is an
/// on-demand pack. Renders nothing for chapters with bundled media.
class ChapterDownloadCard extends ConsumerWidget {
  const new({required this.chapterId, required this.chapter, super.key});

  final String chapterId;
  final int chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chapterPackStateProvider(chapterId));
    if (state == null) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final controller = ref.read(assetPacksProvider.notifier);
    final size = controller.sizeOf(state.name);
    final status = packStatusText(state, size: size);
    final failed = state.status == PackStatus.failed;

    final Widget? action = switch (state) {
      _ when state.isInstalled => null,
      _ when state.isActive => OutlinedButton(
        onPressed: () => controller.cancel(state.name),
        child: const Text('Cancel'),
      ),
      PackState(status: PackStatus.unavailable) => null,
      _ => FilledButton.icon(
        onPressed: () => controller.download(state.name),
        icon: Icon(failed ? Icons.refresh : Icons.download),
        label: Text(
          failed
              ? 'Try again'
              : 'Download${size > 0 ? ' (${formatBytes(size)})' : ''}',
        ),
      ),
    };

    return AppCard(
      semanticLabel: 'Chapter $chapter media. $status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                state.isInstalled
                    ? Icons.download_done
                    : Icons.cloud_download_outlined,
                color: AppColors.gold,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Chapter $chapter media',
                  style: textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            status,
            style: textTheme.bodyMedium?.copyWith(
              color: failed ? AppColors.error : AppColors.ivoryMuted,
            ),
          ),
          if (state.status == PackStatus.unavailable) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Chapter downloads come from Google Play. Install the app '
              'from Play (or a Play internal test) to get this chapter.',
              style: textTheme.bodySmall,
            ),
          ],
          if (state.isActive) ...[
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: state.status == PackStatus.downloading
                  ? state.progress
                  : null,
              color: AppColors.gold,
              backgroundColor: AppColors.outline,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action,
          ],
        ],
      ),
    );
  }
}
