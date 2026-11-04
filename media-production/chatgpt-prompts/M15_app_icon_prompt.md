# M15 App Icon and Feature Graphic Prompts (v001)

Generate in ChatGPT. Save the results to
`media-production/generated-artwork/m15/` as `icon_v001.png` and
`feature_graphic_v001.png`. I then make the Android adaptive icon (all
densities), the monochrome themed icon, and the 512 × 512 Play icon.

Rules (Android adaptive icons): the artwork is cropped to a circle,
squircle, or rounded square depending on the phone. Everything important
must sit inside the **centre 66%**. No text, no letters, no thin lines
that vanish at 48 px.

## Prompt A: app icon (generate 3–4 options)

```text
Create a square app icon, 1024 x 1024 pixels, for "Moksharan", a
respectful Bhagavad Gita reading app with a cinematic Indian mythology
style.

Composition:
- One simple, bold central emblem: a stylised golden peacock feather
  eye merged with a softly glowing lotus, seen straight on and perfectly
  centred.
- The emblem fills about 55% of the canvas width and sits entirely
  inside the central 66% circle. Nothing important near the edges or
  corners.
- Background: a smooth radial gradient from deep midnight blue (#0B1426)
  at the edges to slightly lighter blue (#1A2640) behind the emblem,
  with a very faint celestial glow (#7EB0E6 at low opacity). No stars,
  no texture, no frame, no border.

Style:
- Antique gold (#C9A227) with warm highlights, clean vector-like
  shapes, gentle depth, crisp edges.
- Calm, dignified, timeless. Reads clearly at small sizes (48 px).
- Flat enough to work as a launcher icon. No photographic detail, no
  tiny ornaments.

Do not include: any text or letters, Om or other script characters, a
human face or figure, weapons, a drop shadow outside the canvas,
rounded-corner masking (keep the full square), or a white background.
```

If the emblem is too detailed, follow up: "Simplify the emblem to fewer,
bolder shapes so it reads at 48 pixels. Keep the same colours and
centring."

## Prompt B: feature graphic

```text
Create a wide banner, exactly 1024 x 500 pixels, for the Google Play
listing of "Moksharan", a cinematic Bhagavad Gita motion-manga app.

Scene: dawn over the Kurukshetra plain, seen from a low, wide angle. A
golden chariot with white horses stands small on the right third, and
two armies are faint silhouettes on the horizon. The sky shifts from
midnight blue (#0B1426) at the top to warm saffron and gold near the
horizon. Soft celestial light rays. Painterly, cinematic, respectful.

Keep the left 45% of the image calm and fairly dark (the sky and empty
plain), because Google Play places text and buttons over it. No text,
no logos, no letters, no faces in close-up, no fighting or weapons in
use.
```

## Check before sending back

- [ ] Square 1024 × 1024 PNG (icon); 1024 × 500 (feature graphic).
- [ ] No text or letters anywhere.
- [ ] The icon emblem stays inside the centre circle when cropped round.
- [ ] Looks clear when shrunk to the size of a phone launcher icon.
