# QA Report: Milestone 14

Date: 2026-11-04. Build: `feat/m14-quality` (profile and debug builds;
release builds wait for signing, Milestone 15).

## Devices

| Device | Class | Android | Screen | Used for |
|--------|-------|---------|--------|----------|
| Redmi Note 7 Pro (Snapdragon 675, 4 GB) | mid-range (2019) | 13 | 1080x2340 | flows, lifecycle, performance |
| Xiaomi Mi Pad 7 | high-end tablet | 16 | 2136x3200 | performance, wide-screen layout (D-135) |

No low-memory device was available. See open items.

## Automated tests

| Suite | Count | Where |
|-------|-------|-------|
| Unit and widget tests | 189 | `flutter test` |
| On-device flow | 1 long flow | `integration_test/app_flow_test.dart` |
| Frame timing | 2 scenarios | `integration_test/perf_test.dart` with `test_driver/perf_driver.dart` |

Run the on-device tests:

```bash
flutter test integration_test/app_flow_test.dart -d <device>
flutter drive --no-dds --profile --driver=test_driver/perf_driver.dart \
  --target=integration_test/perf_test.dart -d <device>
```

Both clear the app's settings, progress, and bookmarks on the device,
and `flutter drive` uninstalls the app afterwards. `--no-dds` is needed
over wireless adb.

The on-device flow: Home, Chapters, Chapter 1, reader with the real video
player, all three scenes, a scene bookmark, manga dialogue taps, resume
from Home, Hindi UI language, then the chapter 2 layered scene with
effects. It passes on the Redmi Note 7 Pro.

Accessibility tests run on all 11 screens (`/`, `/chapters`,
`/chapters/1`, `/chapters/2`, `/read/1`, `/read/2`, `/shloka/BG.2.47`,
`/bookmarks`, `/settings`, `/storage`, `/about`). Each screen is checked
at 2x text with no overflow, against the Android 48 dp touch-target and
labelled-target guidelines, and against the text-contrast guideline.

## Defects found and fixed

| ID | Severity | Defect | Fix | Test |
|----|----------|--------|-----|------|
| QA-1 | High (accessibility) | Manga scenes triggered a framework semantics assertion (`'!child.attached'`) on device while panel images faded in and out. A screen reader could get a corrupted tree. | Panel alt text moved outside the `AnimatedSwitcher`; the switching images are excluded from semantics | On-device flow (widget tests could not reproduce it) |
| QA-2 | Medium | At 2x text, the manga footer ("Panel 1 / 3 · Tap to continue") overflowed by 198 px | The text wraps (`Expanded`, end-aligned) | `/read/2 renders at 2x text scale` |
| QA-3 | Medium | Opening one chapter's reader straight from another reused the old page index (chapter 2 opened on chapter 1's last page, with no Next button) | Scene pager keyed by chapter and requested scene | `going from one chapter reader to another starts fresh` |

## Lifecycle (Redmi Note 7 Pro, profile build)

| Check | Result |
|-------|--------|
| Background on a playing video, then foreground | Pass. CPU 19% in the foreground, 0.0% in the background (video paused). The video plays again on return |
| Screen off (sleep) | Pass. CPU 0.0% while locked |
| Unlock and resume | Not separately checked: the phone stays on its secure lock screen over adb. Resume uses the same lifecycle path as background/foreground |
| Process death in background (`am kill`), relaunch | Pass with a note. The app opens at Home, not the reader, but "Continue reading" points to the exact scene. Route restoration is not implemented (D-143) |
| Re-install keeps user data | Pass |
| Rotation and wide screens | Landscape tablet layout was checked on the Mi Pad 7 in D-135 and is covered by `scene_art_frame_test`. Not re-run this round: MIUI asks for an on-tablet tap for each adb install |

## Performance

Cold start (`am start -W`, TotalTime, 3 runs, profile build):

