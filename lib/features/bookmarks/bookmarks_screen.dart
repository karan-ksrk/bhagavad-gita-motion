import 'package:flutter/material.dart';
import 'package:moksharan/core/widgets/state_views.dart';

/// Bookmarks placeholder. Storage arrives in Milestone 10.
class BookmarksScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: const SafeArea(
        top: false,
        child: EmptyView(
          icon: Icons.bookmark_border,
          title: 'No bookmarks yet',
          message: 'Bookmark a verse or scene to find it here.',
        ),
      ),
    );
  }
}
