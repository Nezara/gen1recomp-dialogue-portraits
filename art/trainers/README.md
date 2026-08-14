Pre-baked portraits, one per ROM battle-art file, same basename as the
source (`brock.png`, `rival1.png`, ...).

Two things are baked in, both done once here rather than at runtime:

**Crop.** A straight crop of the corresponding
`assets/generated/battle/trainers/<name>.png` (all 56x56): a 30x30 square,
centered horizontally, starting 4px down from the top (30/56 ≈ 0.536,
4/56 ≈ 0.071 of the source). Checked against a dozen poses (upright,
leaning, raised-arm, seated) before landing there. An earlier pass used a
42x42 square from `y = 0` — 42/56 = 0.75, "the top middle section" as
originally asked for — and came back reading as too much shoulder and not
enough face; the smaller, lower window crops most of the body out and fills
the frame with the head instead. It also happens to land the art at a clean
1x inside the INSET panel's 32x32 interior (30 fits with a pixel of padding
each side) instead of the old crop's fractional ~0.76x.

**Color.** The ROM art has none of its own — every pixel is one of 4 flat
grays. Recolored with BROWNMON, a real palette from this game's own
`red/data/generated/palettes.lua` (the one vanilla already uses for
brown-family species like Diglett and Dragonite): warm off-white paper, tan
midtone, brown shadow, near-black outline — close to a sepia photograph. It
isn't a claim about any character's "true" color — the source has none, so
there's no such thing — just one sourced, consistent palette applied to all
45.

GRAYMON (the palette vanilla uses for gray-family species like Ditto and
Eevee) shipped first and came back reading as washed out — its own job is
signaling "this has no real color", so its midtone sits deliberately pale,
barely darker than the paper. BROWNMON keeps almost the same brightness ramp
(both run roughly 245 → 180 → 128 → 19 in luminance) but at real saturation,
which is what actually reads as colorized rather than faded.

A 2x-upscale/downscale smoothing pass was also tried (blending the hard
steps between the palette's four colors into soft gradients) and dropped —
it read as blurry rather than clean, not worth the tradeoff. The crisp,
flat-color edges above are the shipped look.

Regenerate the whole set from a fresh ROM extract with:

```powershell
Add-Type -AssemblyName System.Drawing
$srcDir = "<pokemon-love2d save dir>\red\assets\generated\battle\trainers"
$outDir = "<this folder>"
$sizeFraction = 30.0 / 56.0
$yFraction = 4.0 / 56.0
$c0 = @(255,239,255); $c1 = @(230,165,123); $c2 = @(173,115,74); $c3 = @(25,16,16)

foreach ($f in Get-ChildItem $srcDir -Filter *.png) {
  $img = [System.Drawing.Bitmap]::FromFile($f.FullName)
  $iw = [int]$img.Width; $ih = [int]$img.Height
  $size = [int]([Math]::Floor([Math]::Min($iw, $ih) * $sizeFraction))
  $yoff = [int]([Math]::Floor($ih * $yFraction))
  $cx = [int](($iw - $size) / 2)
  $out = New-Object System.Drawing.Bitmap($size, $size)
  for ($y = 0; $y -lt $size; $y++) {
    for ($x = 0; $x -lt $size; $x++) {
      $px = $img.GetPixel(($cx + $x), ($yoff + $y))
      if ($px.R -gt 211) { $col = $c0 } elseif ($px.R -gt 127) { $col = $c1 }
      elseif ($px.R -gt 43) { $col = $c2 } else { $col = $c3 }
      $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($px.A, $col[0], $col[1], $col[2])) | Out-Null
    }
  }
  $out.Save((Join-Path $outDir $f.Name), [System.Drawing.Imaging.ImageFormat]::Png)
  $out.Dispose(); $img.Dispose()
}
```

The color-bucket thresholds (211/127/43 on the red channel) match the
engine's own shade-remap shader exactly (`src/render/PaletteFX.lua`'s
`p.r > 0.83 / 0.5 / 0.17` in 0-255 terms), so this is the same recolor the
game would do at runtime if these were a normal SGB zone — just done once,
offline, with a chosen palette instead of whatever zone happens to be
active on screen.

If one character's crop looks off (an unusually wide pose, hair reaching
past the frame), re-crop that single file by hand rather than changing the
fractions for everyone else. Same goes for color — swap `$c0`..`$c3` for a
different sourced palette (see `red/data/generated/palettes.lua`) and rerun,
or hand-edit one file that doesn't read well.

**All 45 are now hand-edited masters in `../trainers_new/`**, not the raw
automated crop above — that script only matters if starting over from a
fresh ROM extract. To regenerate this folder from the current masters
instead, drop the crop step (they're already 30x30) and recolor only:

```powershell
Add-Type -AssemblyName System.Drawing
$srcDir = "<this mod>\art\trainers_new"
$outDir = "<this mod>\art\trainers"
$c0 = @(255,239,255); $c1 = @(230,165,123); $c2 = @(173,115,74); $c3 = @(25,16,16)

foreach ($f in Get-ChildItem $srcDir -Filter *.png) {
  $img = [System.Drawing.Bitmap]::FromFile($f.FullName)
  $out = New-Object System.Drawing.Bitmap($img.Width, $img.Height)
  for ($y = 0; $y -lt $img.Height; $y++) {
    for ($x = 0; $x -lt $img.Width; $x++) {
      $px = $img.GetPixel($x, $y)
      if ($px.R -gt 211) { $col = $c0 } elseif ($px.R -gt 127) { $col = $c1 }
      elseif ($px.R -gt 43) { $col = $c2 } else { $col = $c3 }
      $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($px.A, $col[0], $col[1], $col[2])) | Out-Null
    }
  }
  $out.Save((Join-Path $outDir $f.Name), [System.Drawing.Imaging.ImageFormat]::Png)
  $out.Dispose(); $img.Dispose()
}
```

Same one-way caveat as before: this is not safely re-runnable on its own
output, so `../trainers_new/` is the only copy to edit. This is also the
script `../pokemon_new/` uses (see `../pokemon/README.md`).
