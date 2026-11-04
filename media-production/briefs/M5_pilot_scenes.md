# Milestone 5: Pilot Scene Briefs and Prompts

Version v002 (2026-11-04). Five pilot scenes inside the MVP sample range
(Chapter 1 + 2.1--2.11, D-008).

v002: every prompt is now complete and paste-ready (no blocks to
assemble). Each prompt states the output size at the top and bottom,
tells ChatGPT to ignore the shape of landscape references, and fixes
the camera position and frame layout. Added fix-up replies.

> **Scripture check pending.** Verse ranges and story beats follow the
> commonly known sequence of the text. They must be verified against the
> chosen edition (D-003) by the scripture reviewer (D-006) before any
> scene is marked approved. Artwork can be generated now. No verse text
> or dialogue is written here.

## Overview

| # | Scene ID | Verses (verify) | Beat | Renderer |
|---|----------|-----------------|------|----------|
| 1 | `ch01_scene_001` | 1.1--1.11 | The two armies assembled at Kurukshetra | cinematic |
| 2 | `ch01_scene_002` | 1.14--1.27 | Chariot driven into the space between the armies | cinematic |
| 3 | `ch01_scene_003` | 1.28--1.47 | Arjuna's despair; he sets down his bow | manga_panel |
| 4 | `ch02_scene_001` | 2.1--2.9 | Arjuna asks Krishna for guidance, then falls silent | manga_panel |
| 5 | `ch02_scene_002` | 2.10--2.11 | Krishna, smiling, begins to teach (signature scene) | layered_motion |

------------------------------------------------------------------------

## How to generate each still in ChatGPT

1. Open a **new chat** for every still. Old images in a chat pull new
   ones toward the same shape and angle.
2. If ChatGPT shows an image-size or aspect option, choose **Portrait**.
3. Attach the reference images listed for that still. Attach
   **portrait references first** and landscape ones last.
4. Paste the whole prompt exactly as written. Send.
5. Check the result with the checklist under the prompt. If something
   is wrong, send the matching **fix-up reply** (bottom of this file).
   Fix one problem per reply.
6. Download the approved image to
   `media-production/generated-artwork/<asset_id>_src.png`.
7. Add a row to the generation log at the bottom.

**Size check without tools:** the image must be clearly **taller than
wide**. On a PC, right-click the file > Properties > Details: Width
1024, Height 1536. Anything else, use fix-up reply **FIX-SIZE**.

## How to make each clip in Google Flow

1. **Frames to Video**, aspect ratio **9:16**, length **8 s**.
2. Start frame: the approved still.
3. Looping scenes (1 and the optional 5): also set the **same still as
   the end frame**.
4. Paste the Flow prompt. Generate 3--4 candidates.
5. Pick the clip with no face drift, correct hands, no text, and slow
   smooth motion. Download at the highest resolution offered to
   `media-production/generated-video/<asset_id>_src.mp4`.

------------------------------------------------------------------------

## Scene 1: The armies assembled

**ID:** `ch01_scene_001` | **Renderer:** cinematic | **Verses:** 1.1--1.11 (verify)

**Beat:** Dawn on the field of Kurukshetra. Two vast armies stand
facing each other across empty ground. A moment of stillness.

| Asset ID | Path | From |
|----------|------|------|
| `ch01_scene001_poster` | `posters/ch01_scene001_poster.webp` | S1-A |
| `ch01_scene001_loop` | `videos/ch01_scene001_loop.mp4` | F1 (loop) |

### S1-A Poster and Flow start frame

**Attach:** `kurukshetra_master_v001.png`

```text
OUTPUT FORMAT (most important): one single image in VERTICAL PORTRAIT
orientation, exactly 1024 pixels wide by 1536 pixels tall (2:3, taller
than wide). Do not make a square or landscape image. The attached
reference image is landscape: use it ONLY for how the place, armies,
flags, elephants, and light look. Do NOT copy its shape or layout.

STYLE: Cinematic Indian mythological painting, rich and detailed, in the
spirit of classical Indian devotional art reimagined as a modern film
still. Painterly realism, soft volumetric light, fine detail. Palette:
deep midnight blue and charcoal shadows, antique gold highlights,
celestial blue sky, warm ivory light. Calm, reverent, majestic mood.

SCENE: The vast plain of Kurukshetra at dawn, before any battle. Two
great armies stand facing each other across a wide strip of empty,
dusty ground. The army on the LEFT carries red flags; the army on the
RIGHT carries blue flags. Front ranks show war elephants with gold
howdahs and red or blue caparisons, gold chariots, and rows of
soldiers in bronze armour holding spears upright. Everyone is still.
Thin dust hangs in the air, lit gold by the low sun.

CAMERA: Camera standing in the middle of the empty ground at about the
height of an elephant's back (5 metres), looking straight ahead along
the empty strip toward the horizon. Normal 35 mm lens, no fisheye, no
tilt. Strong one-point perspective: both armies recede from the left
and right edges toward a single vanishing point on the horizon in the
centre.

LAYOUT OF THE TALL FRAME (top to bottom):
- Top 0-35%: open dawn sky, celestial blue at the top fading to warm
  gold near the horizon, a few soft clouds.
- 35-42%: the horizon with low distant mountains and the rising sun
  exactly in the horizontal centre, just above the horizon line.
- 42-65%: the two armies. Nearest soldiers and one elephant on each
  side touch the left and right edges at about 55-65% height; they get
  smaller toward the centre. The empty ground between them forms a deep
  V pointing at the sun.
- 65-100% (bottom 35%): only open, softly lit dusty ground with a few
  dry grass tufts. No soldiers, no objects, no faces here.
- Keep the sun, the V of empty ground, and the nearest elephants inside
  the central 85% of the width; the outer edges may be cropped later.

LIGHTING: Low golden sun ahead, long soft shadows toward the camera,
gold rim light on helmets and spear tips, cool blue shadow on the near
ground.

MUST NOT INCLUDE: any text, letters, numbers, script, symbols, emblems,
or logos anywhere, including on flags (all flags are plain solid red or
plain solid blue); watermarks or signatures; fighting, weapons pointed,
blood, or motion blur; people walking; cartoon, anime, or video-game
style; fisheye or tilted horizon.

FINAL CHECK: the image is VERTICAL PORTRAIT, 1024 wide by 1536 tall,
taller than it is wide.
```

