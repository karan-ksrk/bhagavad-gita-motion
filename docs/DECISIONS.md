# Decision Log

Record every product, content, and technical decision here. Do not make
these decisions silently in code. Each entry states the decision, the
reason, who approved it, and the date.

Status values: `proposed`, `approved`, `pending`, `superseded`.

------------------------------------------------------------------------

## Milestone 0 decisions

### D-001 App name

- **Decision:** Moksharan (lowercase `moksharan` in identifiers)
- **Reason:** Distinct from the many existing "Bhagavad Gita" Play
  listings.
- **Open action:** [ ] Search Play Store for "Moksharan" to confirm no
  conflicting listing before first upload.
- **Status:** approved
- **Approved by / date:** Karan, 2026-11-03

### D-002 Android package ID

- **Decision:** `io.github.karan_ksrk.moksharan`
- **Reason:** Namespace under the owner's GitHub account
  (`karan-ksrk`). Hyphen replaced with underscore because Java/Android
  package segments do not allow hyphens.
- **Note:** Permanent after first Play upload.
- **Status:** approved
- **Approved by / date:** Karan, 2026-11-03

### D-003 Sanskrit source edition

- **Decision:** Standard 700-verse text, using the chapter and verse
  numbering of the Gita Press Gorakhpur edition.
- **Cross-check edition:** _TBD_ (choose one second printed or
  scholarly edition)
- **Digital source used (URL / file):** _TBD_ (record exact source if
  text is copied from a digital copy)
- **License of digital source:** _TBD_
- **Status:** approved (edition); pending (cross-check and digital
  source)
- **Approved by / date:** Karan, 2026-11-03

### D-004 English translation source

- **Decision:** Kashinath Trimbak Telang, *The Bhagavadgîtâ* (1882),
  Sacred Books of the East, Vol. 8.
- **Reason:** Close, literal translation; public domain (published 1882,
  translator died 1893).
- **Fallback / comparison:** Annie Besant, *The Bhagavad-Gita* (1905),
  also public domain.
- **Note:** Telang's English is archaic. Modern-language explanations,
  if added, are original content and require scripture-reviewer
  approval. Mark them `dialogue_type` / content type accordingly and
  never present them as the translation.
- **License status:** Public domain. Record the exact scanned edition
  used in `docs/SCRIPTURE_SOURCES.md`.
- **Status:** approved
- **Approved by / date:** Karan, 2026-11-03

### D-005 Hindi translation source

- **Decision:** Original Hindi explanations, written for this app and
  approved by the scripture reviewer (D-006). No third-party Hindi
  translation is used unless licensed later.
- **Reason:** Public-domain Hindi translations with clear rights are
  scarce; modern Hindi translations are usually copyrighted.
- **Blocker:** Cannot be published until a scripture reviewer is
  confirmed.
- **Status:** pending (reviewer required)
- **Approved by / date:** Karan, 2026-11-03 (approach only)

### D-006 Scripture reviewer

- **Name:** _None yet_
- **Target profile:** Sanskrit/Gita scholar, e.g. university Sanskrit
  faculty or temple/mission scholar.
- **Contact confirmed:** [ ] yes
- **Status:** pending
- **Impact:** Does not block engineering (prompts 12a/12b/12c use
  placeholder content). Blocks Milestone 5 scene briefs, Milestone 9
  scripture content, D-005, and any public release.

### D-007 Cultural / devotional reviewer

- **Name:** _None yet_
- **Contact confirmed:** [ ] yes
- **Status:** pending
- **Impact:** Blocks approval of Krishna and Arjuna reference packs
  (Milestone 4) and public release.

### D-008 MVP sample range

- **Decision:** Chapter 1 + Chapter 2 verses 2.1--2.11.
- **Open action:** [ ] Verify pilot-scene verse ranges against D-003.
- **Status:** approved
- **Approved by / date:** Karan, 2026-11-03

------------------------------------------------------------------------

## Confirmed decisions (from roadmap section 2.1)

| ID | Area | Decision | Status |
|----|------|----------|--------|
| D-101 | Initial platform | Android only | approved |
| D-102 | Framework / language | Flutter stable / Dart | approved |
| D-103 | Reading experience | Hybrid: cinematic scenes + layered motion + manga panels | approved |
| D-104 | Languages | Sanskrit verse text always shown; UI/translation in Hindi or English; transliteration toggle | approved |
| D-105 | Media delivery | Bundled sample; later chapters via Play Asset Delivery; no custom server | approved |
| D-106 | Artwork generation | ChatGPT image generation | approved |
| D-107 | Video generation | Google Flow | approved |
| D-108 | Engineering agent | Claude Code | approved |
| D-109 | Media processing | FFmpeg | approved |
| D-110 | Version control | Git + GitHub (account `karan-ksrk`) | approved |
| D-111 | Backend | None for MVP; local-first | approved |
| D-112 | Local image generation | Not used | approved |
| D-113 | Krita | Optional only | approved |

