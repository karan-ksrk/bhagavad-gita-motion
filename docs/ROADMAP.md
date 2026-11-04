# Bhagavad Gita --- Motion Manga App

## Complete Product, Technical, Creative, and Delivery Roadmap

**Working title:** Bhagavad Gita\
**Platform:** Android first\
**Framework:** Flutter / Dart\
**Experience:** Hybrid cinematic scenes + manga panels\
**Languages:** Sanskrit, Hindi, English\
**Primary creative tools:** ChatGPT image generation and Google Flow\
**Engineering tool:** Claude Code\
**Media processing:** FFmpeg\
**Version control:** GitHub

**Document purpose:** This is the master implementation plan. It defines
the product scope, architecture, creative pipeline, milestones, backlog,
acceptance criteria, testing, release process, and operational
safeguards. Treat it as the project source of truth and update it as
decisions change.

------------------------------------------------------------------------

# 1. Product vision

Build an immersive, offline-first mobile storytelling application that
presents the Bhagavad Gita as a living visual experience rather than a
conventional ebook or static comic.

Readers should be able to: - Explore the Bhagavad Gita chapter by
chapter. - Experience selected moments as full-screen cinematic
scenes. - Read conversations as illustrated manga panels. - See the
original Sanskrit shloka with Hindi and English translations or
explanations. - Reveal dialogue progressively at a comfortable reading
pace. - Pause, replay, mute, or reduce animation. - Bookmark verses and
resume where they left off. - Read downloaded content without an
internet connection.

The visual identity is cinematic Indian mythology: dignified character
portrayals, rich environments, warm gold and celestial blue lighting,
detailed ornaments, and a calm, reverent atmosphere.

## 1.1 Product principles

1.  **Scripture first:** Visual storytelling must not distort the
    meaning, sequence, or context of the text.
2.  **Clarity over spectacle:** Animation should support reading, not
    compete with it.
3.  **Consistent characters:** Krishna, Arjuna, and recurring characters
    must remain visually recognizable.
4.  **Offline-first:** Core reading must work without an account or
    network connection.
5.  **Content-driven:** Chapters and scenes are data, not hardcoded UI.
6.  **Accessible:** Support adjustable text, contrast, reduced motion,
    captions/transcripts, and sensible touch targets.
7.  **Media-efficient:** Download only what is needed; avoid
    unnecessarily large application packages.
8.  **Review before release:** AI-generated artwork, translations,
    dialogue, and scripture references require human review.

## 1.2 MVP scope

The first public-quality beta should prove the complete reading
experience with a small, polished content sample.

MVP includes: - Android application built with Flutter. - Home and
chapter-selection screens. - All 18 chapter entries with reviewed titles
and short summaries, where available. - One sample range only: Chapter 1
plus the opening of Chapter 2 (2.1--2.11), unless a different single
range is approved in Milestone 0. - At least five approved scenes inside
that sample range. - At least one cinematic scene. - At least one
manga-panel scene. - At least one layered-motion scene. - Sanskrit verse
text always shown; UI and translation language selectable between Hindi
and English; transliteration toggle. - Progressive dialogue reveal. -
Shloka detail view. - Previous/next scene navigation. - Local bookmarks
and reading progress. - Offline reading of bundled sample content. -
Settings for language, sound, and reduced motion. - Error and loading
states for missing or unavailable media.

The MVP does **not** require user accounts, subscriptions, social
features, cloud sync, an AI chatbot, a content-management web portal, or
all 700 illustrated verses.

------------------------------------------------------------------------

# 2. Product decisions and open decisions

## 2.1 Confirmed decisions

  -----------------------------------------------------------------------
  Area                                Decision
  ----------------------------------- -----------------------------------
  Working name                        Bhagavad Gita

  Initial platform                    Android only

  Framework                           Flutter

  Language                            Dart

  Reading experience                  Hybrid: full-screen cinematic
                                      scenes + manga panels

  Languages                           Sanskrit verse text always shown;
                                      UI/translation language: Hindi or
                                      English; transliteration toggle

  Media delivery                      Bundled sample media; later
                                      chapters via Play Asset Delivery
                                      (no custom download server)

  Character/artwork generation        ChatGPT image generation

  Video/animation generation          Google Flow Pro

  Coding                              Claude Code

  Video processing                    FFmpeg

  Version control                     GitHub

  Local-first MVP                     Yes

  Local image generation              Not required

  Krita                               Optional only; not a required
                                      dependency
  -----------------------------------------------------------------------

## 2.2 Decisions to make in Milestone 0

These block content, scene briefs, and the first Play upload. Do not
defer them to release.

-   Final app name and Android package ID. Both are permanent once
    uploaded to Play. Use a package ID under a domain you control.
-   Exact Sanskrit source edition.
-   Hindi and English translation sources, and their license status.
    The Sanskrit text is public domain; most modern translations are
    not. Either obtain permission or use public-domain translations.
-   Named scripture reviewer (Sanskrit/Gita expertise).
-   Named cultural/devotional reviewer for Krishna and Arjuna
    depictions.
-   Sample chapter range for the MVP (default: Chapter 1 + 2.1--2.11).

## 2.3 Decisions to make before public release

-   Logo and visual identity.
-   Minimum supported Android version and device-performance target.
-   Commentary, font, music, and artwork licensing.
-   Whether narration/audio is included in the first public release.
-   Whether cloud backup or cross-device sync is needed later.
-   Privacy policy, analytics, and crash-reporting choices.
-   Play Store country availability and release strategy.

Do not silently make these decisions in code. Record approvals in
`docs/DECISIONS.md`.

------------------------------------------------------------------------

# 3. Recommended technology stack

Use stable, mutually compatible versions at project initialization.
Record exact versions in the repository; do not blindly copy old version
numbers from this document.

  ------------------------------------------------------------------------
  Concern                 Recommended technology   Notes
  ----------------------- ------------------------ -----------------------
  Mobile framework        Flutter stable           Android first; iOS may
                                                   be considered later

  Language                Dart                     Null safety

  UI                      Flutter Widgets /        Custom cinematic design
                          Material 3 foundations   system

  State management        Riverpod                 Keep state and side
                                                   effects testable

  Navigation              GoRouter                 Typed/structured route
                                                   arguments where
                                                   practical

  Local database          Drift + SQLite           Progress, bookmarks,
                                                   downloaded content
                                                   metadata. Adds
                                                   build_runner codegen;
                                                   MVP may start with
                                                   SharedPreferences and
                                                   adopt Drift when
                                                   download metadata
                                                   needs it

  Preferences             SharedPreferences or a   Language, motion,
                          small                    audio, reader
                          DataStore-equivalent     preferences
                          Flutter package          

  Video playback          `video_player` initially Use platform-native
                                                   playback; evaluate
                                                   alternatives only if a
                                                   proven requirement
                                                   exists

  Fonts                   Noto Serif Devanagari /  OFL-licensed; support
                          Tiro Devanagari Sanskrit Sanskrit conjuncts.
                                                   Final choice in M2

  Media delivery          Play Asset Delivery      On-demand asset packs
                                                   for chapters beyond
                                                   the bundled sample;
                                                   Google hosts and
                                                   verifies packs

  Animation               Flutter animation        Aura, particles,
                          framework +              feather movement,
                          CustomPainter            transitions

  Optional vector         Rive or Lottie           Use selectively, not
  animation                                        for every effect

  Images                  Flutter asset loading;   MVP should primarily
                          `cached_network_image`   use local media
                          only if remote images    
                          are introduced           

  Serialization           `json_serializable` /    Versioned content
                          `freezed` if useful      schema

  Background tasks        A suitable Flutter       Avoid early complexity
                          background-work package  
                          only when downloads      
                          require it               

  Tests                   `flutter_test`, `test`,  Unit, widget,
                          integration tests        integration,
                                                   performance

  Static analysis         `flutter analyze`        Required in CI

  Version control         Git + GitHub             Branches, pull
                                                   requests, tags

  Media processing        FFmpeg                   Normalize, trim,
                                                   compress, inspect, and
                                                   package video/audio

  Creative artwork        ChatGPT image generation Character references,
                                                   scene art, panels

  Video generation        Google Flow              Image-to-video and
                                                   cinematic clips

  Engineering agent       Claude Code              Implementation, tests,
                                                   refactoring,
                                                   documentation
  ------------------------------------------------------------------------