**Check:** vertical; sun centred on the horizon at ~38% height; V of
empty ground; bottom third empty; flags plain.

### F1 Flow prompt (loop: start frame = end frame = S1-A)

```text
Keep the vertical 9:16 framing. Very slow, smooth forward camera glide
along the empty ground toward the rising sun, so slight that the scene
stays almost the same. Flags ripple gently in a light breeze. Fine dust
drifts slowly through the golden sunlight. Soldiers and elephants stay
completely still apart from tiny natural movements: an elephant's ear
or trunk sways slightly. Sunlight brightens very subtly. Calm, majestic,
cinematic, 24 fps feel. No one walks or runs, no fighting, no camera
shake, no zoom jumps, no new objects, no text or symbols appearing on
flags.
```

------------------------------------------------------------------------

## Scene 2: Between the two armies

**ID:** `ch01_scene_002` | **Renderer:** cinematic | **Verses:** 1.14--1.27 (verify)

**Beat:** After the conch shells sound, Arjuna asks Krishna to drive
the chariot into the space between the armies. Krishna drives forward
at a calm walk. (Conches are heard in narration, not shown.)

| Asset ID | Path | From |
|----------|------|------|
| `ch01_scene002_poster` | `posters/ch01_scene002_poster.webp` | S2-A |
| `ch01_scene002_loop` | `videos/ch01_scene002_loop.mp4` | F2 (plays once) |

### S2-A Poster and Flow start frame

**Attach (in this order):** `krishna_fullbody_v001.png`,
`arjuna_fullbody_v001.png`, `krishna_chariot_seat_v001.png`,
`chariot_master_v001.png`

```text
OUTPUT FORMAT (most important): one single image in VERTICAL PORTRAIT
orientation, exactly 1024 pixels wide by 1536 pixels tall (2:3, taller
than wide). Do not make a square or landscape image. Some attached
references are landscape: use them ONLY for how Krishna, Arjuna, the
chariot, and the horses look. Do NOT copy their shape, camera angle, or
layout.

STYLE: Cinematic Indian mythological painting, rich and detailed, in the
spirit of classical Indian devotional art reimagined as a modern film
still. Painterly realism, soft volumetric light, fine ornament detail.
Palette: deep midnight blue and charcoal shadows, antique gold
highlights, celestial blue rim light, warm ivory tones. Solemn,
purposeful mood.

CHARACTERS (match the attached references exactly):
- KRISHNA, the charioteer: youthful man in his twenties, slender; soft
  blue complexion with a cool lavender undertone; warm brown eyes; calm
  face with a faint smile; long dark wavy hair; tall gold crown with a
  red teardrop gem and ONE upright peacock feather at the crown's
  front-left; gold drop earrings with a pearl; gold necklace with a red
  teardrop gem; long white-and-pink flower garland; gold silk scarf over
  his left shoulder; yellow silk dhoti; gold armlets and bracelets.
- ARJUNA, the warrior: young man in his twenties, strong natural build;
  warm wheatish complexion; short dark beard and moustache; long dark
  curls with a gold-bound top knot; gold warrior crown band with red
  gems; bronze-and-gold engraved breastplate and shoulder plates; white
  silk garments; maroon brocade shawl with gold flowers; brown quiver
  of white-fletched arrows on his back; tall dark-wood recurve bow with
  gold fittings.

CHARIOT AND HORSES (match the attached chariot exactly): gold-clad
wooden war chariot with gold filigree, two large spoked wheels with
gold rims, a domed gold canopy over the rear, red velvet seats. A tall
gold pole at the rear carries a saffron banner with a single pale
monkey figure and nothing else on it. Four white horses in gold
harness with red gems and gold tassels.

SCENE: The chariot is driven slowly, at a calm walk, out into the empty
ground between two armies on the plain of Kurukshetra. Krishna sits on
the FRONT seat holding the reins in both hands, calm and attentive.
Arjuna STANDS behind him on the rear platform under the canopy, holding
his bow upright in his left hand, looking ahead toward the far army
with a serious, thoughtful face.

CAMERA: Front three-quarter view. The camera stands on the ground
ahead of the chariot and slightly to its LEFT, at the chest height of a
standing person, about 12 metres away, looking back at the chariot as
it approaches. The chariot travels diagonally from the upper right
background toward the lower left foreground, angled about 30 degrees
from facing the camera head-on. We see the horses' faces and chests
and the front and left side of the chariot. Normal 50 mm lens, no
fisheye.

LAYOUT OF THE TALL FRAME (top to bottom):
- Top 0-12%: sky, with the top of the banner pole and banner reaching
  up to about 8% from the top.
- 12-55%: the canopy, Arjuna standing (full upper body visible), and
  Krishna seated in front of him. Both faces clearly visible and NOT
  hidden by the horses' heads; Krishna's face at about 38-45% height,
  Arjuna's face at about 25-32% height.
- 35-65%: the four horses walking toward the lower left, heads at
  about 35-45% height, angled so they do not cover the riders; front
  wheel and chariot body.
- 65-100% (bottom 35%): dusty ground with soft dust rising from the
  wheels and the horses' lower legs and hooves only. No faces here.
- Everything important (both faces, the horses' heads, the front
  wheel, the banner) inside the central 85% of the width.
- Background on both sides: the red-flag army far left and the
  blue-flag army far right, small and softly blurred.

MOTION IN THE STILL: horses mid-walk with one hoof lifted low; NOT
trotting or galloping, no flying manes.

LIGHTING: Golden-hour sun from behind and to the right of the chariot,
warm rim light on Krishna's crown, the feather, Arjuna's armour, and
the horses' manes; soft celestial blue fill on the shadow side.

MUST NOT INCLUDE: any text, letters, numbers, script, symbols, marks,
or squiggles anywhere, especially on the banner (only the plain monkey
figure) and on the distant flags (plain solid colours); watermarks;
extra people on the chariot; Krishna standing; Arjuna sitting; a flute;
galloping horses; extra or missing horses (exactly four); extra fingers;
fighting; cartoon, anime, or game style; side-on profile view.

FINAL CHECK: the image is VERTICAL PORTRAIT, 1024 wide by 1536 tall,
taller than it is wide, with the chariot seen from the front-left.
```

