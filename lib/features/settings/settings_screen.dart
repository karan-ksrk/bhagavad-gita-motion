import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/content_width.dart';

class SettingsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final systemReducedMotion = MediaQuery.disableAnimationsOf(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        top: false,
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            children: [
              const _SectionHeader('Language'),
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sanskrit verse text is always shown. Choose the '
                      'language for the interface and translations.',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<AppLanguage>(
                        segments: [
                          for (final lang in AppLanguage.values)
                            ButtonSegment(
                              value: lang,
                              label: Text(lang.nativeName),
                            ),
                        ],
                        selected: {settings.language},
                        onSelectionChanged: (selection) =>
                            controller.setLanguage(selection.first),
                      ),
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                title: const Text('Show transliteration'),
                subtitle: const Text('Roman-script reading aid for verses'),
                value: settings.showTransliteration,
                onChanged: (value) =>
                    controller.setShowTransliteration(value: value),
              ),
              const Divider(),
              const _SectionHeader('Motion'),
              SwitchListTile(
                title: const Text('Reduce motion'),
                subtitle: Text(
                  systemReducedMotion
                      ? 'System setting is also reducing animations'
                      : 'Turns off aura, particles, and scene movement',
                ),
                value: settings.reducedMotion,
                onChanged: (value) => controller.setReducedMotion(value: value),
              ),
              const Divider(),
              const _SectionHeader('About'),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Moksharan'),
                subtitle: Text(
                  'Foundation build. Settings are not saved yet '
                  '(Milestone 10).',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const new(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.md,
        AppSpacing.gutter,
        AppSpacing.sm,
      ),
      child: Semantics(
        header: true,
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.gold),
        ),
      ),
    );
  }
}