| Device | Runs (ms) |
|--------|-----------|
| Redmi Note 7 Pro | 1778, 1710, 1619 |
| Mi Pad 7 | 790, 888, 906 |

Frame timing (`watchPerformance`, profile; budget 16 ms):

| Scenario | Device | Frames | Build avg / p99 (ms) | Raster avg / p99 (ms) | Missed raster |
|----------|--------|--------|----------------------|-----------------------|---------------|
| Chapter 1: entry, 2 swipes, 4 manga taps | Redmi | 411 | 0.49 / 5.2 | 4.0 / 17.1 | 6 (1.5%) |
| Chapter 1 | Mi Pad 7 | 418 | 0.63 / 6.3 | 5.4 / 18.7 | 8 (1.9%) |
| Layered effects, 8 s | Redmi | 240 | 0.86 / 1.1 | 4.3 / 7.8 | 1 |
| Layered effects, 8 s | Mi Pad 7 | 240 | 2.8 / 4.4 | 7.7 / 10.0 | 0 |

Missed frames in chapter 1 come during scene changes, when a video
decoder starts. On device, the layered scene ran without its background
image (plain APKs carry no pack, D-141), so its raster times are a lower
bound. GC: 22–26 new-gen and 4 old-gen in the chapter 1 scenario.

Memory (Redmi, `dumpsys meminfo`, total PSS): 167 MB on chapter detail,
210 MB in the reader with video playing (73 MB graphics).

Size (profile build, an upper bound for release):

| Item | Size |
|------|------|
| arm64-v8a APK | 38.7 MB (armeabi-v7a 36.4 MB, x86_64 40.2 MB) |
| `libflutter.so` / `libapp.so` (arm64, profile) | 12.6 MB / 8.9 MB |
| Bundled media and fonts | 8.6 MB |
| Chapter 2 pack | 1.06 MB |

Image decode: panels and posters are 864x1536 WebP, about 5.3 MB each
when decoded. At most two panel images are decoded at once (during a
panel transition), plus a blurred backdrop on wide screens. No change
needed now.

## Accessibility notes

- Every reader control is a labelled button (tooltip read by TalkBack).
  The manga scene is one "Next" or "Restart panels" button, with panel
  alt text as an image label.
- Dialogue kind is shown as text (Retelling, Narration, Translation of
  BG.x.y), not only by colour.
- Reduced motion is covered by existing tests: no autoplay, no effects,
  no transitions.
- Captions and transcripts: not applicable, since there is no narration
  (Milestone 13 not started).
- The contrast guideline cannot measure text over artwork in widget
  tests (images do not decode there). Dialogue sits on opaque cards or
  scrims.

## Network and permissions

- App code makes no network calls. All content is bundled or comes from
  Play asset packs.
- The Play Asset Delivery library adds `INTERNET`,
  `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, `FOREGROUND_SERVICE`,
  `FOREGROUND_SERVICE_DATA_SYNC`, and `RECEIVE_BOOT_COMPLETED` to the
  merged manifest. Declare these in the Play data-safety form
  (Milestone 15).

## Open items

| Item | Why open |
|------|----------|
| Low-memory device (2–3 GB, Android Go) | No device available. Borrow one or use a Play pre-launch report |
| Incoming call / audio focus | The app has no audio (videos are muted, audio stripped). Re-test with Milestone 13 |
| Airplane-mode run on device | Turning radios off drops wireless adb. Needs a manual check (open chapters 1 and 2 offline) |
| Battery usage | Needs a longer session with Battery Historian. Do it during beta |
| Full TalkBack walkthrough | Automated label and target checks pass. Do a manual pass with TalkBack on before beta |
| Release-build size and startup | Wait for signing (Milestone 15) |

## Acceptance criteria

- No known critical crashes: met. All three defects found were fixed.
- No blocker-level defects: met.
- Reader works with motion disabled: met (tests).
- Performance acceptable on the target matrix: met for the two devices
  tested. A low-end device is still needed before the device matrix is
  final.