**Check:** vertical; front-left three-quarter angle; both faces
visible above the horses; four horses walking; banner has only the
monkey (zoom in); bottom third ground and hooves.

### F2 Flow prompt (no end frame; plays once)

```text
Keep the vertical 9:16 framing. The chariot moves slowly forward along
its diagonal path toward the lower left at a calm walking pace. The four
horses walk with smooth, natural, unhurried steps; wheels turn slowly.
Soft dust rises behind the wheels and hooves. The saffron banner and
Arjuna's maroon shawl move gently in the breeze. Krishna holds the reins
steadily with a calm face; Arjuna stands still holding his bow, looking
ahead. The camera stays in place and turns very slightly to follow the
chariot. No trotting or galloping, no speed-up, no camera shake, no
change to faces, crowns, or the peacock feather, no extra people, no
text or symbols appearing on the banner or flags.
```

------------------------------------------------------------------------

## Scene 3: Arjuna's despair

**ID:** `ch01_scene_003` | **Renderer:** manga_panel | **Verses:** 1.28--1.47 (verify)

**Beat:** Arjuna sees teachers, elders, and kinsmen in both armies. He
is overcome: his limbs tremble, his bow slips, and he sits down in the
chariot, setting aside bow and arrows.

Four separate vertical panels. Speech bubbles are added by the app, so
every panel keeps its bottom 35% calm.

| Asset ID | Path | From |
|----------|------|------|
| `ch01_scene003_panel001` | `images/ch01_scene003_panel001.webp` | S3-P1 |
| `ch01_scene003_panel002` | `images/ch01_scene003_panel002.webp` | S3-P2 |
| `ch01_scene003_panel003` | `images/ch01_scene003_panel003.webp` | S3-P3 |
| `ch01_scene003_panel004` | `images/ch01_scene003_panel004.webp` | S3-P4 |

### S3-P1 What Arjuna sees

**Attach:** `arjuna_profile_v001.png`, `krishna_profile_v001.png`,
`chariot_seats_v001.png`, `kurukshetra_master_v001.png`

```text
OUTPUT FORMAT (most important): one single image in VERTICAL PORTRAIT
orientation, exactly 1024 pixels wide by 1536 pixels tall (2:3, taller
than wide). Do not make a square or landscape image. Use the attached
references ONLY for how Arjuna, Krishna, the chariot, and the
battlefield look, not for shape or layout.

STYLE: Cinematic Indian mythological painting reimagined as a film
still; painterly realism, soft volumetric light, fine detail. Palette:
midnight blue shadows, antique gold highlights, celestial blue rim
light, warm ivory. Quiet, heavy mood.

CHARACTERS (match the references exactly):
- ARJUNA: wheatish complexion, short dark beard, long dark curls with a
  gold-bound top knot, gold crown band with red gems, bronze-and-gold
  armour, maroon brocade shawl, brown quiver of white-fletched arrows.
- KRISHNA: soft lavender-blue complexion, long dark wavy hair, tall gold
  crown with ONE peacock feather at its front-left, yellow and gold
  clothing.

SCENE: Seen from behind and just to the right of Arjuna, who stands on
the rear of the chariot looking out across the empty ground at the
opposing army. In the far army's front rank, standing in a gold
chariot, is a dignified white-bearded elder warrior in white and silver
armour, and beside him an older teacher-warrior with a grey beard. Both
look calm and noble. Soldiers with blue flags stand behind them.

CAMERA: Over-the-shoulder shot from behind Arjuna's right shoulder,
camera at his head height. Normal 50 mm lens. Arjuna is not facing the
camera; we see the back of his head, top knot, crown, quiver, and right
shoulder.

LAYOUT OF THE TALL FRAME:
- Right side, 0-70% height: Arjuna's back of head, crown, top knot, and
  quiver, large in the foreground, slightly out of focus, filling about
  the right 35% of the width.
- Lower left, 45-62% height: the top of Krishna's crown and his peacock
  feather from behind, at the front of the chariot, small.
- Centre-left, 25-50% height: the far army's front rank in focus; the
  elder and the teacher clearly readable but small.
- Top 0-20%: hazy golden sky.
- 65-100% (bottom 35%): the chariot's gold rail and calm dusty ground.
  No faces.
- Keep the elder, the teacher, and Arjuna's head inside the central
  85% of the width.

LIGHTING: Late golden light from the left; Arjuna's foreground in soft
shadow.

MUST NOT INCLUDE: any text, letters, numbers, symbols, or marks
anywhere, including on flags (plain solid blue); watermarks; fighting
or raised weapons; Arjuna's face toward the camera; cartoon, anime, or
game style.

FINAL CHECK: VERTICAL PORTRAIT, 1024 wide by 1536 tall.
```

