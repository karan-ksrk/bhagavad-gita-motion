# Release Guide

How to sign, build, test, and upload Moksharan. Decisions: D-144 to
D-148.

## 1. Create the upload key (once)

Play App Signing is used: Google keeps the app signing key, and you keep
only an **upload key**. If the upload key is lost, Play support can
reset it. Never commit it.

In PowerShell:

```powershell
keytool -genkeypair -v `
  -keystore "$env:USERPROFILE\.android\moksharan-upload.jks" `
  -alias upload -keyalg RSA -keysize 2048 -validity 10000 `
  -dname "CN=Karan, O=Moksharan, C=IN"
```

Choose a strong password when asked, and use the same one for the store
and the key.

Then copy `android/key.properties.example` to `android/key.properties`
(gitignored) and fill it in:

```properties
storeFile=C:/Users/Karan/.android/moksharan-upload.jks
storePassword=<your password>
keyAlias=upload
keyPassword=<your password>
```

**Back up** the `.jks` file and the password together, outside this
repo (a password manager, or an encrypted cloud folder). Check that
`git status` does not list either file.

Without `key.properties`, release outputs are **unsigned**. They are
never signed with the debug key. CI or other machines can point to the
file with the `MOKSHARAN_KEY_PROPERTIES` environment variable.

## 2. Before each release build

1. Increase `version:` in `pubspec.yaml` (`name+code`). The code after
   `+` must be higher than any build already uploaded to Play.
2. Run `dart run tool/validate_content.dart --release`. It must pass
   before a **public** release. Internal testing may ship sample
   content (it is labelled in the app).
3. Run `flutter analyze` and `flutter test`.

## 3. Build

```bash
flutter build appbundle --release
# -> build/app/outputs/bundle/release/app-release.aab
```

R8 shrinking is on. `android/app/proguard-rules.pro` keeps the
WorkManager database that Play Asset Delivery needs (D-145). Without it,
the release app crashes at startup.

## 4. Test the release build on a device

The local testing mode runs the real Play Asset Delivery client:

```bash
java -jar bundletool.jar build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=build/app/outputs/moksharan-release.apks --local-testing \
  --ks=C:/Users/Karan/.android/moksharan-upload.jks --ks-key-alias=upload
adb uninstall io.github.karan_ksrk.moksharan   # if a debug build is installed
java -jar bundletool.jar install-apks \
  --apks=build/app/outputs/moksharan-release.apks
```

Release smoke test:

- [ ] Cold start shows Home (no crash).
- [ ] Chapter 1 video plays, and swiping through the scenes works.
- [ ] Chapter 2: Download, then the panels and layered scene show.
- [ ] Bookmark a scene, then force-stop and reopen: the bookmark and
      "Continue reading" are kept.
- [ ] Settings, then Storage: remove chapter 2. Chapter 2 shows "Not
      downloaded".
- [ ] About shows the support contact; Open-source licenses opens.

Last run: 2026-11-04 on the Redmi Note 7 Pro with a throwaway test key.
All passed after the D-145 fix; cold start 1.2–1.3 s; download size on
that phone 17.0 MB.

## 5. Play Console (owner)

1. Create the app: name **Moksharan**, default language English (India),
   App (not Game), Free.
2. App signing: keep the default (Play App Signing) and upload the
   first AAB to **Internal testing**.
3. Add testers (an email list) and share the opt-in link.
4. Store listing: text in `docs/STORE_LISTING.md`, screenshots in
   `media-production/store/screenshots/`, icon and feature graphic
   (see `media-production/chatgpt-prompts/M15_app_icon_prompt.md`).
5. Privacy policy URL: Play needs a public URL. If the repo is public,
   the GitHub link to `docs/PRIVACY_POLICY.md` works; otherwise host the
   file anywhere public (D-147).
6. App content forms: use the answers below.
7. Target API: the app targets API 36 (Flutter 3.47 default). Check
   Play's current requirement in the Console before uploading.
8. New personal developer accounts need a **closed test with at least
   12 testers for 14 days** before production (Milestone 16).

### Data safety answers

| Question | Answer | Why |
|----------|--------|-----|
| Does the app collect or share user data? | **No** | Settings, progress, and bookmarks are stored only on the device (SharedPreferences). The app has no accounts, analytics, ads, or crash reporting, and its code makes no network calls |
| Is data encrypted in transit? | Not applicable (nothing is sent) | |
| Can users request deletion? | Not applicable. Users can clear progress in Settings, or clear app data or uninstall | |

Chapter downloads are delivered by the Google Play Store app through
Play Asset Delivery. The app talks to the Play Store app on the device
and does not send user data. Check Google's current guidance for Play
libraries before submitting.

Permissions in the release manifest all come from the Play Asset
Delivery library: `INTERNET`, `ACCESS_NETWORK_STATE`, `WAKE_LOCK`,
`FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_DATA_SYNC`,
`RECEIVE_BOOT_COMPLETED`. The app requests no runtime (dangerous)
permissions. If the Console asks about the data-sync foreground service,
its purpose is downloading chapter media that the user requested.

### Content rating (IARC) answers

- Category: Reference, News, or Educational.
- Violence: **No**. The battlefield is shown as assembled armies, with
  no combat, injury, or blood. Answer again if later scenes show
  fighting.
- Sexual content, profanity, drugs, gambling: **No**.
- User interaction, sharing of user content or location, digital
  purchases: **No**.

Expected result: Everyone / PEGI 3 or similar. This is not guaranteed.

### Target audience

Choose **13+** for the first release. Including children brings in
Google Play's Families policy requirements. Revisit after the content
is reviewed (owner decision, D-148).

## 6. Release blockers before a public (production) release

From `docs/RIGHTS_REVIEW.md` and the content validator:

- Real, reviewed verse text and translations replace the placeholders,
  and `validate_content --release` passes.
- Flow videos are replaced: no visible watermark (D-126, D-128).
- Every asset has `rights_status: cleared`.
- App icon and feature graphic are final.
