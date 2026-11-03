# Content Schema (v1)

All app content is JSON under `assets/content/`. The Dart parser
(`lib/data/models/content_parser.dart`) is the schema of record; this
document describes it. Every file carries `"schema_version": 1`. A file
with a newer version is rejected with an "update the app" error.

Unknown keys (such as `_comment`) are ignored. Optional text fields use
`null`, never an empty string.

## Validate

```bash
dart run tool/validate_content.dart            # development rules (CI)
dart run tool/validate_content.dart --release  # release gate
```

Development mode allows sample and placeholder content. Release mode
rejects anything sample, placeholder, unreviewed, or unapproved.

## Files

| File | Contents |
|------|----------|
| `manifest.json` | Chapter list and paths to every other file |
| `chapters/chapter_NN.json` | Scenes for one chapter |
| `shlokas/chapter_NN.json` | Verse records for one chapter |
| `media_manifest.json` | Every media asset; paths relative to `assets/` |
| `sources.json` | Sanskrit editions, translations, original-content sources |

## Enumerations

| Field | Values |
|-------|--------|
| `text_status` | `draft`, `source_verified`, `translation_reviewed`, `linguistically_reviewed`, `scripture_approved`, `published` |
| `asset_status` | `draft`, `continuity_approved`, `processed`, `approved` |
| `rights_status` | `pending`, `cleared` |
| `renderer` | `cinematic`, `layered_motion`, `manga_panel` |
| `dialogue_type` | `creative`, `narration`, `verse_paraphrase`, `verse_translation` |
| `speaker_id` | `krishna`, `arjuna`, `sanjaya`, `dhritarashtra`, `narrator` |
| effect `type` | `golden_aura`, `floating_particles`, `peacock_feather`, `background_drift` |
| `reduced_motion` | `static` (default), `hide` |
| panel `transition` | `none`, `fade` (default), `slide` |
| `media_type` | `image`, `video`, `audio` |
| source `kind` | `sanskrit_edition`, `translation`, `original` |
| translation `language` | `hi`, `en` |

Localized text is an object `{ "hi": string|null, "en": string|null }`.

## manifest.json

```json
{
  "schema_version": 1,
  "chapters": [
    {
      "chapter_id": "chapter_01",
      "number": 1,
      "title": null,
      "summary": null,
      "text_status": "draft",
      "sample": true,
      "scenes_file": "chapters/chapter_01.json"
    }
  ],
  "shloka_files": ["shlokas/chapter_01.json"],
  "media_manifest": "media_manifest.json",
  "sources": "sources.json"
}
```

## Scene (in chapters/chapter_NN.json)

| Field | Required | Notes |
|-------|----------|-------|
| `scene_id` | yes | `chNN_scene_NNN`, chapter must match |
| `order` | yes | Unique within the chapter |
| `title` | yes | Localized text |
| `renderer` | yes | See enumerations |
| `media` | per renderer | `poster`, `video`, `background`, `layers[]`: asset IDs |
| `effects` | no | See below |
| `dialogues` | no | Scene-level lines |
| `panels` | manga only | See below |
| `shloka_refs` | no | Verse IDs; each must exist |
| `read_time_seconds` | no | Positive integer |

Renderer requirements: `cinematic` needs `poster` and `video`;
`layered_motion` needs `background`; `manga_panel` needs at least one
panel.

### Effect

```json
{
  "effect_id": "aura_1",
  "type": "golden_aura",
  "enabled": true,
  "anchor": { "x": 0.52, "y": 0.34 },
  "scale": 0.4,
  "intensity": 0.6,
  "reduced_motion": "static"
}
```

`anchor` is normalized (0--1) to the artwork frame. `scale` is 0.01--2;
`intensity` is 0--1.

### Dialogue

```json
{
  "dialogue_id": "ch01_s001_d001",
  "speaker_id": "narrator",
  "dialogue_type": "verse_paraphrase",
  "source_ref": "BG.1.1",
  "text": { "hi": "...", "en": "..." },
  "reveal_order": 1,
  "text_status": "draft"
}
```

- `dialogue_id` is unique across all content.
- `reveal_order` is unique within its scene or panel.
- `verse_paraphrase` and `verse_translation` require `source_ref`.
- Text needs at least one language; release needs both.

### Panel

`panel_id`, `order`, `image` (image asset ID), `alt_text` (localized,
at least one language), optional `transition` and `dialogues`.

## Shloka (in shlokas/chapter_NN.json)

```json
{
  "verse_id": "BG.1.1",
  "chapter": 1,
  "verse": 1,
  "placeholder": true,
  "sanskrit": null,
  "transliteration": null,
  "source_id": "gita_press_700",
  "text_status": "draft",
  "reviewed_by": null,
  "reviewed_on": null,
  "translations": [
    { "language": "en", "text": null, "source_id": "telang_1882", "text_status": "draft" }
  ],
  "word_meanings": []
}
```

- `verse_id` must equal `BG.<chapter>.<verse>`.
- `source_id` must be a `sanskrit_edition` source.
- `placeholder: true` verses stay `draft` and cannot ship.
- Non-placeholder verses need `sanskrit`.
- `scripture_approved` or `published` needs `reviewed_by` and
  `reviewed_on`, on the verse and on each translation.
- A translation with `text: null` must stay `draft`.

## Media asset (in media_manifest.json)

| Field | Required | Notes |
|-------|----------|-------|
| `asset_id` | yes | Unique |
| `path` | yes | Relative to `assets/`; lowercase snake_case; extension matches type |
| `media_type` | yes | |
| `source_tool` | yes | e.g. `chatgpt`, `google_flow` |
| `asset_status`, `rights_status` | yes | |
| `width`, `height` | approved image/video | |
| `duration_ms` | approved video/audio | |
| `checksum_sha256` | approved | |
| `size_bytes`, `codec`, `prompt_id`, `character_refs` | no | |

A missing file is a warning for `draft` / `continuity_approved` and an
error for `processed` / `approved`. Approved assets need
`rights_status: cleared`.

## Source (in sources.json)

`source_id`, `kind`, `title`, `license` required; `author`, `year`,
`decision_ref` (`D-NNN`), `notes` optional.