### 3.1 Architecture style

Use one layering scheme: shared `lib/data/` and `lib/domain/`, with
each feature folder holding presentation code only. - Presentation
(`lib/features/<feature>/`): screens, widgets, controllers/notifiers, UI
state. - Domain (`lib/domain/`): entities, repository contracts, use
cases where they add value. - Data (`lib/data/`): JSON assets, database,
repository implementations, media manifests. - Core (`lib/core/`):
routing, theme, localization, media, animation, error handling.

Avoid excessive abstraction and dozens of packages in the first version.
Start with a single Flutter application package and a disciplined folder
structure. Split into Dart packages only when there is a real reuse or
ownership benefit.

### 3.2 Core engineering rules

-   Widgets must not query the database directly.
-   UI must not parse raw JSON.
-   Repositories abstract data sources.
-   Use immutable models where practical.
-   Keep content independent of UI.
-   Keep media playback lifecycle separate from content parsing.
-   Do not keep video controllers alive after leaving a scene.
-   Do not preload every chapter's video.
-   Provide poster/fallback artwork while media loads or fails.
-   Avoid storing secrets in the application.
-   No backend is required for the MVP.
-   Make the app functional without sign-in.
-   Every new dependency must have a documented reason.

------------------------------------------------------------------------

# 4. Application architecture

## 4.1 High-level flow

``` text
Flutter UI
  |
  +-- Home / Chapters / Reader / Shloka / Bookmarks / Settings
  |
  +-- Riverpod state and controllers
  |
  +-- Domain models and repository contracts
  |
  +-- Repository implementations
       |
       +-- Bundled JSON content
       +-- Local persistence (SharedPreferences, then Drift / SQLite)
       +-- Local media files and asset manifest
       +-- Optional Play Asset Delivery chapter packs
```

The MVP has no mandatory remote backend. Future cloud services must be
optional adapters rather than assumptions embedded in the reader.

## 4.2 Proposed folder structure

``` text
bhagavad-gita/
├── CLAUDE.md
├── README.md
├── CONTRIBUTING.md
├── CHANGELOG.md
├── LICENSES.md
├── .gitignore
├── .github/
│   └── workflows/
│       └── flutter-ci.yml
│
├── docs/                      # create each doc when its milestone needs it
│   ├── PRODUCT_SPEC.md
│   ├── ARCHITECTURE.md
│   ├── DECISIONS.md
│   ├── ROADMAP.md
│   ├── BACKLOG.md
│   ├── UI_DESIGN_SYSTEM.md
│   ├── VISUAL_STYLE_GUIDE.md
│   ├── CHARACTER_BIBLE.md
│   ├── ANIMATION_GUIDE.md
│   ├── CONTENT_GUIDELINES.md
│   ├── SCRIPTURE_SOURCES.md
│   ├── LICENSING_REGISTER.md
│   ├── ASSET_PIPELINE.md
│   ├── MEDIA_BUDGET.md
│   ├── TESTING_STRATEGY.md
│   ├── RELEASE_CHECKLIST.md
│   └── PRIVACY_AND_SECURITY.md
│
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── animation/
│   │   ├── database/
│   │   ├── errors/
│   │   ├── localization/
│   │   ├── media/
│   │   ├── routing/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local_content/
│   │   │   ├── local_database/
│   │   │   └── local_media/
│   │   ├── models/
│   │   └── repositories/
│   │
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   │
│   └── features/              # presentation only; no per-feature data/domain
│       ├── home/
│       ├── chapters/
│       ├── reader/
│       ├── manga/
│       ├── shloka/
│       ├── bookmarks/
│       └── settings/
│
├── assets/
│   ├── content/
│   │   ├── manifest.json
│   │   ├── chapters/
│   │   └── shlokas/
│   ├── characters/
│   ├── environments/
│   ├── posters/
│   ├── images/
│   ├── videos/
│   ├── animations/
│   ├── audio/
│   └── fonts/
│
├── media-production/
│   ├── briefs/
│   ├── character-references/
│   ├── environment-references/
│   ├── chatgpt-prompts/
│   ├── flow-prompts/
│   ├── generated-artwork/
│   ├── generated-video/
│   ├── review/
│   ├── approved-assets/
│   └── manifests/
│
├── tool/                      # Dart CLI tools; reuse app models
│   ├── validate_content.dart
│   ├── validate_assets.dart
│   ├── inspect_media.dart     # wraps ffprobe
│   └── build_media_manifest.dart
│
├── test/
│   ├── unit/
│   ├── widget/
│   ├── fixtures/
│   └── integration/
│
└── pubspec.yaml
```

Generated source material and rejected variants should not be mixed with
production assets. Large source files may be stored outside Git or in
Git LFS if appropriate. Keep approved, optimized assets and manifests
reproducible.

------------------------------------------------------------------------

# 5. Content model and scripture integrity

## 5.1 Content hierarchy

``` text
Bhagavad Gita
  └── Chapter
       ├── Chapter metadata
       ├── Scene
       │    ├── Scene metadata
       │    ├── Renderer type
       │    ├── Media references
       │    ├── Visual effects
       │    ├── Dialogue
       │    ├── Manga panels
       │    └── Shloka references
       └── Shlokas
            ├── Sanskrit original
            ├── Transliteration
            ├── Hindi translation / explanation
            ├── English translation / explanation
            ├── Word meanings
            └── Source and review metadata
```

A scene may reference one or more shlokas. Shloka records must be stored
separately so the same verse is not duplicated in different scenes.

## 5.2 Core entities

-   `Chapter`: number, stable ID, titles, summary, ordering, content
    status.
-   `Scene`: stable ID, chapter ID, title, ordering, renderer type,
    duration/read-time metadata.
-   `Dialogue`: speaker ID, dialogue type (`creative`, `narration`,
    `verse_paraphrase`, `verse_translation`), source reference,
    localized text, reveal order, optional narration metadata.
-   `Panel`: panel ID, image asset ID, order, optional dialogue and
    transition.
-   `Shloka`: stable verse ID, chapter number, verse number, Sanskrit,
    transliteration, source.
-   `Translation`: language, text, translator/source ID, license
    metadata.
-   `WordMeaning`: Sanskrit term, transliteration, meaning, source.
-   `MediaAsset`: asset ID, path, media type, dimensions, duration,
    size, checksum.
-   `Effect`: effect ID, type, anchor point (normalized 0--1 of the
    artwork frame), scale, intensity, parameters, reduced-motion
    behavior.
-   `ReadingProgress`: chapter, scene, panel/verse position, updated
    timestamp.
-   `Bookmark`: stable bookmark ID, verse or scene reference, created
    timestamp.
-   `ContentSource`: edition, publisher, translator, URL/reference,
    rights and review notes.

## 5.3 Example scene JSON

``` json
{
  "schema_version": 1,
  "chapter_id": "chapter_02",
  "scenes": [
    {
      "scene_id": "ch02_scene_001",
      "title": {
        "hi": "कृष्ण का ज्ञान",
        "en": "Krishna's Wisdom"
      },
      "renderer": "cinematic",
      "media": {
        "poster": "posters/ch02_scene_001.webp",
        "video": "videos/ch02_scene_001.mp4"
      },
      "effects": [
        {
          "effect_id": "golden_aura",
          "enabled": true,
          "anchor": { "x": 0.52, "y": 0.34 },
          "scale": 0.4,
          "intensity": 0.6
        },
        {
          "effect_id": "floating_particles",
          "enabled": true,
          "anchor": { "x": 0.5, "y": 0.4 },
          "scale": 0.8,
          "intensity": 0.4
        },
        {
          "effect_id": "peacock_feather",
          "enabled": true,
          "anchor": { "x": 0.55, "y": 0.18 },
          "scale": 0.1,
          "intensity": 0.5
        }
      ],
      "dialogues": [
        {
          "speaker_id": "krishna",
          "dialogue_type": "creative",
          "source_ref": "BG.2.47",
          "text": {
            "hi": "Reviewed Hindi dialogue",
            "en": "Reviewed English dialogue"
          },
          "reveal_order": 1
        }
      ],
      "shloka_refs": ["BG.2.47"]
    }
  ]
}
```

