import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/content_width.dart';
import 'package:moksharan/data/asset_packs/asset_pack_providers.dart';
import 'package:moksharan/domain/entities/asset_pack.dart';
import 'package:moksharan/features/downloads/pack_status_text.dart';

/// Storage used by chapter media; remove or download chapter packs.
class StorageScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final packs = ref.watch(chapterPacksProvider).value ?? const [];
    final states = ref.watch(assetPacksProvider);
    final bundled = ref.watch(bundledMediaBytesProvider).value;
    final free = ref.watch(availableBytesProvider).value;

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(color: AppColors.gold),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Storage')),
      body: SafeArea(
        top: false,
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            children: [
              if (free != null)
                Text(
                  'Free space on this device: ${formatBytes(free)}',
                  style: textTheme.bodyMedium,
                ),
              heading('Included with the app'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Built-in sample media'),
                subtitle: Text(
                  [
                    if (bundled != null) formatBytes(bundled),
                    'Always available, cannot be removed',
                  ].join(' · '),
                ),
              ),
              heading('Chapter downloads'),
              if (packs.isEmpty)
                Text('No chapter downloads yet.', style: textTheme.bodySmall)
              else
                for (final p in packs)
                  _PackTile(
                    chapter: p.chapter.number,
                    state: states[p.pack] ?? PackState(name: p.pack),
                  ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Removing a chapter deletes only its pictures and video. '
                'Your bookmarks and reading progress are kept.',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackTile extends ConsumerWidget {
  const new({required this.chapter, required this.state});

  final int chapter;
  final PackState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(assetPacksProvider.notifier);
    final status = packStatusText(state, size: controller.sizeOf(state.name));

    final Widget? trailing;
    if (state.isInstalled) {
      trailing = IconButton(
        tooltip: 'Remove chapter $chapter media',
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmRemove(context, ref),
      );
    } else if (state.isActive) {
      trailing = const SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (state.status == PackStatus.unavailable) {
      trailing = null;
    } else {
      trailing = IconButton(
        tooltip: 'Download chapter $chapter media',
        icon: const Icon(Icons.download),
        onPressed: () => controller.download(state.name),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        state.isInstalled ? Icons.download_done : Icons.cloud_outlined,
      ),
      title: Text('Chapter $chapter'),
      subtitle: Text(status),
      trailing: trailing,
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove chapter $chapter media?'),
        content: const Text(
          'Bookmarks and reading progress are kept. You can download the '
          'chapter again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (remove != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(assetPacksProvider.notifier).remove(state.name);
      messenger.showSnackBar(
        SnackBar(content: Text('Chapter $chapter media removed')),
      );
    } on AssetPackException {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not remove. Try again.')),
      );
    }
  }
}
