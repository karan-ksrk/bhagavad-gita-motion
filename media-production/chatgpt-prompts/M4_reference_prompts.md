# Milestone 4: Reference Art Prompts (ChatGPT image generation)

Version: v002 (2026-11-03). Copy prompts exactly; record any change as a
new version in the log at the bottom.

v002: Krishna complexion text updated to match the approved reference
set (soft lavender-blue; v001 said deep blue-black). D-122.

## How to use

1. Start a **new ChatGPT chat** per character so earlier images do not
   bleed in.
2. Paste the **Style block** first, then the prompt. (Or paste both in one
   message.)
3. Generate the **master** first (`KR-01`, `AR-01`, `ENV-01`). Regenerate
   until it is right. Do not move on with a weak master.
4. For every other prompt of that character: **attach the approved master
   image** and keep the "Reference" line at the top of the prompt.
5. Check every result against the checklist at the end. Reject and
   regenerate rather than accept drift.
6. Save approved images to `media-production/character-references/`
   (characters) or `media-production/environment-references/`
   (environments) using the file name in each prompt. Rejects go to
   `media-production/review/`.
7. Fill in the log at the bottom (date, prompt ID, file, approved yes/no).

Image size: choose **portrait (1024x1536, 2:3)** unless the prompt says
otherwise. The app frame is 9:16; posters are cropped or extended later.

------------------------------------------------------------------------

## Style block (paste with every prompt)

```text
STYLE: Cinematic Indian mythological painting, rich and detailed, in the
spirit of classical Indian devotional art reimagined as a modern film
still. Painterly realism, soft volumetric light, fine ornament detail.
Palette: deep midnight blue and charcoal shadows, antique gold
highlights, celestial blue rim light, warm ivory tones. Calm, reverent,
dignified mood. Restrained composition, not busy.

RULES:
- Absolutely no text, letters, numbers, script, symbols, watermarks,
  signatures, or writing anywhere in the image, including on banners,
  clothing, and jewellery.
- No cartoon, anime, chibi, or video-game styling. No exaggerated
  muscles. No gore or violence. Modest, respectful portrayal.
- Anatomically correct hands with five fingers.
- Plain or softly blurred background unless the prompt describes one.
```

------------------------------------------------------------------------

## Character definitions (keep identical across all prompts)

These lines are already inside each prompt. Do not edit them per prompt;
if a design change is needed, change it here and bump the version.

**Krishna:** youthful, serene man in his twenties; soft blue
complexion with a cool lavender undertone and a gentle natural sheen
(match the approved `krishna_master_v001.png`; v002 change, D-122); gentle almond eyes with a
calm, compassionate expression and a faint smile; long dark wavy hair
falling past the shoulders; a golden crown (mukut) with one upright
peacock feather tucked at the front-left; yellow silk dhoti (pitambara)
with a thin gold border; light gold upper scarf (angavastram) draped
over one shoulder; a long garland of small forest flowers (vaijayanti
mala); a single red-gold gem pendant on the chest; slim gold armlets,
bracelets, and earrings; slender, graceful build.

**Arjuna:** young warrior prince in his twenties; warm wheatish
complexion; strong but natural build; short dark beard and moustache,
neatly kept; long dark hair tied back under a gold-and-bronze warrior
crown; deep maroon and gold armour over a white silk garment; a quiver
of arrows on his back; carries a tall, elegant recurve bow (Gandiva)
with gold fittings; arm guards and a waist sash; expression varies per
prompt.

------------------------------------------------------------------------

## Krishna

### KR-01 Master portrait
File: `krishna_master_v001.png`

```text
[Style block]

Portrait of Krishna, head and upper chest, facing the viewer directly,
eyes looking at the viewer. Krishna: youthful, serene man in his
twenties; soft blue complexion with a cool lavender undertone and a
gentle natural sheen;
gentle almond eyes with a calm, compassionate expression and a faint
smile; long dark wavy hair falling past the shoulders; a golden crown
(mukut) with one upright peacock feather tucked at the front-left;
light gold upper scarf over one shoulder; a long garland of small
forest flowers; a single red-gold gem pendant on the chest; slim gold
earrings. Soft golden light from the upper left, faint celestial blue
rim light. Plain deep midnight blue background with a subtle warm glow
behind the head. Character centred in the upper two-thirds of the
frame; lower third empty dark background.
```

