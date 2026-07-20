# Phase 11 Concept Asset Record

Status: All recorded packages are superseded exploration under `DEC-026`. No direction or production asset is approved or integrated.

## Provenance

All three candidate compositions were authored as repository-native SVG markup by Codex for ONE MORE WATT on 2026-07-20. No image-generation model, external image, traced artwork, texture, logo, or third-party visual reference was used. Dynamic-looking labels are concept copy inside review artifacts only; production-game text will remain rendered by Godot.

The current-prototype capture was rendered from the repository's own `4c77a30` runtime with isolated fresh user data. The PNG concepts were mechanically rendered from their adjacent SVG sources using the host `ffmpeg` SVG renderer. The comparison board scales each candidate to 360 × 640 and places the three renders side by side without modifying their content.

The revised Soft Circuit package was authored as repository-native SVG markup on 2026-07-20 after the user's Candidate A selection, then rejected and superseded. No image-generation model, external image, texture, traced artwork, or third-party visual asset was used. Its review PNGs were mechanically rendered with FFmpeg while the exact proposed Atkinson Hyperlegible Next and Mono variable fonts were available in an uncommitted temporary font directory.

The later Living Animated Workshop Diorama revision stopped mid-production. Six SVG sources exist under `living_workshop/`; they were not rendered, assembled into a board, or manually inspected. Their directory-level provenance record labels them superseded and incomplete.

## Inventory

| Asset ID | Source / export | Type and use | Dimensions | Status | Origin / tool | Rights status | Memory note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `p11_a_main_grid` | `concepts/candidate_a_soft_circuit_workshop.svg` / `.png` | Candidate A Main Grid | 720 × 1280 | Candidate | Original SVG / FFmpeg render | Internal original; copyright holder/publisher identity still unresolved in project setup | Review PNG only; not an imported game texture |
| `p11_b_main_grid` | `concepts/candidate_b_blueprint_bureau.svg` / `.png` | Candidate B Main Grid | 720 × 1280 | Candidate | Original SVG / FFmpeg render | Internal original; copyright holder/publisher identity still unresolved in project setup | Review PNG only; not an imported game texture |
| `p11_c_main_grid` | `concepts/candidate_c_midnight_appliance_theatre.svg` / `.png` | Candidate C Main Grid | 720 × 1280 | Candidate | Original SVG / FFmpeg render | Internal original; copyright holder/publisher identity still unresolved in project setup | Review PNG only; not an imported game texture |
| `p11_comparison_board` | Derived from the three candidate PNGs | Approval board | 1080 × 640 | Candidate | FFmpeg scale/hstack | Same as source concepts | Review-only composite |
| `p11_current_grid_capture` | `concepts/current_prototype_360x640.png` | Audit baseline | 360 × 640 | Evidence | Godot 4.6.2 Movie Maker / FFmpeg frame extraction | Repository-owned runtime capture; not a new art asset | Evidence only |
| `p11_soft_grid_final` | `selected_direction/soft_circuit_main_grid.svg` / `.png` | Revised Main Grid proposal | 720 × 1280 | Final proposal | Original SVG / FFmpeg render | Internal original; publisher identity still unresolved in project setup | Review only; not a game texture |
| `p11_soft_build_final` | `selected_direction/soft_circuit_build_states.svg` / `.png` | Four required Build states | 720 × 1280 | Final proposal | Original SVG / FFmpeg render | Same as above | Review only |
| `p11_soft_report_final` | `selected_direction/soft_circuit_performance_report.svg` / `.png` | Performance Report state | 720 × 1280 | Final proposal | Original SVG / FFmpeg render | Same as above | Review only |
| `p11_soft_brownout_final` | `selected_direction/soft_circuit_brownout.svg` / `.png` | Brownout/recovery state | 720 × 1280 | Final proposal | Original SVG / FFmpeg render | Same as above | Review only |
| `p11_soft_era_transition_final` | `selected_direction/soft_circuit_era_01_to_02.svg` / `.png` | Era 01-to-02 transition | 720 × 1280 | Final proposal | Original SVG / FFmpeg render | Same as above | Review only |
| `p11_watt_model_final` | `selected_direction/watt_model_sheet.svg` / `.png` | WATT construction, expressions, housing continuity | 1400 × 1500 | Final proposal | Original SVG / FFmpeg render | Same as above | Review only |
| `p11_soft_phone_board` | `selected_direction/soft_circuit_phone_board.png` | Five-state readability board | 1080 × 1280 | Final proposal | FFmpeg scale/stack | Same as source concepts | 360 × 640 per screen; review only |

## Typography status

The original three candidate SVGs use installed DejaVu fallbacks. The revised final proposal uses these exact temporary review files; neither is copied, embedded, committed, or integrated into the game in Phase 11:

| Role | File | Upstream commit | SHA-256 | Size | License |
| --- | --- | --- | --- | --- | --- |
| UI/body/display | `AtkinsonHyperlegibleNext[wght].ttf` | `7925f50f649b3813257faf2f4c0b381011f434f1` | `5a455d1cfa099b601ab70751bb9673e8fe1854dc4500c80e1a220d0d75e31745` | 114,552 bytes | SIL Open Font License 1.1 |
| Numeric/status | `AtkinsonHyperlegibleMono[wght].ttf` | `154d50362016cc3e873eb21d242cd0772384c8f9` | `5ce8b1698d1ded7dff2178c1a3ad159470085a58ea239e8b2cb88f4fb4a6f646` | 53,960 bytes | SIL Open Font License 1.1 |

Source directories and copyright metadata are recorded in `selected_direction/SOFT_CIRCUIT_DIRECTION_SPEC.md`. Later integration must vendor the exact files with full `OFL.txt`, preserve copyright notices, verify the packaged APK, test glyph coverage/localization expansion, and record the imported resources in the production inventory.

## Reproduction commands

```bash
ffmpeg -hide_banner -loglevel error -i docs/phase_11/concepts/candidate_a_soft_circuit_workshop.svg -frames:v 1 -y docs/phase_11/concepts/candidate_a_soft_circuit_workshop.png
ffmpeg -hide_banner -loglevel error -i docs/phase_11/concepts/candidate_b_blueprint_bureau.svg -frames:v 1 -y docs/phase_11/concepts/candidate_b_blueprint_bureau.png
ffmpeg -hide_banner -loglevel error -i docs/phase_11/concepts/candidate_c_midnight_appliance_theatre.svg -frames:v 1 -y docs/phase_11/concepts/candidate_c_midnight_appliance_theatre.png
ffmpeg -hide_banner -loglevel error \
  -i docs/phase_11/concepts/candidate_a_soft_circuit_workshop.png \
  -i docs/phase_11/concepts/candidate_b_blueprint_bureau.png \
  -i docs/phase_11/concepts/candidate_c_midnight_appliance_theatre.png \
  -filter_complex "[0:v]scale=360:640[a];[1:v]scale=360:640[b];[2:v]scale=360:640[c];[a][b][c]hstack=inputs=3" \
  -frames:v 1 -y docs/phase_11/concepts/candidate_comparison_board.png
```

These commands overwrite generated review exports only. SVG sources remain authoritative for candidate content.

The revised-package render command uses the same one-frame FFmpeg form for every SVG under `selected_direction/`; the 1080 × 1280 phone board scales each of the five required 720 × 1280 screens to 360 × 640, places three across the first row and two centered on the second row, and does not change their content.

## Approval implications

No recorded package remains an approval candidate. All SVGs and PNGs are exploration references only until a future Phase 11 direction explicitly re-adopts an element. They must not be silently mixed into production or treated as inputs to Phase 12.
