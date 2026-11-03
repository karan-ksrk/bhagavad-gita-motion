/// Content enums. Wire values match the JSON schema
/// (docs/CONTENT_SCHEMA.md). Pure Dart: no Flutter imports, so the
/// validator tool can use these.
library;

/// Review state of text content, per language (roadmap 5.4).
enum TextStatus {
  draft('draft'),
  sourceVerified('source_verified'),
  translationReviewed('translation_reviewed'),
  linguisticallyReviewed('linguistically_reviewed'),
  scriptureApproved('scripture_approved'),
  published('published');

  new(this.wire);
  final String wire;

  /// True from `scripture_approved` onward.
  bool get isApproved => index >= TextStatus.scriptureApproved.index;
}

/// Review state of a media asset (roadmap 5.4).
enum AssetStatus {
  draft('draft'),
  continuityApproved('continuity_approved'),
  processed('processed'),
  approved('approved');

  new(this.wire);
  final String wire;
}

enum RightsStatus {
  pending('pending'),
  cleared('cleared');

  new(this.wire);
  final String wire;
}

enum RendererType {
  cinematic('cinematic'),
  layeredMotion('layered_motion'),
  mangaPanel('manga_panel');

  new(this.wire);
  final String wire;
}

/// Distinguishes scripture from creative writing (roadmap 5.3).
enum DialogueType {
  creative('creative'),
  narration('narration'),
  verseParaphrase('verse_paraphrase'),
  verseTranslation('verse_translation');

  new(this.wire);
  final String wire;

  /// Verse-derived lines must cite a `source_ref`.
  bool get requiresSourceRef =>
      this == DialogueType.verseParaphrase ||
      this == DialogueType.verseTranslation;
}

enum Speaker {
  krishna('krishna'),
  arjuna('arjuna'),
  sanjaya('sanjaya'),
  dhritarashtra('dhritarashtra'),
  narrator('narrator');

  new(this.wire);
  final String wire;
}

enum EffectType {
  goldenAura('golden_aura'),
  floatingParticles('floating_particles'),
  peacockFeather('peacock_feather'),
  backgroundDrift('background_drift');

  new(this.wire);
  final String wire;
}

/// What an effect does when motion is reduced.
enum ReducedMotionBehavior {
  /// Render a still frame of the effect.
  static_('static'),

  /// Hide the effect entirely.
  hide('hide');

  new(this.wire);
  final String wire;
}

enum PanelTransition {
  none('none'),
  fade('fade'),
  slide('slide');

  new(this.wire);
  final String wire;
}

enum MediaType {
  image('image'),
  video('video'),
  audio('audio');

  new(this.wire);
  final String wire;
}

enum SourceKind {
  sanskritEdition('sanskrit_edition'),
  translation('translation'),
  original('original');

  new(this.wire);
  final String wire;
}

/// Content languages. `sa` is Sanskrit; UI languages are `hi` and `en`.
enum ContentLanguage {
  sanskrit('sa'),
  hindi('hi'),
  english('en');

  new(this.wire);
  final String wire;
}
