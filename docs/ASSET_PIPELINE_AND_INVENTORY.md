# Asset Pipeline and Inventory

## Asset record

Every production asset must record:

- Stable asset ID
- Type and intended screen/era
- Source format
- Export format and dimensions
- Creator/source/tool
- Prompt and references when AI-assisted
- License and commercial-use status
- Version/date
- Godot import settings
- Memory estimate
- Status: placeholder, candidate, approved, integrated, rejected, retired

## Inventory table

Maintain a machine-readable inventory when production begins. Minimum columns:

```text
id,path,type,era,screen,status,source,license,dimensions,memory_notes,approved_by
```

## Source files

Retain editable sources for vector art, layered illustrations, audio sessions, and animation rigs when available. Generated exports are not the only copy of important assets.

## Naming

Use lowercase snake_case and stable category directories. Do not name production files `final`, `final2`, or `new_new`.

Examples:

```text
watt_face_thinking_era01.svg
icon_generation_wall_outlet.svg
env_era02_bedroom_background.webp
sfx_request_complete_03.ogg
```

## UI assets

Prefer Godot theme styles, nine-patch textures, SVG icons, and reusable components. Avoid full-screen baked UI images. Never bake dynamic text into generated art.

## Raster assets

- Generate/export above intended display size, then downsample cleanly.
- Use lossless formats where transparency/edges require it.
- Use WebP or appropriate compression for large opaque backgrounds.
- Inspect at actual phone scale.
- Avoid excessive unique high-resolution textures per era.

## Audio assets

- Retain clean source and normalized game export.
- Use OGG for longer music/ambience where appropriate.
- Avoid harsh repeated high-frequency effects.
- Record loop points and loudness target.
- Verify behavior with system audio focus and mute settings.

## Approval flow

`placeholder → candidate → approved → integrated → device verified`

Only approved assets may define the production direction. Integrated assets are not complete until verified in context on the target screen.

## License gate

Unknown or ambiguous rights block production release. Record licenses for fonts, icons, textures, sounds, references, third-party tools, and generated outputs.

## Completion audit

Release-scope assets must have no placeholder status, broken reference, unrecorded source, missing license, inconsistent resolution, or unexplained import warning.
