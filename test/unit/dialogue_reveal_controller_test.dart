import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/features/reader/dialogue_reveal_controller.dart';

Dialogue _line(String id) => Dialogue(
  dialogueId: id,
  speaker: Speaker.narrator,
  type: DialogueType.narration,
  text: LocalizedText(en: id),
  revealOrder: 1,
  textStatus: TextStatus.draft,
);

void main() {
  test('reveals lines in order, then completes', () {
    final c = DialogueRevealController([_line('a'), _line('b'), _line('c')]);
    var notified = 0;
    c.addListener(() => notified++);

    expect(c.current?.dialogueId, 'a');
    expect(c.revealedCount, 1);
    expect(c.isComplete, isFalse);

    expect(c.next(), isTrue);
    expect(c.next(), isTrue);
    expect(c.current?.dialogueId, 'c');
    expect(c.isComplete, isTrue);
    expect(c.next(), isFalse);
    expect(notified, 2);

    c.reset();
    expect(c.current?.dialogueId, 'a');
    expect(notified, 3);
  });

  test('empty dialogue is complete with no current line', () {
    final c = DialogueRevealController(const []);
    expect(c.current, isNull);
    expect(c.revealedCount, 0);
    expect(c.isComplete, isTrue);
    expect(c.next(), isFalse);
  });
}