### KR-02 Three-quarter portrait
File: `krishna_threequarter_v001.png`

```text
Reference: use the attached image as the exact character reference.
Keep the same face, complexion, crown, peacock feather position,
jewellery, and clothing. Change only the angle.

[Style block]

Krishna, head and shoulders, turned three-quarters to the left, eyes
looking slightly past the viewer. Same lighting and background as the
reference. Character in the upper two-thirds; lower third empty.
```

### KR-03 Side profile
File: `krishna_profile_v001.png`

```text
Reference: use the attached image as the exact character reference.
Keep the same face, complexion, crown, peacock feather position,
jewellery, and clothing. Change only the angle.

[Style block]

Krishna in clean side profile facing left, head and shoulders. The
peacock feather and crown clearly visible in silhouette. Same lighting
and background. Character in the upper two-thirds; lower third empty.
```

### KR-04 Full-body standing
File: `krishna_fullbody_v001.png`

```text
Reference: use the attached image as the exact character reference.
Keep the same face, complexion, crown, peacock feather, jewellery.

[Style block]

Full-body view of Krishna standing upright in a relaxed, graceful pose,
weight slightly on one leg, arms relaxed at his sides, facing the
viewer. Yellow silk dhoti (pitambara) with a thin gold border, light
gold upper scarf, long flower garland reaching the knees, gold armlets
and bracelets, bare feet. Plain midnight blue background, soft floor
shadow. Whole figure visible head to toe with margin around it.
```

### KR-05 Seated as charioteer
File: `krishna_chariot_seat_v001.png`

```text
Reference: use the attached image as the exact character reference.
Keep the same face, complexion, crown, peacock feather, jewellery, and
clothing.

[Style block]

Krishna seated at the front of an ornate wooden-and-gold war chariot as
its charioteer, holding the horses' reins loosely in both hands, body
facing forward, head turned slightly back over his right shoulder as if
about to speak to someone behind him. Calm, composed posture. Chariot
detail simple and blurred; background a softly blurred dusty plain at
golden hour. Character in the upper two-thirds; lower third chariot
front and soft dust.
```

### KR-06 Expression sheet
File: `krishna_expressions_v001.png`
Size: square (1024x1024).

```text
Reference: use the attached image as the exact character reference.
Same face, complexion, crown, peacock feather, jewellery.

[Style block]

Character expression sheet of Krishna: three head-and-shoulders
portraits side by side on a plain midnight blue background, identical
lighting. Left: calm and serene, mouth closed. Centre: speaking gently,
lips slightly parted, one eyebrow subtly raised as if explaining.
Right: deeply compassionate, soft eyes, faint reassuring smile. No
labels or text.
```

### KR-07 Crown and feather detail
File: `krishna_crown_detail_v001.png`
Size: square (1024x1024).

```text
Reference: use the attached image as the exact character reference.

[Style block]

Close-up detail study of Krishna's golden crown (mukut) and the single
peacock feather tucked at its front-left, seen from a slight
three-quarter angle. Show the crown's gold filigree, small gems, and
the feather's eye clearly. Hair edge and forehead visible at the bottom
of the frame. Plain dark background.
```

------------------------------------------------------------------------

## Arjuna

### AR-01 Master portrait
File: `arjuna_master_v001.png`

```text
[Style block]

Portrait of Arjuna, head and upper chest, facing the viewer directly.
Arjuna: young warrior prince in his twenties; warm wheatish complexion;
strong but natural build; short dark beard and moustache, neatly kept;
long dark hair tied back under a gold-and-bronze warrior crown; deep
maroon and gold armour over a white silk garment; a quiver strap
crossing the chest. Steady, thoughtful expression. Soft golden light
from the upper right, faint celestial blue rim light. Plain deep
midnight blue background. Character in the upper two-thirds; lower
third empty dark background.
```

### AR-02 Three-quarter portrait
File: `arjuna_threequarter_v001.png`

```text
Reference: use the attached image as the exact character reference.
Keep the same face, complexion, beard, crown, armour. Change only the
angle.

[Style block]

Arjuna, head and shoulders, turned three-quarters to the right, eyes
looking slightly past the viewer. Same lighting and background.
Character in the upper two-thirds; lower third empty.
```