### S3-P2 Grief rises

**Attach:** `arjuna_expressions_v001.png`, `arjuna_master_v001.png`

```text
OUTPUT FORMAT (most important): one single image in VERTICAL PORTRAIT
orientation, exactly 1024 pixels wide by 1536 pixels tall (2:3, taller
than wide). Do not make a square or landscape image. The attached
expression sheet is wide: use it ONLY for Arjuna's face and the
distressed expression (left portrait on the sheet), not for shape or
layout. Show ONE portrait only.

STYLE: Cinematic Indian mythological painting reimagined as a film
still; painterly realism, soft volumetric light. Palette: midnight blue
shadows, antique gold rim light, celestial blue tones. Sorrowful,
dignified mood.

CHARACTER: ARJUNA, matching the references exactly: wheatish
complexion, short dark beard and moustache, long dark curls with a
gold-bound top knot, gold crown band with red gems, red tilak line on
the forehead, gold drop earrings with a pearl, bronze-and-gold armour
collar with a red gem pendant, maroon shawl on his left shoulder.

SCENE: Close-up of Arjuna overcome by grief. Head turned slightly down
and to the viewer's left; brows drawn together; eyes wet, a single tear
on one cheek; lips pressed together. Sorrow held with dignity, not
crying out.

CAMERA: Close-up at eye level, slightly to his right. 85 mm portrait
lens, shallow depth of field.

LAYOUT OF THE TALL FRAME:
- Top 0-8%: top of the crown and top knot, with a little dark space.
- 8-60%: face and neck, eyes at about 30% height, centred.
- 60-100%: armour collar, shoulders, and maroon shawl fading into dark
  shadow; the bottom 35% stays dark and calm.
- Face inside the central 70% of the width.

LIGHTING: Cool celestial blue key light on his face from the viewer's
left; thin warm gold rim light on the right edge of his hair and crown;
dark, softly blurred battlefield behind.

MUST NOT INCLUDE: any text, letters, symbols, or marks; more than one
face; a grid or multiple panels; exaggerated wailing; cartoon, anime,
or game style.

FINAL CHECK: VERTICAL PORTRAIT, 1024 wide by 1536 tall, one face only.
```

### S3-P3 The bow slips

**Attach:** `arjuna_fullbody_v001.png`, `arjuna_chariot_seat_v001.png`

```text
OUTPUT FORMAT (most important): one single image in VERTICAL PORTRAIT
orientation, exactly 1024 pixels wide by 1536 pixels tall (2:3, taller
than wide). Do not make a square or landscape image. Use the
references ONLY for the design of Arjuna's arm guards, sleeves, shawl,
and bow.

STYLE: Cinematic Indian mythological painting reimagined as a film
still; painterly realism, soft volumetric light, fine detail. Palette:
midnight blue shadows, antique gold highlights, celestial blue tones.
Quiet, heavy mood.

SCENE: Close-up of Arjuna's two hands as his tall bow slips from his
loosened, trembling grip. The bow is the one in the reference: dark
wood with gold fittings and red gems, string visible. It tilts
diagonally from the upper right toward the lower left, sliding down,
not yet fallen. His fingers are open and slack. Only his forearms are
visible: engraved gold arm guards with red gems, white silk sleeves,
the edge of a maroon brocade shawl.

CAMERA: Close-up at waist height, looking slightly down at the hands.
85 mm lens, shallow depth of field.

LAYOUT OF THE TALL FRAME:
- 5-65% height: hands, forearms, and the tilting bow; the bow's upper
  limb reaches toward the top right, its lower limb toward the lower
  left ending around 65% height.
- 65-100% (bottom 35%): dim, out-of-focus gold-and-wood chariot floor.
- Hands inside the central 70% of the width.

HANDS: two hands, each with exactly five fingers, natural anatomy,
relaxed and open.

LIGHTING: Soft blue shadow; a thin line of warm gold light along the
bow's limb.

MUST NOT INCLUDE: any text, letters, symbols, or marks; extra hands or
fingers; a face; arrows flying; cartoon, anime, or game style.

FINAL CHECK: VERTICAL PORTRAIT, 1024 wide by 1536 tall.
```

### S3-P4 He sits down

**Attach:** `arjuna_chariot_seat_v001.png`, `krishna_chariot_seat_v001.png`,
`chariot_seats_v001.png`