This is a structural example only. Placeholder dialogue must not be
presented as a canonical quotation.

Field rules: - `anchor` uses normalized coordinates (0--1) relative to
the artwork frame, so effects line up with Krishna's position in each
image. - `dialogue_type` is required. Allowed values: `creative`,
`narration`, `verse_paraphrase`, `verse_translation`. The reader must
visually distinguish creative dialogue from scripture. - `source_ref`
is required for `verse_paraphrase` and `verse_translation`.

## 5.4 Content status workflow

Track text and assets with separate status fields.

`text_status` (per language): - `draft` - `source_verified` -
`translation_reviewed` - `linguistically_reviewed` -
`scripture_approved` - `published`

`asset_status` (per media asset): - `draft` - `continuity_approved` -
`processed` - `approved`

A verse can have different review states for different language
versions. Record the reviewer and review date where practical.

## 5.5 Scripture and copyright rules

-   Choose and document a reliable Sanskrit source edition.
-   Verify chapter and verse numbering against the selected edition.
-   Do not treat AI output as an authoritative Sanskrit source.
-   Distinguish literal translation, paraphrase, commentary, and
    creative dialogue.
-   Attribute translators and commentators.
-   Verify the license or permission for each modern translation and
    commentary.
-   Check font licenses and music/sound-effect licenses.
-   Maintain `SCRIPTURE_SOURCES.md` and `LICENSING_REGISTER.md`.
-   Do not publish unreviewed verse text.
-   Do not place generated text inside artwork or video; render all
    scripture text in the app.

------------------------------------------------------------------------

# 6. Visual identity and character bible

## 6.1 Visual direction

-   Cinematic Indian mythological artwork.
-   Deep midnight blue and charcoal surfaces.
-   Antique gold accents.
-   Celestial blue lighting.
-   Warm ivory text.
-   Rich but restrained environmental colour.
-   Dignified, peaceful, compassionate portrayal of Krishna.
-   Dramatic but readable compositions.
-   Vertical mobile-first artwork, with safe areas for overlays.
-   Overlay safe zone: keep the bottom 35% of every vertical frame free
    of faces and key detail. Include this rule in every ChatGPT and
    Flow prompt.

## 6.2 Character consistency

Create approved master references before producing chapter scenes.

### Krishna reference pack

-   Front portrait.
-   Three-quarter portrait.
-   Side profile.
-   Full-body standing pose.
-   Seated/chariot pose.
-   Calm expression.
-   Speaking expression.
-   Compassionate expression.
-   Crown and peacock-feather detail.
-   Clothing, jewellery, complexion, and body-proportion reference.

### Arjuna reference pack

-   Front portrait.
-   Three-quarter portrait.
-   Side profile.
-   Full-body warrior pose.
-   Seated/chariot pose.
-   Distressed expression.
-   Listening expression.
-   Focused expression.
-   Armour, bow, clothing, and body-proportion reference.

### Environment reference pack

-   Kurukshetra wide battlefield.
-   Krishna and Arjuna's chariot.
-   Chariot interior/seat positions.
-   Distant army and flags.
-   Sunrise/sunset lighting.
-   Sky and cloud variations.
-   Celestial/divine environments where required.

Use approved reference images as inputs when generating later scenes.
Reference images improve consistency but do not guarantee identical
output. Review every generated asset for face, costume, proportions,
hands, jewellery, feather placement, and continuity.

## 6.3 Character approval checklist

-   [ ] Face and facial proportions approved.
-   [ ] Complexion and skin rendering approved.
-   [ ] Crown and feather approved.
-   [ ] Clothing and jewellery approved.
-   [ ] Full-body proportions approved.
-   [ ] Expression range approved.
-   [ ] Character looks consistent across views.
-   [ ] Reference image rights and source recorded.

------------------------------------------------------------------------

# 7. Motion and reader system

## 7.1 Three renderer types

### A. Cinematic renderer

-   Full-screen MP4 scene.
-   Poster shown while loading.
-   Native dialogue and shloka overlays.
-   Progressive dialogue reveal.
-   Pause, resume, replay, and mute.
-   Previous/next scene controls.
-   Video loop only when the asset is authored for looping.
-   Correct lifecycle handling and player disposal.

### B. Layered-motion renderer

-   Background image.
-   Character/foreground layers where available.
-   Golden aura pulse.
-   Floating particles.
-   Peacock-feather movement.
-   Clothing/environment movement where supplied.
-   Native dialogue and scripture overlays.
-   Effects disabled or reduced in reduced-motion mode.

### C. Manga-panel renderer

-   Ordered panels.
-   Panel-by-panel or vertical reading mode.
-   Speech bubbles.
-   Progressive dialogue.
-   Shloka cards.
-   Panel transitions.
-   Accessible reading order and text alternatives.

## 7.2 Signature Krishna scene

The signature scene is Krishna speaking to Arjuna.

Required visual elements: - Krishna's divine aura gently pulses. -
Peacock feather moves subtly. - Golden light particles float around
Krishna. - Krishna maintains a peaceful, compassionate expression. -
Background clouds, flags, or dust move subtly. - Camera motion is slow
and restrained. - Dialogue appears progressively. - Sanskrit shloka is
revealed separately from the dialogue. - Hindi and English meaning can
be opened without interrupting the scene.

Avoid rapid flashes, excessive glow, distracting movement, or
action-game styling.

## 7.3 Animation architecture

Create a shared scene contract and renderer implementations: -
`CinematicSceneRenderer` - `LayeredMotionRenderer` -
`MangaPanelRenderer`

Shared services: - `ScenePlaybackController` - `MediaLifecycleManager` -
`AnimationPreferences` - `DialogueRevealController` -
`SceneNavigationController`

The renderer should consume a scene model and not parse source JSON
itself.

## 7.4 Performance and lifecycle requirements

-   Only one active cinematic player per reader route.
-   Pause playback when app is backgrounded or reader is not visible.
-   Dispose player/controllers when the scene/route is disposed.
-   Display poster fallback on load error.
-   Avoid preloading every chapter's video.
-   Preload only the next scene's poster or lightweight metadata.
-   Use appropriately encoded, device-compatible video.
-   Test on low-, mid-, and high-tier Android devices.
-   Offer a static-art fallback if video decoding fails.
-   Respect system reduced-motion settings where possible.
-   Do not animate off-screen content.
-   Avoid unbounded particle lists and per-frame object allocation.
-   Measure memory, frame pacing, battery, and startup performance.

------------------------------------------------------------------------

# 8. Media and asset production pipeline

## 8.1 Tool responsibilities

  -----------------------------------------------------------------------
  Tool                                Responsibility
  ----------------------------------- -----------------------------------
  ChatGPT                             Character reference sheets, scene
                                      artwork, manga panels, visual
                                      prompts, scripts and review

  Google Flow                         Image-to-video,
                                      character/environment motion,
                                      cinematic scene generation

  FFmpeg                              Video inspection, trimming,
                                      encoding, resizing, audio
                                      processing, loop preparation

  Claude Code                         Flutter implementation, scripts,
                                      tests, architecture and
                                      documentation

  GitHub                              Source control, issues, pull
                                      requests, approved manifests and
                                      release tags

  Android Studio                      Android SDK, emulator, device
                                      debugging, build and profiling
  -----------------------------------------------------------------------

Krita is optional and is not required. Local image generation is not
part of the selected workflow.

## 8.2 Asset lifecycle

``` text
Creative brief
  -> ChatGPT prompt
  -> Generate artwork
  -> For layered-motion scenes: generate foreground character on a
     transparent background, separate from the background plate
  -> Review artwork
  -> Approve character/environment continuity
  -> Google Flow animation
  -> Review generated video
  -> FFmpeg processing
  -> Validate dimensions, duration, codec, size
  -> Approve asset
  -> Update manifest
  -> Integrate into Flutter app
  -> Test on device
```

## 8.3 Asset naming

Use stable identifiers:

``` text
krishna_master_v001.png
arjuna_master_v001.png
kurukshetra_master_v001.png

ch01_scene001_poster.webp
ch01_scene001_loop.mp4
ch02_scene001_poster.webp
ch02_scene001_loop.mp4
ch02_scene002_panel001.webp
ch02_scene002_panel002.webp
```

Avoid ambiguous names such as `final_new_2.mp4`.

## 8.4 Asset manifest fields

Each approved asset should record: - Stable asset ID. - Relative file
path. - Media type. - Width and height. - Duration for audio/video. -
File size. - Codec and format where applicable. - Aspect ratio. - Source
tool. - Prompt ID/version. - Character reference IDs. - Creation date. -
Review/approval status. - License/rights status. - Checksum. - Target
scenes.

## 8.5 Media encoding and storage policy

-   Generate clean source assets and retain them outside the production
    bundle.
-   Create optimized app-ready derivatives with FFmpeg.
-   Use WebP or AVIF where supported and validated for images.
-   Use broadly compatible MP4/H.264 as the initial video baseline;
    evaluate other codecs only after device testing.
-   Keep a poster image for every video.
-   Avoid unnecessary audio tracks. Flow generates audio by default;
    strip it unless approved (`ffmpeg -i in.mp4 -an -c:v copy out.mp4`).
-   Normalize audio where included.
-   Flow clips are short (about 8 seconds). Author scenes as loops or as
    a still plus overlay motion, not long takes.
-   Measure actual file sizes and total chapter package sizes.
-   Bundle only the smallest sample needed for the first install.
-   Deliver later chapters as Play Asset Delivery on-demand packs
    before shipping large media collections.
-   Never assume a generated Flow clip is seamlessly loopable; inspect
    and process it.

------------------------------------------------------------------------

# 9. Detailed milestone roadmap

Estimates are planning ranges for a focused solo developer using AI
assistance. They are not guaranteed delivery dates. Visual production
and engineering can overlap after the initial references and contracts
are approved.

Scripture review time depends on external reviewer availability and is
not included in these estimates. Track it separately; it is likely the
critical path.

## Milestone 0 --- Product setup and project governance

**Estimate:** 1--2 days\
**Priority:** P0

### Tasks

-   [ ] Make and record every decision in section 2.2 (app name,
    package ID, Sanskrit source, translation sources, reviewers, sample
    range).
-   [ ] Contact and confirm the scripture reviewer and cultural
    reviewer.
-   [ ] Create GitHub repository `bhagavad-gita-motion`.
-   [ ] Create initial Flutter project.
-   [ ] Set application ID/package identity from the approved package
    ID.
-   [ ] Create `CLAUDE.md`.
-   [ ] Create README and contribution instructions.
-   [ ] Add product specification and roadmap.
-   [ ] Add architecture decision log.
-   [ ] Configure `.gitignore`.
-   [ ] Decide how large media assets will be stored.
-   [ ] Create GitHub issue labels and milestone labels.
-   [ ] Establish branch and commit conventions.
-   [ ] Record toolchain versions.

### Acceptance criteria

-   Repository exists and has a clean initial commit.
-   Flutter project opens successfully.
-   `flutter doctor` has no unresolved blocker for the selected Android
    target.
-   Product decisions are documented.
-   All section 2.2 decisions are recorded in `docs/DECISIONS.md`.
-   Claude Code can inspect the project and follow `CLAUDE.md`.

### Deliverables

-   GitHub repository.
-   `CLAUDE.md`.
-   `README.md`.
-   `docs/PRODUCT_SPEC.md`.
-   `docs/DECISIONS.md`.
-   `docs/ROADMAP.md`.

## Milestone 1 --- Flutter foundation and CI

**Estimate:** 1--3 days\
**Priority:** P0

### Tasks

-   [ ] Initialize Flutter stable project.
-   [ ] Configure Dart analysis rules.
-   [ ] Configure package/version management.
-   [ ] Add Riverpod.
-   [ ] Add GoRouter.
-   [ ] Establish app entry point and app theme.
-   [ ] Establish error handling and logging.
-   [ ] Add GitHub Actions workflow.
-   [ ] Add `flutter analyze` CI step.
-   [ ] Add `flutter test` CI step.
-   [ ] Generate and install debug APK.
-   [ ] Verify app launch on emulator and physical phone.

### Acceptance criteria

-   Debug build succeeds.
-   Static analysis passes.
-   Initial test suite passes.
-   CI runs on pushes and pull requests.
-   No unnecessary permissions are requested.

### Deliverables

-   Compiling Flutter skeleton.
-   CI workflow.
-   Initial test.
-   Build instructions.

## Milestone 2 --- Design system and navigation

**Estimate:** 3--5 days\
**Priority:** P0

### Tasks

-   [ ] Define colour tokens.
-   [ ] Define typography tokens.
-   [ ] Select and license Sanskrit/Devanagari font (candidates: Noto
    Serif Devanagari, Tiro Devanagari Sanskrit; both OFL).
-   [ ] Select English font.
-   [ ] Define spacing, radius, elevation, and border tokens.
-   [ ] Build reusable buttons and cards.
-   [ ] Build loading, empty, and error states.
-   [ ] Implement app navigation.
-   [ ] Implement Home screen.
-   [ ] Implement Chapter list screen.
-   [ ] Implement Chapter detail/introduction screen.
-   [ ] Implement Reader placeholder.
-   [ ] Implement Shloka detail placeholder.
-   [ ] Implement Bookmarks screen.
-   [ ] Implement Settings screen.
-   [ ] Add responsive layouts for common phone sizes.
-   [ ] Verify system bars and safe areas.

### Acceptance criteria

-   All primary screens are navigable.
-   UI uses design tokens rather than scattered hardcoded styles.
-   Text remains readable at larger accessibility text sizes.
-   Placeholder content is clearly identified as sample content.

### Deliverables

-   UI foundation.
-   Navigation flow.
-   Design system documentation.
-   Screenshot set.

## Milestone 3 --- Content schema and content engine

**Estimate:** 3--5 days\
**Priority:** P0

### Tasks

-   [ ] Define versioned chapter JSON schema.
-   [ ] Define scene JSON schema.
-   [ ] Define dialogue and panel schema.
-   [ ] Define shloka and translation schema.
-   [ ] Define media asset manifest.
-   [ ] Define effect configuration schema, including normalized
    anchor, scale, and intensity.
-   [ ] Add `dialogue_type` and `source_ref` to the dialogue schema.
-   [ ] Define separate `text_status` and `asset_status` fields and
    source metadata.
-   [ ] Create Dart models.
-   [ ] Add JSON serialization.
-   [ ] Implement schema validation.
-   [ ] Implement local bundled-content data source.
-   [ ] Implement repository interfaces and implementations.
-   [ ] Add sample chapter metadata.
-   [ ] Add three sample scenes.
-   [ ] Add at least one sample scene of each renderer type.
-   [ ] Add sample shloka record with verified source metadata or
    clearly marked non-publishable placeholder.
-   [ ] Add Dart validation tool (`dart run tool/validate_content.dart`)
    for content and asset references, and run it in CI.

### Acceptance criteria

-   App loads content from JSON.
-   UI does not contain hardcoded chapter/scene content.
-   Invalid schema produces a useful validation error.
-   Missing asset references are detected before release.
-   Sample content for all three renderer types parses and passes
    validation. (Rendering is verified in Milestone 8.)

### Deliverables

-   Content schema.
-   Dart content models.
-   Content repository.
-   Dart validation tools.
-   Sample JSON.

## Milestone 4 --- Character bible and creative direction

**Estimate:** 1--2 weeks, overlapping with engineering. AI character
consistency usually needs several iteration rounds.\
**Priority:** P0 for visual production

### Tasks

-   [ ] Create Krishna master character reference using ChatGPT.
-   [ ] Create Krishna front, three-quarter, side, and full-body
    references.
-   [ ] Create Krishna expression references.
-   [ ] Create Arjuna master character reference.
-   [ ] Create Arjuna pose and expression references.
-   [ ] Create chariot reference.
-   [ ] Create Kurukshetra environment references.
-   [ ] Define lighting and colour rules.
-   [ ] Define clothing, ornaments, and character continuity.
-   [ ] Create prompt templates.
-   [ ] Review and approve references.
-   [ ] Get cultural/devotional reviewer sign-off on Krishna and Arjuna
    references.
