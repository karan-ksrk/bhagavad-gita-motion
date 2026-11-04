import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/content_width.dart';
import 'package:moksharan/data/repositories/content_providers.dart';

/// About the app and attribution for text, fonts, and media.
class AboutScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final sources = ref.watch(sourcesByIdProvider).value?.values.toList();

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
      appBar: AppBar(title: const Text('About and sources')),
      body: SafeArea(
        top: false,
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            children: [
              Text('Moksharan', style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Foundation build. Works offline. Your settings, reading '
                'progress, and bookmarks stay on this device only.',
                style: textTheme.bodyMedium,
              ),
              heading('Scripture and translations'),
              if (sources == null)
                const LinearProgressIndicator()
              else
                for (final s in sources)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      [
                        s.title,
                        if (s.author != null) s.author!,
                        if (s.year != null) '${s.year}',
                        s.license,
                      ].join(' · '),
                      style: textTheme.bodySmall,
                    ),
                  ),
              heading('Font'),
              Text(
                'Tiro Devanagari Sanskrit · Tiro Typeworks / Indigo '
                'Project · SIL Open Font License 1.1',
                style: textTheme.bodySmall,
              ),
              heading('Artwork and video'),
              Text(
                'Scene artwork generated with ChatGPT image generation; '
                'motion clips with Google Flow. Usage rights are under '
                'review before public release.',
                style: textTheme.bodySmall,
              ),
              heading('Support'),
              Text(
                'Questions or problems: karanksrk2000@outlook.com, or open '
                'an issue at github.com/karan-ksrk/bhagavad-gita-motion.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: 'Moksharan',
                  ),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Open-source licenses'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