### AR-03 Side profile
File: `arjuna_profile_v001.png`

```text
Reference: use the attached image as the exact character reference.
Keep the same face, complexion, beard, crown, armour. Change only the
angle.

[Style block]

Arjuna in clean side profile facing right, head and shoulders, crown
and quiver strap visible. Same lighting and background. Character in
the upper two-thirds; lower third empty.
```

### AR-04 Full-body warrior
File: `arjuna_fullbody_v001.png`

```text
Reference: use the attached image as the exact character reference.
Keep the same face, complexion, beard, crown, armour.

[Style block]

Full-body view of Arjuna standing upright, holding a tall elegant
recurve bow (Gandiva) with gold fittings vertically in his left hand,
the bow's lower tip resting on the ground, quiver of arrows on his
back, arm guards, waist sash, maroon and gold armour over white silk.
Dignified, ready posture, not aggressive. Plain midnight blue
background, soft floor shadow. Whole figure visible head to toe with
margin around it.
```

### AR-05 Seated in chariot
File: `arjuna_chariot_seat_v001.png`

```text
Reference: use the attached image as the exact character reference.
Keep the same face, complexion, beard, crown, armour.

[Style block]

Arjuna seated on the raised rear platform of an ornate war chariot, bow
resting across his knees, looking forward over the charioteer's
position. Chariot detail simple and blurred; background a softly
blurred dusty plain at golden hour. Character in the upper two-thirds.
```

### AR-06 Expression sheet
File: `arjuna_expressions_v001.png`
Size: square (1024x1024).

```text
Reference: use the attached image as the exact character reference.
Same face, complexion, beard, crown, armour.

[Style block]

Character expression sheet of Arjuna: three head-and-shoulders
portraits side by side on a plain midnight blue background, identical
lighting. Left: distressed and sorrowful, brows drawn together, eyes
lowered, on the verge of tears (dignified, not melodramatic). Centre:
listening intently, head slightly tilted, eyes attentive. Right:
focused and resolved, steady gaze, calm determination. No labels or
text.
```

------------------------------------------------------------------------

## Environments

### ENV-01 Chariot (master)
File: `chariot_master_v001.png`
Size: landscape (1536x1024).

```text
[Style block]

An ornate ancient Indian war chariot seen from a three-quarter front
angle, no people. Two large spoked wooden wheels with gold fittings, a
carved wooden body with gold ornament, a raised rear platform for the
warrior and a front seat for the charioteer. Four pure white horses in
gold-trimmed harness. A tall flagpole at the rear with a plain
saffron banner bearing a simple stylised monkey emblem (no text,
no letters). Standing on a dusty plain under a golden-hour sky. Calm
mood, not in motion.
```

### ENV-02 Chariot seat positions
File: `chariot_seats_v001.png`
Size: landscape (1536x1024).

```text
Reference: use the attached image as the exact chariot reference. Keep
the same chariot design, colours, and ornament.

[Style block]

Side view of the same chariot, no people, showing clearly the
charioteer's seat at the front and the raised warrior's platform at the
rear, with the distance between them. Neutral soft light, plain softly
blurred background.
```

### ENV-03 Kurukshetra wide battlefield
File: `kurukshetra_master_v001.png`

```text
[Style block]

Vast open plain of Kurukshetra at dawn, seen from a slightly elevated
viewpoint. Two great armies assembled far apart on either side,
rendered as distant masses of soldiers, elephants, chariots, and many
plain coloured flags with no text or symbols. Fine dust hanging in the
air. Wide empty ground in the centre between the armies. Sky of
celestial blue fading to warm gold at the horizon. Upper half sky,
lower half plain; the bottom third mostly empty ground for text
overlays. No battle, no violence; a moment of stillness before.
```

### ENV-04 Kurukshetra sunrise
File: `kurukshetra_sunrise_v001.png`

```text
Reference: use the attached image as the exact location reference.
Keep the same landscape layout and armies.

[Style block]

The same battlefield at sunrise: low warm sun on the horizon, long
golden light across the dust, deep blue shadows. Bottom third mostly
empty ground.
```

### ENV-05 Kurukshetra sunset
File: `kurukshetra_sunset_v001.png`