-   [ ] Record reference image IDs and versions.
-   [ ] Create `CHARACTER_BIBLE.md`.
-   [ ] Create `VISUAL_STYLE_GUIDE.md`.

### Acceptance criteria

-   Krishna and Arjuna have approved reusable references.
-   Character features are documented.
-   Reference assets have stable IDs.
-   No production scene is generated without the relevant approved
    reference.
-   Rejected variants are separated from approved assets.

### Deliverables

-   Character reference library.
-   Environment reference library.
-   Visual style guide.
-   Prompt library.

## Milestone 5 --- Scene production pilot

**Estimate:** 3--7 days, overlapping with engineering\
**Priority:** P0

### Pilot scenes

All pilot scenes stay inside the approved sample range (default:
Chapter 1 + 2.1--2.11).

1.  Armies assembled at Kurukshetra (1.1--1.11).
2.  Conch shells sound; chariot drawn between the armies (1.14--1.27).
3.  Arjuna's despair; bow set down (1.28--1.47).
4.  Arjuna asks Krishna for guidance (2.1--2.9).
5.  Krishna begins teaching --- signature scene (2.10--2.11).

Verify each verse range against the chosen source edition before
writing briefs.

### Tasks

-   [ ] Write scene briefs.
-   [ ] Verify scene sequence and scripture context.
-   [ ] Generate still artwork in ChatGPT.
-   [ ] Review character consistency.
-   [ ] Approve scene posters.
-   [ ] Create Flow prompts using reference ingredients.
-   [ ] Generate animation candidates.
-   [ ] Review movement and visual artefacts.
-   [ ] Select approved clips.
-   [ ] Process clips with FFmpeg (strip generated audio, trim, encode
    H.264, prepare loops).
-   [ ] Generate transparent foreground layers for layered-motion
    scenes.
-   [ ] Record effect anchor coordinates for each scene's artwork.
-   [ ] Create posters and optimized derivatives.
-   [ ] Add metadata to asset manifest.
-   [ ] Check licensing/usage terms for generated assets.
-   [ ] Store prompts and source versions.

### Acceptance criteria

-   At least five scene assets are approved.
-   At least one clip demonstrates the signature Krishna
    aura/feather/particles experience.
-   No generated clip contains incorrect or garbled scripture text.
-   Every asset keeps the bottom 35% overlay safe zone clear.
-   Every video has a poster fallback.
-   All production assets pass manifest validation.

### Deliverables

-   Five approved scene packages.
-   Flow prompt library.
-   Optimized media.
-   Asset manifest.

## Milestone 6 --- Media engine and lifecycle

**Estimate:** 3--5 days\
**Priority:** P0

### Tasks

-   [ ] Add video playback package.
-   [ ] Create media controller abstraction.
-   [ ] Implement initialization and disposal.
-   [ ] Handle buffering and errors.
-   [ ] Add poster fallback.
-   [ ] Add pause/resume/replay.
-   [ ] Add mute/volume handling.
-   [ ] Handle app lifecycle changes.
-   [ ] Handle route changes and player disposal.
-   [ ] Prevent duplicate active players.
-   [ ] Test device rotation and app backgrounding.
-   [ ] Test missing and corrupted media.

### Acceptance criteria

-   Cinematic video plays reliably.
-   Player is paused when reader is not active.
-   Player resources are released after leaving the reader.
-   Poster fallback appears on failure.
-   No uncontrolled playback continues in the background.

### Deliverables

-   Media service.
-   Playback controller.
-   Lifecycle tests.
-   Error handling.

## Milestone 7 --- Signature motion system

**Estimate:** 4--7 days\
**Priority:** P0

### Tasks

-   [ ] Define effect configuration model.
-   [ ] Position effects from normalized anchor coordinates in scene
    data.
-   [ ] Implement golden aura pulse.
-   [ ] Implement floating particles.
-   [ ] Implement peacock-feather motion layer.
-   [ ] Implement optional subtle background movement.
-   [ ] Implement dialogue reveal controller.
-   [ ] Implement scene transitions.
-   [ ] Implement reduced-motion behavior (honor
    `MediaQuery.disableAnimations` and the in-app setting).
-   [ ] Add effect intensity/duration configuration.
-   [ ] Avoid expensive per-frame allocations.
-   [ ] Test on low- and mid-tier devices.
-   [ ] Add static fallback for every effect.

### Acceptance criteria

-   Signature Krishna scene has the requested aura, feather, particles,
    and progressive dialogue.
-   Effects can be disabled or reduced.
-   Motion does not block reading.
-   Performance remains acceptable on target devices.
-   Effects do not continue after the scene is disposed.

### Deliverables

-   Reusable motion components.
-   Effect configuration.
-   Performance notes.
-   Reduced-motion tests.

## Milestone 8 --- Hybrid reader and manga experience

**Estimate:** 5--8 days\
**Priority:** P0

### Tasks

-   [ ] Create shared scene renderer contract.
-   [ ] Implement cinematic renderer.
-   [ ] Implement layered-motion renderer.
-   [ ] Implement manga-panel renderer.
-   [ ] Add panel ordering.
-   [ ] Add dialogue bubbles.
-   [ ] Add progressive dialogue reveal.
-   [ ] Add tap-to-reveal or next-dialogue controls.
-   [ ] Add previous/next scene navigation.
-   [ ] Add scene progress indicator.
-   [ ] Add shloka overlay/card.
-   [ ] Visually distinguish creative dialogue from scripture using
    `dialogue_type`.
-   [ ] Add pause/replay/mute controls.
-   [ ] Add portrait-first responsive layout.
-   [ ] Handle screen safe areas.
-   [ ] Add loading, error, and retry states.
-   [ ] Add accessibility labels and reading order.

### Acceptance criteria

-   All three renderer types work from the same content contract.
-   Reader can navigate forward and backward.
-   Dialogue can be read at the user's pace.
-   Shloka content is native app text, not baked into media.
-   Missing media does not crash the reader.

### Deliverables

-   Working hybrid reader.
-   Three renderer implementations.
-   Reader widget tests.
-   Sample content integration.

## Milestone 9 --- Scripture and multilingual experience

**Estimate:** 3--6 days for framework; content review continues
separately\
**Priority:** P0

### Tasks

-   [ ] Implement Sanskrit display (always shown for verses).
-   [ ] Implement Hindi display.
-   [ ] Implement English display.
-   [ ] Implement UI/translation language switching (Hindi or English).
-   [ ] Define language fallback behavior.
-   [ ] Add transliteration support and toggle.
-   [ ] Add word-by-word meaning display where reviewed.
-   [ ] Add translation attribution.
-   [ ] Add shloka detail screen.
-   [ ] Add verse navigation.
-   [ ] Verify Devanagari shaping and font rendering.
-   [ ] Test punctuation, line wrapping, and mixed-language layout.
-   [ ] Add content-review status display for internal builds.
-   [ ] Validate all sample verses against the chosen source edition.

### Acceptance criteria

-   Sanskrit and Hindi render correctly on supported devices.
-   English text is readable and correctly attributed.
-   Language switching does not lose reading position.
-   Unreviewed translations cannot accidentally appear as approved
    content.
-   Verse references match the selected source edition.

### Deliverables

-   Multilingual text system.
-   Shloka reader.
-   Reviewed sample scripture content.
-   Source/attribution records.

## Milestone 10 --- Persistence, bookmarks, progress, and settings

**Estimate:** 4--7 days\
**Priority:** P1, but required before public beta

This milestone merges the former Milestone 10 (persistence) and
Milestone 12 (bookmarks, progress, settings).

### Tasks

Storage:

-   [ ] Choose storage: SharedPreferences for the MVP, or Drift +
    SQLite if download metadata is already needed. Record the decision.
-   [ ] Define bookmark storage.
-   [ ] Define reading-progress storage.
-   [ ] Implement repository persistence.
-   [ ] Handle storage/schema migrations.
-   [ ] Test fresh install and app upgrade.
-   [ ] Verify reading works offline.

Reading progress and bookmarks:

-   [ ] Save last-read chapter and scene.
-   [ ] Save panel/verse position where relevant.
-   [ ] Implement resume reading and continue-reading card.
-   [ ] Add chapter completion/progress display.
-   [ ] Add bookmark action to shloka and scene views.
-   [ ] Add bookmarks list and remove action.

Settings:

-   [ ] Persist UI/translation language preference.
-   [ ] Persist animation (reduced-motion) preference.
-   [ ] Persist ambient sound preference.
-   [ ] Add text-size setting if not handled solely through system
    scaling.
-   [ ] Add clear-progress action with confirmation.
-   [ ] Add app/about and attribution pages.

### Acceptance criteria

-   App resumes at the last-read position.
-   Bookmarks persist across restarts.
-   Preferences persist and apply consistently.
-   Clear-progress action is safe and explicit.
-   Core sample content works without internet.
-   Migrations are tested.
-   Corrupt or missing optional media does not corrupt reading progress.

### Deliverables

-   Local persistence layer.
-   Persistence repositories.
-   Bookmarks, progress, and settings UI.
-   Offline and persistence tests.
-   Migration strategy.

## Milestone 11 --- Chapter packaging with Play Asset Delivery

**Estimate:** 2--4 days; can be deferred if MVP ships only bundled
sample media\
**Priority:** P1

Use Play Asset Delivery on-demand asset packs instead of a custom
download server. Google hosts the packs and handles integrity, so no
backend, resume, or checksum logic is needed.

### Tasks

-   [x] Define one asset pack per chapter and its manifest.
-   [x] Select or write the Flutter integration for Play Asset Delivery
    (plugin or platform channel). Record the reason.
-   [x] Show pack size before download.
-   [x] Design download progress UI.
-   [x] Handle low-storage and failed-download states.
-   [x] Implement remove downloaded chapter.
-   [x] Ensure bundled sample content remains available.
-   [x] Add storage usage screen.
-   [ ] Test with internal app sharing / internal testing track.
    Local testing with bundletool done (D-141); Play track waits for
    signing (Milestone 15).
-   [ ] Test offline after download.

### Acceptance criteria

-   Chapter packs download through Play and load correctly.
-   Users can remove optional media without deleting bookmarks/progress.
-   App clearly identifies downloaded and unavailable content.

### Deliverables

-   Chapter asset pack structure.
-   Pack download integration.
-   Storage management UI.
-   Download tests.

## Milestone 12 --- Merged into Milestone 10

Bookmarks, progress, and settings are now part of Milestone 10. The
number is kept so later milestone numbers stay stable.

## Milestone 13 --- Audio and sound (optional MVP enhancement)

**Estimate:** 2--5 days\
**Priority:** P2

### Tasks

-   [ ] Decide whether narration is in MVP.
-   [ ] Select and license ambient sound/music.
-   [ ] Define audio asset manifest.
-   [ ] Add narration transcript/captions.
-   [ ] Implement audio controls.
-   [ ] Handle audio focus and interruptions.
-   [ ] Respect mute and sound preferences.
-   [ ] Avoid autoplaying sound unexpectedly.
-   [ ] Test audio/video synchronization where relevant.

### Acceptance criteria

-   All audio rights are documented.
-   Audio controls are accessible.
-   Audio stops or pauses correctly on navigation and interruptions.
-   Text remains available when audio is disabled.

### Deliverables

-   Audio subsystem, if approved.
-   Licensed audio assets.
-   Audio tests.

## Milestone 14 --- Quality, accessibility, and performance

**Estimate:** 4--7 days\
**Priority:** P0 before public beta

Results and open items: `docs/QA_REPORT.md`.

### Functional tests

-   [x] Home and chapter navigation.
-   [x] Scene navigation.
-   [x] Renderer selection.
-   [x] Dialogue reveal.
-   [x] Shloka rendering.
-   [x] Language switching.
-   [x] Bookmarks.
-   [x] Reading progress.
-   [ ] Offline behavior.
-   [x] Missing media fallback.
-   [x] Video pause/resume/disposal.

### Device and lifecycle tests

-   [ ] Low-memory device.
-   [x] Mid-range device.
-   [x] High-end device.
-   [x] App background/foreground.
-   [ ] Incoming call/audio interruption.
-   [ ] Screen lock/unlock.
-   [x] Process death and resume.
-   [ ] Orientation and different screen sizes.
-   [x] Low storage.
-   [ ] No network.

### Accessibility tests

-   [x] Screen-reader labels.
-   [ ] Logical reading order.
-   [x] Large text.
-   [x] Contrast.
-   [x] Touch target size.
-   [x] Reduced motion.
-   [ ] Captions/transcripts for narration.
-   [x] No meaning conveyed only through colour or animation.

### Performance checks

-   [x] App startup.
-   [x] Reader entry.
-   [x] Video initialization.
-   [x] Memory usage.
-   [x] Frame pacing.
-   [ ] Battery usage.
-   [x] Image decode sizes.
-   [x] Total installed size.
-   [x] Chapter package sizes.

### Acceptance criteria

-   No known critical crashes.
-   No blocker-level defects.
-   Reader works with motion disabled.
-   Performance is acceptable on the agreed target-device matrix.
-   Test results are documented.
-   At least 12 closed-test testers are recruited for Milestone 16.

## Milestone 15 --- Security, privacy, legal, and release preparation

**Estimate:** 3--5 days\
**Priority:** P0 before public release

Guide: `docs/RELEASE.md`. Owner steps: create upload key, Play Console.

### Tasks

-   [x] Confirm app permissions are minimal.
-   [x] Confirm no secrets are embedded in the app.
-   [x] Document local data stored by the app.
-   [x] Prepare privacy policy appropriate to actual data practices.
-   [x] Prepare terms/attribution where needed.
-   [ ] Complete translation and commentary license review.
    Review done (`docs/RIGHTS_REVIEW.md`); digital Sanskrit source still to choose.
-   [ ] Complete font and audio license review.
-   [ ] Complete artwork/tool terms review.
    Review done; Flow videos block public release.
-   [ ] Prepare app icon.
    Prompt ready; owner generates.
-   [x] Prepare screenshots.
-   [x] Prepare Play Store description.
-   [x] Prepare support contact and issue process.
-   [x] Configure signing securely.
-   [x] Build release AAB.
-   [x] Test release build, not just debug.
-   [ ] Set up internal testing track.
-   [x] Meet the current Play target API level requirement.
-   [ ] Complete the Data safety form.
-   [ ] Complete the content rating questionnaire.
-   [ ] Review current Play Console requirements.

### Acceptance criteria

-   Release artifact installs and runs.
-   All content and media rights are documented.
-   Privacy disclosures reflect actual behavior.
-   Signing material is stored securely.
-   Store listing assets are complete.

### Deliverables

-   Release AAB.
-   Store listing materials.
-   Privacy and licensing documents.
-   Release checklist sign-off.

## Milestone 16 --- Public beta and feedback

**Estimate:** 2--3 weeks of feedback and iteration (includes the
14-day closed-test minimum)\
**Priority:** P1

### Tasks

-   [ ] Run a closed test with at least 12 opted-in testers for 14
    continuous days. Play requires this for new personal developer
    accounts before production access.
-   [ ] Distribute to a small internal/closed testing group.
-   [ ] Collect device compatibility reports.
-   [ ] Collect reader usability feedback.
-   [ ] Review crash and performance reports if enabled.
-   [ ] Review scripture and translation feedback.
-   [ ] Review character consistency feedback.
-   [ ] Fix critical issues.
-   [ ] Improve onboarding and navigation.
-   [ ] Re-run regression suite.
-   [ ] Publish a revised beta.

### Acceptance criteria

-   Critical feedback is triaged.
-   No unresolved critical defects.
-   Reader comprehension and usability are acceptable.
-   Release candidate is approved.

### Deliverables

-   Beta feedback report.
-   Defect backlog.
-   Release candidate.

## Milestone 17 --- Expansion to all 18 chapters

**Estimate:** Content-dependent; plan chapter batches\
**Priority:** P1 after MVP validation

### Tasks

