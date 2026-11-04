# Rights and Licence Review

Date: 2026-11-04. A working checklist prepared during development, not
legal advice. Get qualified advice before a public release if anything
below is uncertain.

Status: ✅ clear · ⚠️ action needed · ⛔ blocks public release

## Text

| Item | Source | Status | Notes |
|------|--------|--------|-------|
| Sanskrit verses | Traditional text, Gita Press Gorakhpur numbering (D-003) | ⚠️ | The ancient text is public domain. A **specific digital edition** can carry its own copyright in edits and typography. Choose a public-domain or openly licensed digital source, record it in `sources.json`, and keep the source shown on the verse screen. Placeholders only for now |
| English translation | K. T. Telang, *The Bhagavadgita*, Sacred Books of the East vol. 8, 1882 (D-004) | ✅ | Published 1882; author died 1893. Public domain. Copy from a scan of the original, not a modern re-edition with new notes |
| Hindi explanations | Written for the app (D-005) | ⚠️ | Original work, so no third-party rights, but it must be reviewed before release (D-133). Not written yet |
| Creative dialogue | Written for the app | ✅ | Labelled "Retelling" in the app (D-130) |
| Word meanings, commentary | None used | ✅ | Do not add any without a recorded source and licence |

## Fonts

| Item | Status | Notes |
|------|--------|-------|
| Tiro Devanagari Sanskrit | ✅ | SIL OFL 1.1. Licence bundled (`assets/fonts/OFL.txt`) and shown on the in-app Open-source licenses page. Not sold separately (OFL condition met) |
| Platform fonts (Roboto, Noto) | ✅ | System fonts, not bundled |

## Software

| Item | Status | Notes |
|------|--------|-------|
| Flutter and Dart packages | ✅ | BSD/MIT/Apache. Notices shown automatically on the in-app licenses page |
| Play Asset Delivery, AndroidX | ✅ | Apache 2.0 / Play Core terms. Included in the licenses page via Gradle metadata where provided |

## Artwork and video

| Item | Tool | Status | Notes |
|------|------|--------|-------|
| Character references, posters, panels | ChatGPT image generation | ⚠️ | OpenAI's terms assign output rights to the user, subject to the usage policies. Check: no recognisable living person or third-party artwork or trademark; the banner mark in the chariot references is not reproduced (D-123). Then set `rights_status: cleared` per asset in `media_manifest.json` |
| Scene video clips | Google Flow (Veo) | ⛔ | Visible Veo watermark (D-126). Shipped as temporary (D-128). Before public release: regenerate without the visible watermark on a plan that allows it, and confirm commercial use is permitted under the Google terms for that plan. Do not remove watermarks by editing |
| AI disclosure | -- | ✅ | The About screen states the artwork and motion tools. Keep it |

## Audio

None in the app (Milestone 13 not started). ✅

## Store and policy

| Item | Status | Notes |
|------|--------|-------|
| Religious content portrayal | ✅ | Dignified portrayal (CLAUDE.md, CHARACTER_BIBLE). Avoid claims of official endorsement by any institution, including Gita Press |
| Trademarks in the listing | ✅ | No third-party names or logos in the icon or title |
| Play AI-generated content policy | ✅ | The app does not generate AI content for users; static media only |
| Privacy | ✅ | No data collected (`docs/PRIVACY_POLICY.md`, D-146) |

## Before public release

- [ ] Digital Sanskrit source chosen and recorded.
- [ ] Verses and translations entered and reviewed;
      `validate_content --release` passes.
- [ ] Videos regenerated without the visible watermark; terms checked.
- [ ] Every media asset `rights_status: cleared`.
