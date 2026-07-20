# Living Workshop Concept Provenance

Status: Superseded, incomplete exploration; not rendered, reviewed, approved, or production-ready.

## Origin

All SVG compositions in this directory were authored as repository-native markup by Codex for ONE MORE WATT on 2026-07-20. They use no external imagery, traced artwork, third-party texture, product mark, or generated raster. Work stopped before PNG rendering or visual inspection.

The exact proposed Atkinson Hyperlegible Next/Mono files were available only in `/tmp/omw_phase11_typography` during rendering. The files are not embedded, copied into the repository, or imported into Godot. Their upstream commits, hashes, sizes, and OFL 1.1 records remain in `../CONCEPT_ASSET_RECORD.md`.

## Review assets

| ID | Source/export | Dimensions | Status |
| --- | --- | ---: | --- |
| `p11_living_main` | `living_workshop_main.svg` | 720 × 1280 | Superseded; unrendered |
| `p11_living_build` | `living_workshop_build_drawer.svg` | 720 × 1280 | Superseded; unrendered |
| `p11_power_strip_sequence` | `questionable_power_strip_sequence.svg` | 1800 × 900 | Superseded; unrendered |
| `p11_living_brownout` | `living_workshop_brownout.svg` | 720 × 1280 | Superseded; unrendered |
| `p11_desk_bedroom_pullback` | `desk_to_bedroom_pullback.svg` | 1800 × 900 | Superseded; unrendered |
| `p11_watt_physical_sheet` | `watt_physical_model_sheet.svg` | 1600 × 1600 | Superseded; unrendered |

## Unexecuted rendering recipe

```bash
XDG_DATA_HOME=/tmp/omw_phase11_typography ffmpeg -hide_banner -loglevel error \
  -i docs/phase_11/living_workshop/living_workshop_main.svg -frames:v 1 -y \
  docs/phase_11/living_workshop/living_workshop_main.png
```

The recipe was recorded but not executed for this package. No approval composite was created.

## Rights status

Concept SVGs are internal original work, subject to the unresolved publisher/copyright-holder identity recorded in project setup. They are superseded evidence only and confer no production approval.
