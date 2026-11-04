import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/domain/entities/content.dart';

/// Display helpers shared by the dialogue card and manga speech bubbles.
abstract final class DialogueLabels {
  static String speaker(Speaker s) => switch (s) {
    Speaker.krishna => 'Krishna',
    Speaker.arjuna => 'Arjuna',
    Speaker.sanjaya => 'Sanjaya',
    Speaker.dhritarashtra => 'Dhritarashtra',
    Speaker.narrator => 'Narrator',
  };

  /// Tells the reader what kind of text a line is (D-130).
  static String kind(Dialogue d) => switch (d.type) {
    DialogueType.creative => 'Retelling',
    DialogueType.narration => 'Narration',
    DialogueType.verseParaphrase => 'Paraphrase of ${d.sourceRef ?? 'verse'}',
    DialogueType.verseTranslation => 'Translation of ${d.sourceRef ?? 'verse'}',
  };

  /// Text in the chosen language, falling back to the other one.
  static String text(Dialogue d, AppLanguage language) {
    final preferred = language == AppLanguage.hindi ? d.text.hi : d.text.en;
    return preferred ?? d.text.en ?? d.text.hi ?? '';
  }
}