```text
OUTPUT FORMAT (most important): one single image in VERTICAL PORTRAIT
orientation, exactly 1024 pixels wide by 1536 pixels tall (2:3, taller
than wide). Do not make a square or landscape image. Use the references
ONLY for how Arjuna, Krishna, and the chariot look.

STYLE: Cinematic Indian mythological painting reimagined as a film
still; painterly realism, soft volumetric light. Palette: dusk midnight
blue, antique gold glow, celestial blue tones. Grieving but tender mood.

CHARACTERS (match the references exactly):
- ARJUNA: wheatish complexion, short dark beard, gold-bound top knot,
  gold crown band, bronze-and-gold armour, white silk, maroon shawl.
- KRISHNA: soft lavender-blue complexion, long dark wavy hair, tall gold
  crown with ONE peacock feather at its front-left, gold necklace with a
  red gem, flower garland, yellow dhoti, gold scarf.

SCENE: Arjuna sits on the floor of the chariot's rear platform, knees
drawn up, head bowed, his right hand pressed to his brow. His bow and
quiver lie set aside on the floor beside him. At the front of the
chariot, Krishna has turned around in his seat to look back at him with
calm, compassionate attention.

CAMERA: Side view from the chariot's left, slightly elevated (camera
about 2.5 metres high), looking down at both figures. 35 mm lens.

LAYOUT OF THE TALL FRAME:
- Top 0-25%: the underside of the gold canopy and dusk sky.
- 25-45%: Krishna at the upper right, turned back toward Arjuna, face
  at about 32% height, softly lit.
- 40-65%: Arjuna seated at the left-centre, head bowed, face partly
  hidden by his hand.
- 65-100% (bottom 35%): dark chariot floor with the bow and quiver lying
  flat; no faces.
- Both figures inside the central 85% of the width.

LIGHTING: Cool dusk blue overall; a soft warm gold glow on Krishna's
face and crown (natural light, not a halo).

MUST NOT INCLUDE: any text, letters, symbols, or marks; halos, light
rings, sparkles; Krishna standing; extra people; cartoon, anime, or
game style.

FINAL CHECK: VERTICAL PORTRAIT, 1024 wide by 1536 tall.
```

------------------------------------------------------------------------

## Scene 4: Arjuna asks for guidance

**ID:** `ch02_scene_001` | **Renderer:** manga_panel | **Verses:** 2.1--2.9 (verify)

**Beat:** Krishna speaks to the grieving Arjuna, urging him to rise.
Arjuna asks Krishna to instruct him as his disciple, then says he will
not fight and falls silent.

| Asset ID | Path | From |
|----------|------|------|
| `ch02_scene001_panel001` | `images/ch02_scene001_panel001.webp` | S4-P1 |
| `ch02_scene001_panel002` | `images/ch02_scene001_panel002.webp` | S4-P2 |
| `ch02_scene001_panel003` | `images/ch02_scene001_panel003.webp` | S4-P3 |

### S4-P1 Krishna speaks

**Attach:** `krishna_threequarter_v001.png`, `krishna_expressions_v001.png`,
`krishna_chariot_seat_v001.png`

```text
OUTPUT FORMAT (most important): one single image in VERTICAL PORTRAIT
orientation, exactly 1024 pixels wide by 1536 pixels tall (2:3, taller
than wide). Do not make a square or landscape image. The expression
sheet is wide: use it ONLY for the "speaking" expression (centre
portrait). Show ONE figure only.

STYLE: Cinematic Indian mythological painting reimagined as a film
still; painterly realism, soft volumetric light, fine ornament detail.
Palette: midnight blue, antique gold, celestial blue rim, warm ivory.
Earnest, caring mood.

CHARACTER: KRISHNA, matching the references exactly: youthful, slender;
soft lavender-blue complexion; warm brown eyes; long dark wavy hair;
tall gold crown with a red teardrop gem and ONE peacock feather at the
crown's front-left; gold drop earrings with a pearl; gold necklace with
a red teardrop gem; white-and-pink flower garland; gold scarf over his
left shoulder; gold armlets.

SCENE: Krishna, seated at the front of the chariot, has turned to his
right to speak to Arjuna (who is off-frame, toward the viewer). He
speaks earnestly but kindly: lips slightly parted, brows gently raised,
his right hand lifted to chest height with the palm open and fingers
relaxed. Firm and caring at once.

CAMERA: Medium close-up from the waist up, eye level, as if from
Arjuna's position. 85 mm lens, soft background blur.

LAYOUT OF THE TALL FRAME:
- Top 0-10%: top of the crown and feather with a little space above.
- 10-60%: face (eyes at about 28% height), shoulders, and the raised
  hand at about 50-58% height.
- 60-100% (bottom 35%+): garland, scarf, and the blurred gold chariot
  rail, calm.
- Face and hand inside the central 80% of the width.

LIGHTING: Warm gold key light on his face from the viewer's left; soft
celestial blue rim on the right; dusky blurred battlefield behind.

MUST NOT INCLUDE: any text, letters, symbols, or marks; halo or glow
rings; a flute; more than one figure; a grid or multiple panels; extra
fingers; cartoon, anime, or game style.

FINAL CHECK: VERTICAL PORTRAIT, 1024 wide by 1536 tall, one figure.
```

### S4-P2 Arjuna asks to be taught

**Attach:** `arjuna_threequarter_v001.png`, `arjuna_expressions_v001.png`,
`arjuna_fullbody_v001.png`

```text
OUTPUT FORMAT (most important): one single image in VERTICAL PORTRAIT
orientation, exactly 1024 pixels wide by 1536 pixels tall (2:3, taller
than wide). Do not make a square or landscape image. The expression
sheet is wide: use it ONLY for the "listening" expression (centre
portrait). Show ONE figure only.

STYLE: Cinematic Indian mythological painting reimagined as a film
still; painterly realism, soft volumetric light. Palette: midnight blue,
antique gold, celestial blue, warm ivory. Humble, sincere mood.

CHARACTER: ARJUNA, matching the references exactly: wheatish
complexion, short dark beard and moustache, long dark curls with a
gold-bound top knot, gold crown band with red gems, red tilak line,
gold drop earrings, bronze-and-gold armour, white silk, maroon brocade
shawl, gold arm guards. No bow or quiver in his hands.

SCENE: Arjuna kneels on the chariot's rear platform, facing toward the
front of the chariot (toward the viewer's left), his two hands joined
palm to palm at his chest in a gesture of humble request. His eyes are
lifted toward Krishna (off-frame left) with sincere, searching hope.
Faint traces of tears on his cheeks.

CAMERA: Three-quarter view from his front-right, camera slightly below
his eye level. 50 mm lens.

LAYOUT OF THE TALL FRAME:
- Top 0-15%: canopy edge and dusk sky.
- 15-65%: Arjuna from the knees up; face at about 28% height; joined
  hands at about 45% height.
- 65-100% (bottom 35%): his knees and the dim chariot platform, calm.
- Figure inside the central 85% of the width.

LIGHTING: Cool blue light on most of him; warm gold light falling on
his face and hands from the viewer's left, as if from Krishna.

HANDS: two hands pressed palm to palm, five fingers each, natural.

MUST NOT INCLUDE: any text, letters, symbols, or marks; weapons in his
hands; extra people; a grid or multiple panels; cartoon, anime, or game
style.

FINAL CHECK: VERTICAL PORTRAIT, 1024 wide by 1536 tall, one figure.
```

