# CLAUDE.md

Rules for Claude Code and contributors working on Moksharan.

## Product

Moksharan is an offline-first Android app (Flutter/Dart) that presents
the Bhagavad Gita as a motion manga: full-screen cinematic scenes,
layered-motion scenes, and manga panels. Sanskrit verse text is always
shown; UI and translation language is Hindi or English; transliteration
is a toggle.

Visual direction: cinematic Indian mythology. Midnight blue and charcoal
surfaces, antique gold accents, celestial blue highlights, warm ivory
text. Dignified, peaceful, compassionate portrayal of Krishna. Motion
supports reading and never competes with it.

Source of truth: `docs/ROADMAP.md`. Decisions: `docs/DECISIONS.md`.

## Identity

- App name: Moksharan
- Package ID: `io.github.karan_ksrk.moksharan` (permanent; never change)
- Repo: https://github.com/karan-ksrk/bhagavad-gita-motion

## Toolchain

Flutter 3.47.9 stable, Dart 3.13.7, JDK 17. Key packages:
`flutter_riverpod` 3.x, `go_router` 18.x, `very_good_analysis` (lints).

Commands:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

Do not run release builds until signing is configured (Milestone 15).

## Folder structure

```text
lib/
  main.dart, app.dart
  core/        routing, theme, localization, media, animation, errors, widgets
  data/        datasources, models, repository implementations
  domain/      entities, repository contracts, use cases (only when useful)
  features/    <feature>/ presentation code only (screens, widgets, notifiers)
tool/          Dart CLI tools (validators, media manifest)
assets/        app-ready content and media only
media-production/  source and rejected assets; never bundled
test/          unit/, widget/, fixtures/, integration/
docs/          created when a milestone needs each doc
```

## Architecture rules

- Feature folders hold presentation only. Shared `data/` and `domain/`.
- Widgets never query storage directly; UI never parses raw JSON.
- Repositories abstract all data sources.
- Use Riverpod for state; keep side effects testable.
- Route paths live in `core/routing/app_router.dart` (`AppRoutes`).
- Content is data (JSON), never hardcoded in widgets.
- Keep media playback lifecycle separate from content parsing.
- Dispose video controllers when leaving a scene; one active player max.
- Never preload every chapter's media.
- No backend, accounts, Firebase, or Supabase in the MVP.
- Every new dependency needs a reason recorded in `docs/DECISIONS.md`.
- Use a single app package; do not split into packages without a reason.

## Naming

- Dart: `snake_case.dart` files, `UpperCamelCase` types, `lowerCamelCase`
  members.
- Content IDs: `chapter_02`, `ch02_scene_001`, verse `BG.2.47`.
- Assets: `ch01_scene001_poster.webp`, `ch01_scene001_loop.mp4`,
  `krishna_master_v001.png`. Never `final_new_2.mp4`.

## Scripture integrity (non-negotiable)

- Never invent, generate, or "fill in" Sanskrit verses, translations, or
  word meanings.
- Use explicit pending-verification placeholders until a source is
  verified; label all sample data as sample.
- Every dialogue line has a `dialogue_type`: `creative`, `narration`,
  `verse_paraphrase`, or `verse_translation`. Creative dialogue must be
  visually distinct from scripture.
- Verse numbering follows the Gita Press Gorakhpur edition (D-003).
- English translation: Telang 1882 (D-004). Hindi: original reviewed
  explanations only (D-005).
- Never bake text into artwork or video; render all text in the app.

## Media rules

- Bottom 35% of every vertical frame stays clear for overlays.
- H.264 MP4 baseline, WebP posters, a poster for every video.
- Strip Flow-generated audio unless approved.
- Every asset has a manifest entry with source, rights, and checksum.

## Working rules

- Inspect before editing. Implement one milestone or prompt at a time.
- Write tests alongside code.
- Run format, analyze, and test before reporting done.
- Do not change approved decisions without asking.
- Report unverified behavior honestly; never claim a check you did not run.
- Update docs when architecture changes.
- Stop at each prompt's gate and wait for approval.

## Definition of done

Requirements implemented; tests pass; `dart format` run; `flutter
analyze` clean; UI checked on device where relevant; docs updated; new
assets have manifest and rights entries; acceptance criteria checked.
