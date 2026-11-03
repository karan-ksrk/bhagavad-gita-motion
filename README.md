# Moksharan

An offline-first Android app that presents the Bhagavad Gita as a motion
manga: cinematic scenes, layered motion, and illustrated manga panels,
with the Sanskrit shloka and Hindi/English translations rendered as app
text.

Status: **foundation build (Milestone 1).** No scripture content is
included yet. Any sample data is labelled as sample and is not
authoritative.

## Requirements

| Tool | Version |
|------|---------|
| Flutter | 3.47.9 stable |
| Dart | 3.13.7 |
| JDK | 17 |
| Android SDK | platform 36+ |

## Setup

```bash
flutter pub get
flutter run            # on a connected Android device or emulator
```

## Checks

Run these before every commit. CI runs the same checks.

```bash
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

## Project docs

- [docs/ROADMAP.md](docs/ROADMAP.md): master plan, milestones, backlog.
- [docs/DECISIONS.md](docs/DECISIONS.md): product and technical decisions.
- [CLAUDE.md](CLAUDE.md): rules for Claude Code and contributors.

## Content and rights

Scripture text, translations, artwork, fonts, and audio each require a
recorded source and license before publication. See the roadmap,
section 5.5.