-   [ ] Create chapter-by-chapter story outlines.
-   [ ] Map every scene to verified scripture references.
-   [ ] Decide which verses need cinematic scenes.
-   [ ] Decide which conversations need manga panels.
-   [ ] Generate and approve artwork in batches.
-   [ ] Generate Flow animations for selected scenes.
-   [ ] Process and optimize media.
-   [ ] Review translations and commentary.
-   [ ] Add content source metadata.
-   [ ] Validate chapter/verse ordering.
-   [ ] Run automated content validation.
-   [ ] Run visual continuity review.
-   [ ] Release chapter packages in stages.

### Acceptance criteria

-   Every published chapter has approved text and media.
-   Verse references are accurate.
-   Translation and asset rights are recorded.
-   All scene assets pass validation.
-   Chapters can be added without changing reader code.

### Deliverables

-   Approved chapter packages.
-   Full content catalogue.
-   Content release notes.

## Milestone 18 --- Post-MVP enhancements

**Priority:** P2 / future

Possible additions: - Optional cloud backup and cross-device sync. - iOS
version using the Flutter codebase. - Additional language packs. -
Narrated reading. - Search across verses and themes. - Daily reading
plans. - Adjustable reading pace. - Download manager improvements. -
Optional content updates. - Accessibility refinements. - More detailed
word-by-word study mode. - Curated commentary, subject to licensing and
review.

Do not add an AI religious-answer chatbot until its sources,
limitations, citations, safety, and review approach are clearly
designed.

------------------------------------------------------------------------

# 10. Initial prioritized backlog

Use these IDs in GitHub Issues. Keep tasks small enough to implement and
review independently.

  ID       Task                                 Priority   Milestone
  -------- ------------------------------------ ---------- -----------
  BG-001   Create GitHub repository             P0         0
  BG-002   Create Flutter project               P0         1
  BG-003   Configure analysis and CI            P0         1
  BG-004   Write CLAUDE.md                      P0         0
  BG-005   Define theme tokens                  P0         2
  BG-006   Implement app navigation             P0         2
  BG-007   Build Home screen                    P0         2
  BG-008   Build Chapter list                   P0         2
  BG-009   Define content schema                P0         3
  BG-010   Implement content repository         P0         3
  BG-011   Create Krishna reference pack        P0         4
  BG-012   Create Arjuna reference pack         P0         4
  BG-013   Create environment references        P0         4
  BG-014   Produce five pilot scenes            P0         5
  BG-015   Define media manifest                P0         3/5
  BG-016   Implement video controller           P0         6
  BG-017   Implement cinematic renderer         P0         8
  BG-018   Implement layered-motion renderer    P0         7/8
  BG-019   Implement aura and particles         P0         7
  BG-020   Implement dialogue reveal            P0         7/8
  BG-021   Implement manga renderer             P0         8
  BG-022   Implement shloka detail view         P0         9
  BG-023   Add Sanskrit/Hindi/English support   P0         9
  BG-024   Add local persistence layer          P1         10
  BG-025   Implement bookmarks                  P1         10
  BG-026   Implement reading progress           P1         10
  BG-027   Implement offline sample reading     P1         10
  BG-028   Implement reduced-motion mode        P0         7/14
  BG-029   Add content validator                P0         3
  BG-030   Add asset validator                  P0         5
  BG-031   Test low-memory playback             P0         14
  BG-032   Prepare privacy/licensing review     P0         15
  BG-033   Build release AAB                    P0         15
  BG-034   Run closed beta (12 testers, 14 d)   P1         16
  BG-035   Record Milestone 0 decisions         P0         0
  BG-036   Confirm scripture/cultural reviewers P0         0
  BG-037   Integrate Play Asset Delivery        P1         11

Priority definitions: - **P0:** Required for a working, trustworthy
beta. - **P1:** Required for a useful public release or the next planned
release. - **P2:** Future enhancement.

------------------------------------------------------------------------

# 11. Claude Code workflow and project rules

## 11.1 Claude Code responsibilities

Claude Code is the implementation agent. It should: - Inspect before
editing. - Follow architecture and content contracts. - Implement one
milestone at a time. - Write tests alongside code. - Run formatting,
analysis, and tests. - Explain dependency changes. - Avoid changing
approved product decisions without asking. - Never invent scripture or
translation content. - Never replace real content with unmarked mock
content. - Report unverified behavior honestly.

## 11.2 Suggested CLAUDE.md rules

Include: - Product summary and visual direction. - Flutter/Dart version
and commands. - Folder structure. - Architecture boundaries. - Naming
conventions. - Content schema location. - Asset naming rules. - Media
lifecycle rules. - Scripture integrity and copyright rules. - Test
expectations. - Definition of done. - Instructions to update docs when
architecture changes.

## 11.3 Standard development loop

``` text
Read issue and relevant docs
  -> Inspect current implementation
  -> Propose a small implementation plan
  -> Implement
  -> Add/update tests
  -> Format
  -> flutter analyze
  -> flutter test
  -> Build Android debug app when relevant
  -> Review diff
  -> Update docs
  -> Commit
```

Useful commands:

``` bash
flutter doctor
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
flutter build appbundle --release
```

Use the Windows command equivalents where needed. Run release builds
only after signing configuration is safely established.

## 11.4 Git practices

-   Use `main` for stable code.
-   Use short-lived feature branches.
-   Make small, descriptive commits.
-   Do not commit secrets, signing keys, or private credentials.
-   Do not commit huge raw generated source videos by default.
-   Keep approved media reproducible from documented source assets.
-   Use Git LFS or separate storage only after choosing a clear asset
    policy.
-   Tag milestone releases.

------------------------------------------------------------------------

# 12. First Claude Code implementation prompts

Run these prompts from the root of the new repository, one at a time.
Each prompt ends with a stop-and-wait gate. Do not ask Claude Code to
build the entire product in one pass. Complete Milestone 0 decisions
before running 12a.

The shared context block below is pasted at the top of each prompt.

## 12.0 Shared context (prepend to 12a, 12b, 12c)

``` text
PROJECT
Name: <approved app name from Milestone 0>
Package identity: <approved package ID from Milestone 0>
Platform: Android first
Framework: Flutter stable
Language: Dart

PRODUCT VISION
Build an immersive, offline-first Bhagavad Gita storytelling app combining:
1. Full-screen cinematic scenes.
2. Illustrated manga panels.
3. Sanskrit shlokas.
4. Hindi and English translations/explanations.
5. Progressive dialogue reveal.
6. Subtle divine visual effects.

VISUAL IDENTITY
- Cinematic Indian mythology.
- Dignified, peaceful, compassionate portrayal of Krishna.
- Consistent Krishna and Arjuna character references.
- Midnight blue, antique gold, celestial blue, and warm ivory.
- No generic cartoon styling.
- No scripture text baked into generated images or video.

TOOLS
- ChatGPT for character and scene artwork.
- Google Flow for cinematic animation.
- Claude Code for engineering.
- FFmpeg for media processing.
- GitHub for version control.

LANGUAGES
Sanskrit verse text is always shown for verses.
UI and translation language: Hindi or English.
Transliteration is a toggle.

ARCHITECTURE
Shared lib/data/ and lib/domain/; feature folders hold presentation only.
Keep content independent of widgets.
Keep media playback lifecycle separate from content parsing.
Use repositories for data access.
Do not make widgets query storage directly.
Avoid premature multi-package architecture.
Every new dependency must have a documented reason.

RULES
Do not guess incompatible package versions. Inspect the installed Flutter SDK and select compatible stable releases. Record versions.
Do not add a backend, accounts, Supabase, or Firebase.
Do not generate or invent scripture content.
Do not silently change product decisions.
Report commands run, results, changed files, and outstanding issues.
```

## 12a. Skeleton, CI, and project rules

``` text
# TASK 12a: Flutter skeleton and CI

Act as the principal Flutter architect and senior Dart engineer.

<paste 12.0 shared context>

DELIVERABLES
1. Inspect the repository and installed environment. Report blockers before changing files.
2. Create the Flutter project with the approved package ID.
3. Add Riverpod and GoRouter at compatible stable versions. Record versions.
4. Configure Dart analysis rules.
5. Create a minimal app entry point that launches to a placeholder screen.
6. Create CLAUDE.md (rules from roadmap section 11.2) and README.md.
7. Add one smoke widget test.
8. Configure GitHub Actions: dart format check, flutter analyze, flutter test.
9. Run dart format, flutter analyze, flutter test, and flutter build apk --debug where the environment permits.
10. Fix errors introduced by your changes.

STOP after this task. Wait for approval before 12b.
```