### S4-P3 Silence

**Attach:** `chariot_seats_v001.png`, `krishna_chariot_seat_v001.png`,
`arjuna_chariot_seat_v001.png`, `kurukshetra_sunset_v001.png`

```text
OUTPUT FORMAT (most important): one single image in VERTICAL PORTRAIT
orientation, exactly 1024 pixels wide by 1536 pixels tall (2:3, taller
than wide). Do not make a square or landscape image. Several references
are landscape: use them ONLY for how the chariot, horses, Krishna,
Arjuna, and battlefield look, not for shape or layout.

STYLE: Cinematic Indian mythological painting reimagined as a film
still; painterly realism, soft volumetric light. Palette: dusk midnight
blue, last antique gold light, celestial blue. Hushed, still mood.

SUBJECTS (match the references exactly): the gold chariot with domed
canopy, saffron banner with only a plain pale monkey figure, four white
horses in gold harness; KRISHNA (lavender-blue skin, gold crown with
ONE peacock feather, yellow and gold clothing) seated at the front,
turned back toward Arjuna; ARJUNA (wheatish skin, beard, top knot,
bronze armour, maroon shawl) seated at the rear, head lowered, silent.

SCENE: The chariot stands completely still in the open ground between
two distant armies at dusk. The horses stand quietly, heads low.
Nothing moves.

CAMERA: Wide shot from the chariot's front-left, standing height, about
25 metres away. 35 mm lens. The whole chariot and all four horses are
visible but fairly small in the tall frame.

LAYOUT OF THE TALL FRAME:
- Top 0-35%: dusk sky, deep blue at the top, last gold glow low down.
- 35-40%: horizon with tiny distant armies and flags on both sides.
- 40-65%: the chariot and horses, centred; Krishna and Arjuna readable
  as small figures.
- 65-100% (bottom 35%): empty dusky ground with long blue shadows.
- Chariot and horses inside the central 85% of the width.

LIGHTING: Low sun just set behind the far right army; long blue
shadows; warm gold edge light on the canopy and banner.

MUST NOT INCLUDE: any text, letters, numbers, symbols, marks, or
squiggles, especially on the banner and flags; watermarks; extra
people near the chariot; movement or dust clouds; cartoon, anime, or
game style.

FINAL CHECK: VERTICAL PORTRAIT, 1024 wide by 1536 tall.
```

------------------------------------------------------------------------

## Scene 5: Krishna begins to teach (signature scene)

**ID:** `ch02_scene_002` | **Renderer:** layered_motion | **Verses:** 2.10--2.11 (verify)

**Beat:** Between the two armies, Krishna, as if smiling, speaks to the
despondent Arjuna and begins his teaching. The app adds aura, feather
motion, and golden particles (Milestone 7), so **no glow is painted
into any image**.

Build order: **S5-A** background (no Krishna) > **S5-B** Krishna on a
transparent background > **S5-C** both combined (poster) > optional
**F5** Flow loop.

| Asset ID | Path | From |
|----------|------|------|
| `ch02_scene002_background` | `environments/ch02_scene002_background.webp` | S5-A |
| `ch02_scene002_krishna_layer` | `characters/ch02_scene002_krishna_layer.webp` | S5-B |
| `ch02_scene002_poster` | `posters/ch02_scene002_poster.webp` | S5-C |
| `ch02_scene002_loop` (optional) | `videos/ch02_scene002_loop.mp4` | F5 (loop) |

### S5-A Background plate (no Krishna)

**Attach:** `arjuna_chariot_seat_v001.png`, `chariot_seats_v001.png`,
`kurukshetra_sunset_v001.png`