------------------------------------------------------------------------

## Dependencies

| ID | Package | Version | Reason | Status |
|----|---------|---------|--------|--------|
| D-114 | `very_good_analysis` (dev) | ^11.0.0 | Stricter lint set than `flutter_lints`; `public_member_api_docs` disabled because this is an app, not a package | approved |
| D-115 | `flutter_riverpod` | ^3.4.3 | State management (roadmap §3) | approved |
| D-116 | `go_router` | ^18.1.2 | Navigation (roadmap §3) | approved |
| D-117 | removed `cupertino_icons`, `flutter_lints` | -- | Android-only Material app; lints replaced by D-114 | approved |
| D-118 | Font: Tiro Devanagari Sanskrit (bundled TTF, Regular + Italic) | Google Fonts repo, 2026-11-03 | SIL OFL 1.1 (`assets/fonts/OFL.txt`). Display and verse text; covers Devanagari, Sanskrit conjuncts, and Latin. Bundled, not fetched, for offline use. UI body text uses the platform font (Roboto + system Noto Devanagari) | approved |
| D-120 | Hand-written JSON parsing (no `json_serializable` / `freezed`) | -- | Avoids `build_runner` codegen; gives errors with file and JSON path; parser is pure Dart so `tool/validate_content.dart` reuses it. Schema documented in `docs/CONTENT_SCHEMA.md` | approved |
| D-121 | Content validator in CI | -- | `dart run tool/validate_content.dart` runs on every push; `--release` gate rejects sample, placeholder, and unapproved content | approved |
| D-122 | Krishna complexion | -- | Soft blue with a lavender undertone, as generated consistently across all seven Krishna references; replaces "deep blue-black" in prompts v001 | approved |
| D-123 | Chariot banner mark | -- | Small glyph-like mark on the banner in both chariot references is kept as-is (reference use only). Production art must not reproduce it | approved |
| D-124 | Reference images in Git | -- | Approved Milestone 4 references (~47 MB, 20 PNGs) committed directly; revisit Git LFS or external storage before production media grows | approved |
| D-125 | Scene 5 without a separate Krishna layer | -- | ChatGPT re-rendered the whole poster, so a difference cut-out failed; `rembg`/`onnxruntime` crashes on the installed Python 3.14. Scene 5 uses the poster as its background; aura and particles draw on top. Feather animation needs a Krishna layer: revisit with a Python 3.12 environment or a manual cut-out | approved |
| D-126 | Flow videos held back | -- | All three Flow clips carry the visible Veo watermark and the Scene 1 clip does not loop. Videos stay `draft` until regenerated on a plan without the visible watermark, or a watermark-removal decision is recorded after checking Google's terms | approved |
| D-127 | `video_player` ^2.14.1 | -- | Platform-native playback (ExoPlayer on Android), roadmap §3. Wrapped behind `ScenePlayer` so tests use a fake and the backend can change | approved |
| D-128 | Temporary videos in the app | -- | Owner chose to ship current Flow clips into `assets/videos/` now (watermark, scene 1 not seamless) and replace them later; supersedes the hold in D-126. Marked `notes_temporary` in the manifest | approved |
| D-129 | Motion system design | -- | One repeating 20 s AnimationController per layered scene drives all effects (stops when off-screen via TickerMode; does not run with reduced motion). Effects are CustomPainters with cached shaders and pre-generated particle data (no per-frame allocation). Anchors map through a BoxFit.cover rect so effects stay on the art. Feather effect is a glint until a Krishna layer exists (D-125) | approved |
| D-130 | Dialogue labels | -- | Every dialogue line shows its kind (Retelling, Narration, Paraphrase of BG.x.y, Translation of BG.x.y); verse-derived lines use a blue badge and upright text, creative lines italic | approved |
| D-131 | Renderer contract | -- | `SceneRenderer.forScene` maps each scene to `CinematicSceneRenderer`, `LayeredMotionRenderer`, or `MangaPanelRenderer`; renderers get the parsed `Scene` and an asset-path map, never JSON. Manga reveals one line per tap, then the next panel; narration renders as a caption box, speech as a bubble, both with kind labels | approved |
| D-132 | Review status always visible | -- | Verse and translation review badges show in every build (not only internal builds) until `published`, so unreviewed text can never pass as approved | approved |
| D-133 | Reviewer step skipped for now | -- | Owner chose to build Milestone 9 without a scripture reviewer. The app still ships no generated scripture: verse text is added only from a named source into `assets/content/shlokas/`, stays `draft`, shows the Draft badge, and the `--release` gate keeps rejecting it until reviewed | approved |
| D-134 | Language fallback | -- | Translation in the chosen language if it has text; else the other UI language with a "not available yet" note; else a pending placeholder. Sanskrit is always shown | approved |
| D-135 | Wide-screen reader | -- | When the reader is wider than 0.8 (width/height), scene art is shown whole in a centred 9:16 column over a blurred, darkened copy of itself; dialogue and captions are capped at 600 dp. Phones and portrait tablets keep full-bleed art. Effects stay aligned because cover equals contain inside the column. Checked on Mi Pad 7 (2136x3200) | approved |
| D-136 | `shared_preferences` ^2.5.6 for user data | -- | Settings, reading progress, and bookmarks are small; SharedPreferences avoids Drift's build_runner codegen (roadmap allows this for the MVP). JSON values under versioned keys (`v1.*`) with a `user_data_version` key and a migrate step at startup; corrupt values fall back to defaults. Revisit Drift when download metadata needs queries (Milestone 11) | approved |
| D-137 | Text size | -- | No in-app text-size setting: the app follows the system font scale (tested at 2x). Revisit after beta feedback | approved |
| D-138 | Ambient sound preference deferred | -- | No audio exists yet; the sound setting arrives with Milestone 13 | approved |
| D-139 | Chapter media packs: own platform channel over `com.google.android.play:asset-delivery` 2.3.0 | -- | One on-demand Play asset pack per chapter (Gradle module `android/chapter_NN`, pack name = chapter ID). A small Kotlin `AssetPackChannel` (method + event channel) instead of a pub.dev plugin: the Flutter PAD plugins are thinly maintained, and we need only fetch/state/remove/confirm/free space. Dart side is `AssetPackService` with Play, unsupported, and fake implementations. Chapter 1 stays bundled as the always-available sample; chapter 2 media moved into pack `chapter_02` as the working proof. Media paths are `assets/...` (bundle) or absolute files (installed pack). Download is blocked when free space < pack size + 20 MB; Play's cellular-confirmation dialog is shown only for a download the user started | approved |
| D-140 | No Drift for download metadata | -- | Play stores pack state itself, so the app keeps no download database; D-136 (SharedPreferences) stands | approved |
| D-142 | `integration_test` and `flutter_driver` (dev, Flutter SDK) | -- | On-device flow test and frame-timing (`watchPerformance`) for Milestone 14; part of the SDK, no third-party code. Results in `docs/QA_REPORT.md` | approved |
| D-143 | No route restoration after process death | -- | After the OS kills the app in the background, it reopens at Home; "Continue reading" goes back to the exact scene. Full `RestorationScope` routing is not worth the complexity for the MVP. Revisit if beta users report it | approved |
| D-141 | Pack testing without Play Console | -- | Debug app bundle + `bundletool --local-testing` (`tool/install_with_packs.sh`) exercises the real Play Asset Delivery client against locally stored packs. Plain `flutter run` APKs carry no packs and show chapter 2 as "Download unavailable in this build". Internal app sharing / internal testing track waits for signing (Milestone 15) | approved |
| D-119 | In-memory settings | -- | Language, transliteration, and reduced-motion settings live in a Riverpod `Notifier` until persistence in Milestone 10. UI strings stay English until localization in Milestone 9 | approved |

