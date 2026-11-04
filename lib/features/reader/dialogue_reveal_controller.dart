import 'package:flutter/foundation.dart';
import 'package:moksharan/domain/entities/content.dart';

/// Reveals a scene's dialogue one line at a time, at the reader's pace.
class DialogueRevealController extends ChangeNotifier {
  new(Iterable<Dialogue> lines) : lines = List.unmodifiable(lines);

  final List<Dialogue> lines;
  int _revealed = 1;

  /// Number of lines shown so far (at least one when there are lines).
  int get revealedCount => lines.isEmpty ? 0 : _revealed;

  /// Line currently in focus, or null when there are no lines.
  Dialogue? get current => lines.isEmpty ? null : lines[_revealed - 1];

  bool get isComplete => _revealed >= lines.length;

  /// Shows the next line. Returns false when already complete.
  bool next() {
    if (isComplete) return false;
    _revealed++;
    notifyListeners();
    return true;
  }

  /// Goes back to the first line.
  void reset() {
    if (_revealed == 1) return;
    _revealed = 1;
    notifyListeners();
  }
}