## 12b. Theme, navigation, and placeholder screens

``` text
# TASK 12b: Design tokens, navigation, screens

Act as the principal Flutter architect and senior Dart engineer.

<paste 12.0 shared context>

DESIGN
- Dark cinematic UI.
- Antique gold accents, celestial blue highlights, warm ivory text.
- Reusable design tokens (colour, typography, spacing, radius, elevation).
- Devanagari font: Noto Serif Devanagari or Tiro Devanagari Sanskrit (OFL). Record the choice.
- Responsive mobile layouts and safe areas for system bars.
- Accessible text sizes and touch targets.

DELIVERABLES
1. Theme and design tokens.
2. GoRouter navigation for all screens.
3. Home screen.
4. Chapter list with 18 entries, clearly labelled as sample data.
5. Chapter detail placeholder.
6. Reader placeholder.
7. Shloka placeholder.
8. Bookmarks placeholder.
9. Settings screen with UI/translation language selector (Hindi, English) and reduced-motion placeholder.
10. Loading, empty, and error state widgets.
11. Widget tests for navigation and screens.
12. Run dart format, flutter analyze, flutter test.

STOP after this task. Wait for approval before 12c.
```

## 12c. Content models, schema, and validator

``` text
# TASK 12c: Content models and validation

Act as the principal Flutter architect and senior Dart engineer.

<paste 12.0 shared context>

CONTENT
Create Dart models and a versioned JSON schema for:
- Chapter, Scene, Dialogue, Panel, Shloka, Translation, MediaAsset, Effect, ReadingProgress, Bookmark.

Schema requirements (see roadmap sections 5.2--5.4):
- Effect: normalized anchor (x, y in 0--1), scale, intensity.
- Dialogue: dialogue_type (creative | narration | verse_paraphrase | verse_translation) and source_ref.
- Separate text_status (per language) and asset_status fields.

Create clearly labelled sample data only. Do not invent or publish Sanskrit verses or translations as authoritative. Use an explicit pending-verification placeholder until source material is verified.

DELIVERABLES
1. Dart models with JSON serialization.
2. Sample JSON for one scene of each renderer type.
3. Local bundled-content data source and repository.
4. tool/validate_content.dart: schema checks, missing asset references, source_ref rules.
5. Add the validator to CI.
6. Unit tests for parsing and validation, including invalid fixtures.
7. Run dart format, flutter analyze, flutter test.

STOP after this task. Wait for approval before the next milestone.
```

------------------------------------------------------------------------

# 13. Definition of done for every milestone

A milestone is not complete merely because code was generated.

Every milestone must satisfy: - \[ \] Requirements are implemented. - \[
\] Relevant tests pass. - \[ \] `dart format` has been run. - \[ \]
`flutter analyze` has no unresolved project errors. - \[ \] No known
critical regression is introduced. - \[ \] UI has been checked on an
emulator or physical device where relevant. - \[ \] Media and lifecycle
behavior has been checked where relevant. - \[ \] Documentation is
updated. - \[ \] New assets have manifest entries and rights metadata. -
\[ \] Git changes are reviewed and committed. - \[ \] Acceptance
criteria are explicitly checked off.

For scripture/content milestones, also require source verification,
translation attribution, review status, and rights checks.

------------------------------------------------------------------------

# 14. Risk register

  -----------------------------------------------------------------------
  Risk                    Impact                  Mitigation
  ----------------------- ----------------------- -----------------------
  Krishna/Arjuna visual   High                    Approved reference
  inconsistency                                   library and review

  Incorrect Sanskrit or   Critical                Trusted source edition
  verse mapping                                   and human verification

  Copyrighted translation Critical                Licensing register and
  used without permission                         rights review

  AI-generated visual     Medium                  Human asset review and
  artefacts                                       selective cleanup

  Very large video assets High                    FFmpeg optimization and
                                                  chapter downloads

  Video playback failure  High                    Poster fallback and
  on some devices                                 device testing

  Battery drain from      Medium                  Pause off-screen
  effects                                         effects and reduced
                                                  motion

  Reader becomes visually High                    Restrained motion and
  distracting                                     user-controlled reveal

  Content/renderer        High                    Versioned JSON schema
  coupling                                        and renderer contract

  App becomes too complex High                    Milestone gates and MVP
  too early                                       scope control

  Lost work or broken     High                    Git commits, branches,
  changes                                         and CI

  Inadequate              High                    Reduced motion, text
  accessibility                                   scaling, semantics,
                                                  captions

  Unclear media rights    Critical                Record generation
                                                  source and applicable
                                                  tool terms

  Scripture reviewer      High                    Confirm reviewer in
  unavailable or slow                             Milestone 0; track
                                                  review time separately

  Community objection to  High                    Cultural/devotional
  AI depiction of Krishna                         reviewer sign-off on
                                                  references and scenes

  Play closed-test        Medium                  Recruit 12+ testers
  requirement delays                              during Milestone 14
  production
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# 15. Release acceptance checklist

Before public release:

## Product

-   [ ] App name and branding approved.
-   [ ] MVP scope met.
-   [ ] Onboarding and navigation understandable.
-   [ ] No placeholder content presented as final scripture.

## Scripture and content

-   [ ] Sanskrit source edition documented.
-   [ ] Chapter and verse references verified.
-   [ ] Hindi and English translations reviewed.
-   [ ] Translator/commentary attribution included.
-   [ ] Rights and licenses recorded.
-   [ ] Dialogue clearly distinguished from canonical scripture.

## Artwork and media

-   [ ] Krishna and Arjuna references approved.
-   [ ] Character continuity reviewed.
-   [ ] All videos have poster fallbacks.
-   [ ] Video codec and dimensions tested.
-   [ ] Asset manifest validates.
-   [ ] Media rights and tool terms reviewed.
-   [ ] No malformed AI text in artwork.

## Engineering

-   [ ] Release build succeeds.
-   [ ] Tests pass.
-   [ ] Analysis passes.
-   [ ] No critical crashes.
-   [ ] Video lifecycle works.
-   [ ] Offline reading works.
-   [ ] Bookmarks and progress persist.
-   [ ] Reduced-motion setting works.
-   [ ] Low-memory behavior tested.
-   [ ] Permissions are minimal.

## Store and operations

-   [ ] Privacy policy matches actual app behavior.
-   [ ] App signing is secure.
-   [ ] Store listing and screenshots prepared.
-   [ ] Support contact established.
-   [ ] Closed test completed (12+ testers, 14 continuous days).
-   [ ] Target API level, Data safety form, and content rating done.
-   [ ] Feedback triaged.
-   [ ] Release notes prepared.

------------------------------------------------------------------------

# 16. Recommended execution order

Do not attempt every milestone at once.

The recommended sequence is:

1.  **Make Milestone 0 decisions: app name, package ID, Sanskrit
    source, translation sources, reviewers, sample range.**
2.  **Set up the repository and Flutter environment.**
3.  **Run prompt 12a (skeleton + CI), then approve.**
4.  **Run prompt 12b (theme + navigation + screens), then approve.**
5.  **Run prompt 12c (content schema + validator), then approve.**
6.  **Create and approve Krishna, Arjuna, and environment references
    using ChatGPT.**
7.  **Produce five pilot scenes in the sample range with Google Flow.**
8.  **Implement the media engine and signature motion effects.**
9.  **Complete the hybrid reader.**
10. **Integrate reviewed Sanskrit, Hindi, and English content.**
11. **Add persistence, bookmarks, progress, and settings.**
12. **Test, optimize, and run the 14-day closed beta.**
13. **Expand the content chapter by chapter via Play Asset Delivery.**

## First immediate action

Record the Milestone 0 decisions in `docs/DECISIONS.md`. Then create the
GitHub repository `bhagavad-gita-motion`, add this roadmap as
`docs/ROADMAP.md`, and run prompt 12a.

**Do not start by generating all 18 chapters. First prove that one
Krishna scene, one manga sequence, and one shloka experience work
beautifully together on a real Android device.**