```text
OUTPUT FORMAT (most important): one single image in VERTICAL PORTRAIT
orientation, exactly 1024 pixels wide by 1536 pixels tall (2:3, taller
than wide). Do not make a square or landscape image. Several references
are landscape: use them ONLY for how Arjuna, the chariot, and the
battlefield look, not for shape or layout.

STYLE: Cinematic Indian mythological painting reimagined as a film
still; painterly realism, soft volumetric light, fine detail. Palette:
warm sunset gold, midnight blue shadows, celestial blue sky, ivory.
Calm, expectant mood.

SUBJECTS (match the references exactly):
- CHARIOT: gold-clad wooden war chariot, gold filigree, red velvet
  seats, domed gold canopy over the rear.
- ARJUNA: wheatish complexion, short dark beard, gold-bound top knot,
  gold crown band with red gems, bronze-and-gold armour, white silk,
  maroon brocade shawl; his bow lies beside him.

SCENE: The chariot stands still between the two armies at sunset.
Arjuna sits on the rear platform under the canopy, head now slightly
raised, beginning to listen, his face turned toward the front of the
chariot (toward the viewer's left). The FRONT charioteer seat is EMPTY.
No horses visible (they are out of frame to the left). No other people.

CAMERA: Low front-left three-quarter view of the chariot, camera at
about knee height, 6 metres away, looking slightly up. 35 mm lens.

LAYOUT OF THE TALL FRAME (critical, a figure will be added later):
- LEFT-CENTRE, 15-62% height and 20-60% of the width: the EMPTY front
  seat and open soft sky above and around it. Keep this area clear of
  objects, poles, and canopy edges.
- RIGHT, 15-60% height and 55-90% of the width: the canopy and Arjuna
  seated, face at about 35% height.
- Top 0-15%: sunset sky with soft clouds.
- 62-100% (bottom 35%+): the chariot's front panel and wheel, then calm
  dusty ground with tiny, blurred distant armies at the horizon.

LIGHTING: Warm sunset light from the viewer's left; soft celestial blue
in the shadows; gentle dust in the air.

MUST NOT INCLUDE: Krishna or anyone in the front seat; horses; any
text, letters, symbols, or marks; halos, glow, light rays, sparkles, or
particles; cartoon, anime, or game style.

FINAL CHECK: VERTICAL PORTRAIT, 1024 wide by 1536 tall, front seat
empty, left-centre area clear.
```

### S5-B Krishna layer (transparent background)

**Attach:** `krishna_master_v001.png`, `krishna_threequarter_v001.png`,
`krishna_expressions_v001.png`, `krishna_fullbody_v001.png`

```text
OUTPUT FORMAT (most important): one single PNG image with a FULLY
TRANSPARENT BACKGROUND (alpha channel), VERTICAL PORTRAIT orientation,
exactly 1024 pixels wide by 1536 pixels tall (2:3). Do not make a
square or landscape image. Use the references ONLY for how Krishna
looks; the expression sheet's right portrait shows the compassionate
expression to use.

STYLE: Cinematic Indian mythological painting; painterly realism, fine
ornament detail. Palette: antique gold, warm ivory, celestial blue rim
light.

CHARACTER: KRISHNA, matching the references exactly: youthful man in
his twenties, slender; soft blue complexion with a cool lavender
undertone; warm brown eyes; long dark wavy hair; tall gold crown with a
red teardrop gem and ONE upright peacock feather at the crown's
front-left; gold drop earrings with a pearl; gold necklace with a red
teardrop gem; long white-and-pink flower garland; gold silk scarf over
his left shoulder; yellow silk dhoti; gold armlets and bracelets.

POSE: Seated, shown from the waist up, body turned three-quarters to
the VIEWER'S RIGHT (as if speaking to someone behind him on that side),
head turned a little further toward the right. A gentle, reassuring
smile. His right hand is raised softly at chest height in a calm
teaching gesture, palm slightly forward, fingers relaxed and natural;
his left hand rests out of view.

LAYOUT: Krishna fills about the central 70% of the width; top of the
feather at about 5% from the top; waist at the bottom edge of the
figure around 75-80% height; below the waist is transparent.

LIGHTING (baked into the figure): warm sunset light from the viewer's
left, soft celestial blue rim light on the right.

MUST NOT INCLUDE: any background colour, scenery, floor, or shadow; a
white or grey backdrop; halo, glow, light rays, sparkles, or particles;
a flute; text, letters, or marks; extra fingers; cartoon, anime, or
game style. Clean, crisp edges around the hair, crown, and feather.

FINAL CHECK: VERTICAL PORTRAIT, 1024 wide by 1536 tall, background
fully transparent.
```

### S5-C Poster (combined)

**Attach:** your approved S5-A and S5-B images.

```text
OUTPUT FORMAT (most important): one single image in VERTICAL PORTRAIT
orientation, exactly 1024 pixels wide by 1536 pixels tall (2:3, taller
than wide), the same framing as the attached background image.

TASK: Combine the two attached images into one natural scene. Place
Krishna (the transparent figure) into the EMPTY front charioteer seat
on the left-centre of the background, seated and turned toward Arjuna,
at the size a seated man of his build would be at that distance (his
crown reaching about 15-18% from the top of the image). Match the
background's sunset lighting and add a soft, natural contact shadow
where he sits.

KEEP UNCHANGED: Krishna's face, expression, crown, peacock feather,
jewellery, garland, clothing, and hand pose; Arjuna, the chariot, and
the background composition.

MUST NOT INCLUDE: halo, glow, light rays, sparkles, or particles; any
text, letters, or marks; any change to the frame's shape.

FINAL CHECK: VERTICAL PORTRAIT, 1024 wide by 1536 tall.
```

### F5 Optional Flow loop (start frame = end frame = S5-C)

```text
Keep the vertical 9:16 framing. An almost still, serene moment. Krishna
keeps a gentle, steady smile and breathes softly; his raised hand stays
still. The peacock feather on his crown sways very slightly in the
breeze. Fine dust motes drift slowly through the warm sunset light.
Arjuna stays still, listening. Distant flags ripple faintly. The camera
does not move. No glow or light effects added, no change to faces, no
hand or finger movement, no lip movement, no text.
```

### After approval: record effect anchors

On the final poster, measure each point as a fraction of width (x) and
height (y) from the top-left corner, e.g. a point 520 px from the left
and 460 px from the top of a 1024x1536 image is x 0.51, y 0.30.

| Effect | Point to measure |
|--------|------------------|
| `golden_aura` | Centre of Krishna's face and upper chest |
| `peacock_feather` | Base of the feather where it meets the crown |
| `floating_particles` | Centre of the area around Krishna |