------------------------------------------------------------------------

## Toolchain (recorded 2026-11-03)

| Tool | Version |
|------|---------|
| Flutter | 3.47.9 stable |
| Dart | 3.13.7 |
| Android SDK | platform android-37, build-tools 36.0.0 |
| JDK | Microsoft OpenJDK 17.0.21 |
| Git | 2.56.0 |
| FFmpeg | 9.0.2 |
| Test device | Redmi Note 7 Pro, Android 13 (API 33) |

------------------------------------------------------------------------

## Pending decisions (before public release)

- Logo and visual identity.
- Minimum supported Android version and device-performance target.
- Commentary, font, music, and artwork licensing.
- Narration/audio in first public release.
- Cloud backup or cross-device sync (later).
- Privacy policy, analytics, and crash-reporting choices.
- Play Store country availability and release strategy.

------------------------------------------------------------------------

## Change history

| Date | ID | Change | By |
|------|----|--------|----|
| 2026-11-03 | D-001--D-008 | Milestone 0 decisions recorded | Karan / Claude Code |
| 2026-11-03 | D-114--D-117 | Prompt 12a dependencies recorded | Claude Code |
| 2026-11-03 | D-118--D-119 | Prompt 12b font and settings decisions | Claude Code |
| 2026-11-03 | D-120--D-121 | Prompt 12c content schema and validator | Claude Code |
| 2026-11-03 | D-122--D-124 | Milestone 4 reference set accepted | Karan / Claude Code |
| 2026-11-04 | D-139--D-141 | Milestone 11 chapter media packs | Claude Code |
| 2026-11-04 | D-142--D-143 | Milestone 14 QA tooling and process-death behaviour | Claude Code |
