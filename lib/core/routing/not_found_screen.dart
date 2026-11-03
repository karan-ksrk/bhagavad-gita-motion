import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/widgets/state_views.dart';

class NotFoundScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ErrorView(
          title: 'Page not found',
          message: 'This page does not exist.',
          action: FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('Go to Home'),
          ),
        ),
      ),
    );
  }
}