Send the numbers to Claude Code for the scene JSON. Measure on the
1024x1536 ChatGPT image; Claude Code converts them to the 9:16 crop
(864x1536, 80 px trimmed from each side).

------------------------------------------------------------------------

## Fix-up replies (paste into the same chat)

**FIX-SIZE** (result is square or landscape):

```text
The image must be VERTICAL PORTRAIT, exactly 1024 pixels wide by 1536
pixels tall, taller than it is wide. Regenerate the same scene in that
shape. Keep the characters, clothing, lighting, and camera angle;
rearrange the layout vertically as described in my first message.
```

**FIX-ANGLE** (wrong camera view):

```text
Keep everything else the same, but use exactly the camera position from
my first message: [paste the CAMERA paragraph here]. Keep the image
vertical, 1024x1536.
```

**FIX-TEXT** (marks, letters, or symbols on banners, flags, or clothing):

```text
Remove every mark, letter, symbol, or squiggle from the banner and
flags. The banner shows only the plain pale monkey figure; all other
flags are plain solid colour. Change nothing else.
```

**FIX-FACE** (character drifted from the reference):

```text
Make [Krishna / Arjuna]'s face, complexion, crown, and jewellery match
the attached reference exactly. Change nothing else.
```

**FIX-HANDS**:

```text
Fix the hands: each hand has exactly five fingers with natural anatomy.
Change nothing else.
```

**FIX-BOTTOM** (faces or key detail in the bottom third):

```text
Move the main subject up so the bottom 35% of the image is only calm
ground or shadow. Keep the image vertical, 1024x1536. Change nothing
else.
```

**FIX-GLOW** (scene 5 has painted glow or sparkles):

```text
Remove all glow, halo, light rays, sparkles, and particles. Natural
light only. Change nothing else.
```

**FIX-TRANSPARENT** (S5-B has a background):

```text
Make the background fully transparent (PNG with alpha). Keep Krishna
exactly the same. Keep the image vertical, 1024x1536.
```

------------------------------------------------------------------------

## Processing with FFmpeg (Claude Code runs this)

Put selected sources in `media-production/generated-artwork/` and
`media-production/generated-video/` (not committed). Approved outputs go
to `assets/<path>` from the tables.

**Video** (strip Flow audio, crop to 9:16 if needed, H.264, never
upscale):

```bash
ffmpeg -i media-production/generated-video/IN.mp4 -an \
  -vf "crop=trunc(ih*9/32)*2:ih,fps=24" \
  -c:v libx264 -profile:v high -pix_fmt yuv420p -crf 22 -preset slow \
  -movflags +faststart assets/videos/ch01_scene001_loop.mp4
```

**Still to 9:16 WebP** (crops the 2:3 still to 9:16, centred):

```bash
ffmpeg -i media-production/generated-artwork/IN.png \
  -vf "crop=trunc(ih*9/32)*2:ih" \
  -c:v libwebp -quality 85 assets/posters/ch01_scene001_poster.webp
```

**Transparent layer to WebP (keeps alpha):**

```bash
ffmpeg -i media-production/generated-artwork/IN.png \
  -vf "crop=trunc(ih*9/32)*2:ih" \
  -c:v libwebp -pix_fmt yuva420p -quality 90 \
  assets/characters/ch02_scene002_krishna_layer.webp
```

**Inspect and checksum** (values go into `media_manifest.json`):

```bash
ffprobe -v error -show_entries stream=codec_name,width,height,duration \
  -show_entries format=size -of compact assets/videos/ch01_scene001_loop.mp4
sha256sum assets/videos/ch01_scene001_loop.mp4
```

------------------------------------------------------------------------

## Checklist per image

- [ ] 1024x1536, taller than wide.
- [ ] Camera angle matches the CAMERA paragraph.
- [ ] Layout matches the frame map; bottom 35% calm; key content in the
      central 85% of the width.
- [ ] Faces, crowns, feather, armour match `docs/CHARACTER_BIBLE.md`.
- [ ] No text or marks (zoom on banners, flags, borders).
- [ ] Hands correct.
- [ ] Scene 5: no painted glow; S5-B background transparent.

## Generation log

| Date | Still | Asset | Attempts | Approved | Notes |
|------|-------|-------|----------|----------|-------|
| 2026-11-04 | S2-A | ch01_scene002_poster | 1 | no | 1536x1024 landscape, side view, horses trotting, faint banner mark |
| 2026-11-04 | S1-A | ch01_scene001_poster | -- | yes | Processed to assets/posters (864x1536) |
| 2026-11-04 | S2-A | ch01_scene002_poster | 2 | yes | Vertical, front-left; horses trotting (accepted) |
| 2026-11-04 | S3-P1..P4 | ch01_scene003_panel001-004 | -- | yes | Processed to assets/images |
| 2026-11-04 | S4-P1..P3 | ch02_scene001_panel001-003 | -- | yes | P3: last horse's nose at the 9:16 crop edge |
| 2026-11-04 | S5-A | ch02_scene002_background | -- | not used | Superseded by poster as background (D-125) |
| 2026-11-04 | S5-B | ch02_scene002_krishna_layer | -- | not used | Waist-up, does not match poster pose (D-125) |
| 2026-11-04 | S5-C | ch02_scene002_poster | -- | yes | Used as poster and background |
| 2026-11-04 | F1 | ch01_scene001_loop | -- | no | Does not loop (SSIM 0.52); Veo watermark (D-126) |
| 2026-11-04 | F2 | ch01_scene002_loop | -- | hold | Motion OK; Veo watermark (D-126) |
| 2026-11-04 | F5 | ch02_scene002_loop | -- | hold | Loops (SSIM 0.87); eyes close mid-clip; Veo watermark (D-126) |
