import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/domain/gita_structure.dart';

/// Temporary sample chapter list for the UI foundation.
///
/// SAMPLE ONLY. Titles and summaries are deliberately not included: they
/// come from the verified content repository in prompt 12c / Milestone 3.
/// Replace this provider with the content repository then.
final sampleChapterNumbersProvider = Provider<List<int>>(
  (ref) => List<int>.generate(GitaStructure.chapterCount, (i) => i + 1),
);
