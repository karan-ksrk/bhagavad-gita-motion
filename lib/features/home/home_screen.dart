import 'package:flutter/material.dart';

/// Placeholder home screen. Replaced by the real Home screen in prompt 12b.
class HomeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Moksharan', style: textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text(
                  'Foundation build. Sample content only.',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