```text
Reference: use the attached image as the exact location reference.
Keep the same landscape layout and armies.

[Style block]

The same battlefield at sunset: amber and rose sky, sun low behind the
far army, silhouetted flags, cooler midnight blue creeping into the
foreground. Bottom third mostly empty ground.
```

### ENV-06 Sky and cloud plates
File: `sky_plates_v001.png`
Size: square (1024x1024).

```text
[Style block]

Sheet of four sky studies in a 2x2 grid, no land, no text: (1) clear
dawn celestial blue to gold, (2) scattered soft clouds at midday,
(3) dramatic golden-hour clouds, (4) deep twilight midnight blue with
first stars. Matching painterly style.
```

### ENV-07 Celestial background (for later divine scenes)
File: `celestial_master_v001.png`

```text
[Style block]

Abstract celestial space: deep midnight blue cosmos with soft nebula
clouds in celestial blue and antique gold, gentle radiant light from
the centre, faint scattered stars. Calm and vast, not busy. No figures,
no symbols, no text. Bottom third darker and calmer for text overlays.
```

------------------------------------------------------------------------

## Review checklist (every image)

- [ ] No text, letters, numbers, or pseudo-script anywhere (zoom in on
      banners, borders, and jewellery).
- [ ] Face matches the master (shape, eyes, complexion).
- [ ] Krishna: lavender-blue complexion, crown, feather at front-left,
      yellow dhoti, garland, gem pendant.
- [ ] Arjuna: beard, crown, maroon-gold armour, bow and quiver where
      required.
- [ ] Hands: five fingers, natural grip.
- [ ] Jewellery and clothing consistent with the master.
- [ ] Bottom third clear of faces and key detail (portrait images).
- [ ] Palette: midnight blue, antique gold, celestial blue, ivory.
- [ ] Dignified, respectful portrayal; nothing cartoonish or violent.

When the full set passes, send it to the cultural/devotional reviewer
(D-007) before Milestone 5.

------------------------------------------------------------------------

## Generation log

| Date | Prompt ID | File | Approved | Notes |
|------|-----------|------|----------|-------|
| 2026-11-03 | KR-01 | krishna_master_v001.png | yes | Complexion lavender-blue; accepted as canonical (D-122) |
| 2026-11-03 | KR-02 | krishna_threequarter_v001.png | yes | |
| 2026-11-03 | KR-03 | krishna_profile_v001.png | yes | Faces left |
| 2026-11-03 | KR-04 | krishna_fullbody_v001.png | yes | |
| 2026-11-03 | KR-05 | krishna_chariot_seat_v001.png | yes | Head turned sideways rather than back over shoulder |
| 2026-11-03 | KR-06 | krishna_expressions_v001.png | yes | Compassionate panel close to calm; regenerate if a clearer difference is needed |
| 2026-11-03 | KR-07 | krishna_crown_detail_v001.png | yes | Landscape, not square |
| 2026-11-03 | AR-01 | arjuna_master_v001.png | yes | Armour reads bronze-gold; maroon in sash |
| 2026-11-03 | AR-02 | arjuna_threequarter_v001.png | yes | |
| 2026-11-03 | AR-03 | arjuna_profile_v001.png | yes | Faces right |
| 2026-11-03 | AR-04 | arjuna_fullbody_v001.png | yes | Bow in right hand |
| 2026-11-03 | AR-05 | arjuna_chariot_seat_v001.png | yes | |
| 2026-11-03 | AR-06 | arjuna_expressions_v001.png | yes | |
| 2026-11-03 | ENV-01 | chariot_master_v001.png | yes, reference only | Banner has a small glyph-like mark beside the monkey; not fixed by decision (D-123) |
| 2026-11-03 | ENV-02 | chariot_seats_v001.png | yes, reference only | Same banner mark (D-123) |
| 2026-11-03 | ENV-03 | kurukshetra_master_v001.png | yes | 16:9 landscape; army flags carry small gold crests, no text |
| 2026-11-03 | ENV-04 | kurukshetra_sunrise_v001.png | yes | Nearly identical to master |
| 2026-11-03 | ENV-05 | kurukshetra_sunset_v001.png | yes | |
| 2026-11-03 | ENV-06 | sky_plates_v001.png | yes | |
| 2026-11-03 | ENV-07 | celestial_master_v001.png | yes | 16:9 landscape |

Cultural/devotional review (D-007): **pending**. No reviewer confirmed yet.
