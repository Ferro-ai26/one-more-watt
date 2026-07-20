# Decision Log

Accepted decisions are authoritative. New entries must not silently overwrite old ones; mark a superseded decision and link its replacement.

## DEC-001 — WATT is the main character

- Status: Accepted
- Decision: Requests, dialogue, unlocks, and progression are framed through WATT. The grid is the managed system, not the game's personality.
- Reason: Character-driven escalation differentiates the game from generic power incremental titles.

## DEC-002 — Three-variable grid model

- Status: Accepted
- Decision: The core grid consists of Generation, Transmission, and Reserve. No wire-by-wire simulation is planned.
- Reason: These constraints create legible decisions on a phone without engineering-simulator complexity.

## DEC-003 — City Data Center is Era 6

- Status: Accepted
- Decision: Era 6 is City Data Center and marks the deliberate transition from fast active requests to 20–60 minute idle requests.
- Reason: The game must spend enough time at human scale for escalation to feel earned.

## DEC-004 — Brownouts never erase request progress

- Status: Accepted
- Decision: Insufficient power reduces progress rate and report quality but never reverses accumulated progress or destroys ordinary infrastructure.
- Reason: Failure should inform and amuse rather than punish time investment.

## DEC-005 — Offline simulation is deterministic and safe

- Status: Accepted
- Decision: Offline progress uses known state and deterministic demand. Random destructive offline events are prohibited.
- Reason: Players cannot respond while away and should not be punished by unpreventable randomness.

## DEC-006 — Authored WATT dialogue

- Status: Accepted
- Decision: Shipped WATT dialogue is authored content. Live generative AI is not required.
- Reason: Authored lines provide consistent comedy, safety, localization, and offline operation.

## DEC-007 — Prototype contains Eras 1–3

- Status: Accepted
- Decision: The first vertical slice ends after Home Server Closet and includes 12–18 requests, full core grid mechanics, save, and conservative offline progress.
- Reason: It proves the relationship between WATT, requests, and grid management before expensive content expansion.

## DEC-008 — Data-driven content

- Status: Accepted
- Decision: Authored content and balance values live outside presentation and simulation scripts, initially in validated JSON.
- Reason: The game requires large content expansion and frequent balancing without repeated code changes.

## DEC-009 — No monetization in the prototype

- Status: Accepted
- Decision: Phases 00–09 contain no advertising, purchases, premium currency, or monetization pressure.
- Reason: The first milestone is proving fun, clarity, retention potential, and technical reliability.

## DEC-010 — Godot 4.6.2 foundation baseline

- Status: Proposed
- Date: 2026-07-19
- Decision: Target Godot 4.6.2 stable with the GL Compatibility renderer for the project foundation. Store the development version in `application/config/version` as its single source.
- Reason: This stable engine and matching export templates are installed and operational on the ARM64 development host, and GL Compatibility is the conservative mobile baseline.
- Consequences: Keep the project on this exact engine line during an active phase. Any upgrade requires an accepted decision and full regression pass; Android export still requires an approved package identifier and complete SDK.

## DEC-011 — Manifest-driven JSON schema version 1

- Status: Proposed
- Date: 2026-07-19
- Decision: Use `data/manifest.json` as the single content entry point, JSON as source of truth, schema version 1, exact placeholder-asset exceptions, typed immutable runtime definitions, and only enumerated effect/unlock vocabularies.
- Reason: The Phase 01 contract requires deterministic validation, stable cross-file IDs, safe effects, and a content version without committing later phases to generated Godot resources.
- Consequences: Schema changes require a manifest/schema version decision; unknown content operations and undeclared missing assets fail closed. Full prototype population remains separate from the schema exercise records.

## DEC-012 — Load-first standalone grid boundary

- Status: Proposed
- Date: 2026-07-19
- Decision: Keep Phase 02 request-agnostic. Deliverable power and Reserve serve a generic external load first; remaining surplus is split by the selected allocation mode. Eligible grid share charges Reserve before conversion to Stored Energy, while the WATT share is exposed for the Phase 03 request layer.
- Reason: This preserves the documented Reserve equations, prevents simultaneous Reserve charge/discharge, and avoids embedding request lifecycle assumptions in `GridCalculator`.
- Consequences: Phase 03 owns the mapping from authored continuous demand and useful WATT power to request progress, but it must consume the existing grid outputs rather than rewriting the core flow equations.

## DEC-013 — Served request load contributes useful WATT power

- Status: Proposed
- Date: 2026-07-20
- Decision: During an active request, power that serves its authored demand contributes to useful WATT power. WATT's share of surplus may add acceleration up to `max_useful_power`; only the remaining grid share may charge Reserve or convert to Stored Energy.
- Reason: This connects the load-first Phase 02 boundary to the documented first request, which must complete from the starting 5 W grid even when its continuous demand is also 5 W, without double-counting request-serving energy as currency.
- Consequences: Allocation affects acceleration when surplus exists, underpowered requests still advance from actually served demand, and preview/runtime use the same demand and cap definitions. A future balance change can alter authored values without changing this boundary.

## DEC-014 — Explicit starting ownership and derived economy rebuild

- Status: Proposed
- Date: 2026-07-20
- Decision: Store starting infrastructure as stable-ID counts in balance data. Remove those items' authored contributions from the non-owned starting-grid baseline during economy configuration, then rebuild all derived grid values from baseline hardware, ownership, milestones, passive effects, and upgrades through the same aggregator used by previews.
- Reason: The documented starting Wall Outlet must be real ownership for cost scaling and unlocks, while the Phase 02 starting grid already included its 5 W. Separating the two sources prevents double counting and makes a fresh state equivalent to a reconstructed state after load.
- Consequences: Future saves should persist currency, stable ownership counts, upgrade levels, milestone history, and automation settings rather than aggregate grid totals. Authored starting ownership must validate against infrastructure IDs, and balance changes can be applied by rebuilding without save migration unless a stable ID changes.

## DEC-015 — Thin online session coordinator with presentation snapshots

- Status: Proposed
- Date: 2026-07-20
- Decision: Use a thin `GameSession` to coordinate the existing request and economy domains during online play. Keep calculations in those domains, synchronize their shared Stored Energy and economy-derived grid state only at explicit boundaries, and expose UI-ready data through `MainViewModel` snapshots.
- Reason: Phase 05 needs purchases, allocation, requests, and reports to operate as one loop without moving economy rules into scene scripts or forcing the Phase 03 and Phase 04 coordinators to know about presentation.
- Consequences: UI tests can compare view-model fields directly with domain previews, save work can later serialize domain truth behind the session boundary, and scene labels remain disposable presentation. Any future consolidation of request/economy state must preserve the tested atomic command and rebuild behavior.

## DEC-016 — Checksummed local JSON with validated backup rotation

- Status: Proposed
- Date: 2026-07-20
- Decision: Use canonical SHA-256-checksummed JSON save format version 2 with one main file, two known-good rotating backups, timestamped corrupt evidence, sequential migrations, and domain restore validation before a new snapshot may replace main.
- Reason: The prototype needs inspectable diagnostics and deterministic migration tests while protecting progress from interrupted writes, malformed files, stale derived caches, and duplicated completion rewards.
- Consequences: Content compatibility and stable-ID migrations fail closed, every successful save advances a monotonic sequence and non-decreasing trusted UTC, and storage writes remain local under `user://`. Cloud sync and platform backup guarantees require a later decision.

## DEC-017 — Report-driven era and feature progression

- Status: Proposed
- Date: 2026-07-20
- Decision: Store unlocked/current eras, best Stability service, authored feature rewards, pending era transition, and prototype completion in the existing economy state. Add the validated `stability_service_at_least` condition for the documented Era 3 gate, and keep required request selection distinct from optional vanity selection.
- Reason: Phase 07 needs cross-system gates based on requests, ownership, upgrades, and report quality without introducing a second authoritative progression store or embedding stable content IDs in presentation scripts.
- Consequences: Request reports reconcile into economy progression before availability refresh; all new fields round-trip through format version 2 with safe defaults; additive `0.6.0` saves may load into `0.7.0`; and future conditions must remain enumerated, data-driven, and reachability-tested.

## DEC-018 — Put prototype pacing into visible work, not purchase cliffs

- Status: Proposed
- Date: 2026-07-20
- Decision: Tune the Eras 1–3 first run around a 65.8-minute mechanical earned-currency route plus conservative newcomer interaction time, producing a 79.8-minute structured self-test. Lengthen authored requests while lowering Portable Generator to 425 Stored Energy and Reinforced Wiring to 41,000 so no required purchase gap exceeds five minutes.
- Reason: The Phase 07 route reached the endpoint in 46.8 minutes but hid 660 seconds behind one late purchase. Continuously moving request progress is legible and character-bearing; an unchanging affordability wait is not.
- Consequences: The first request remains 25 seconds, Era 2 and Era 3 move to 11.7 and 37.0 minutes, all four prepared-route Era 3 requests take 3–6 minutes, and the structured route lands at 79.8 minutes. This is deterministic self-test evidence, not an external-player timing claim; an unfamiliar-player pass remains required when a tester is available.

## DEC-019 — Reproducible prebuilt-template Android prototype

- Status: Proposed
- Date: 2026-07-20
- Decision: Export the Phase 09 debug prototype from a clean recorded commit with Godot 4.6.2's matching prebuilt Android template, arm64-v8a and x86_64 architectures, version code 9, no Internet permission, and only the vibration permission required by the existing optional haptic feedback. Inject the exact source commit into build diagnostics during export and record the APK package, signature verification, byte size, and SHA-256 hash.
- Reason: The prototype has no custom Java/plugin dependency requiring Gradle, while a deterministic script makes artifact provenance and PC handoff repeatable. x86_64 supports a future emulator pass and arm64-v8a covers the intended physical-device pass.
- Consequences: The prebuilt template supplies minimum API 24 and target API 35. A production AAB, release signing, store assets, and additional architectures remain outside Phase 09. The publisher approved the permanent package identifier `com.ferroai.onemorewatt` on 2026-07-20.

## DEC-020 — Close Phase 09 with targeted revisions

- Status: Accepted
- Date: 2026-07-20
- Decision: Conclude Phase 09 with “continue with targeted revisions.” Accept Kevin's manual Moto phone report as the available physical-device evidence while recording every skipped device check as unverified. Do not begin the existing Phase 10 because the roadmap and document pack are being revised.
- Reason: The recorded APK passed host build/static verification and successfully installed/launched on physical hardware with working onboarding and touch purchases. The tester reported no blocker/critical defect, but found a minor presentation-scale issue and chose to skip the remaining questionnaire.
- Consequences: `ISSUE-004` remains open for a later 720p/scale revision. Brownout/Back, lifecycle/offline, force-close, audio/haptics, safe-area, endpoint, and device-performance behavior are not promoted to passing evidence. Future planning must account for those validation gaps before external release claims.

<!-- ONE_MORE_WATT_DECISION_V2 -->
## DEC-021 — Adopt post-prototype roadmap v2

- Status: Accepted
- Date: 2026-07-20
- Decision: Replace the unstarted v1 Phase 10–16 roadmap with the v2 Phase 10–26 roadmap. Add explicit targeted stabilization, theme/art direction, reusable skin architecture, Eras 1–3 production skinning, visual/mobile QA, era-integrated art production, content lock, final audiovisual production, release-candidate stabilization, closed testing, and separately authorized production release.
- Reason: The Phase 09 Android prototype proved the functional loop, but the original roadmap did not allocate enough controlled work for visual identity, systematic skinning, full-game production quality, and external release evidence.
- Consequences: Completed Phase 00–09 history remains authoritative. Original Phase 10–16 contracts are archived as superseded and must not be executed. Phase 10 begins only after explicit authorization.
<!-- END_ONE_MORE_WATT_DECISION_V2 -->

## DEC-022 — Scale the Android prototype by density within layout bounds

- Status: Accepted
- Date: 2026-07-20
- Decision: Keep the documented 720 × 1280 `canvas_items`/`expand` base, but on mobile multiply Godot's automatic resolution scale by a density-derived content scale. Treat one logical UI unit as one Android density-independent pixel where the display can still provide at least the verified 320 × 568 logical layout; otherwise bound the scale at that layout floor. Expose the measured inputs and result in Settings.
- Reason: The Moto symptom was “presentation appeared too small,” but the project was already configured at the suggested 720p base. The actual mismatch was that the UI contract's 48-pixel controls were treated as 48 dp while Godot's canvas stretch responded to pixel resolution, not Android density. A fixed resolution change would not reliably correct physical size across xhdpi, xxhdpi, and xxxhdpi phones.
- Consequences: Typical 720 × 1600 xhdpi and 1080 × 2400 xxhdpi screens both resolve to approximately 360 × 800 logical units, making a 48-unit target approximately 48 dp. Very small dense displays favor the verified layout floor over an impossible physical-size target. The exact Moto result is deferred to Phase 14 under DEC-023; broad visual redesign remains Phase 11+ work.

## DEC-023 — Close Phase 10 with device verification deferred

- Status: Accepted
- Date: 2026-07-20
- Decision: Close Phase 10 on its complete host regression, diagnosed/implemented density-scale fix, larger-text repair, and verified APK. Accept the absence of a revised-build Moto run as an explicit limitation; transfer `ISSUE-004` physical-device verification to Phase 14. Withdraw `ISSUE-005` because no actionable reproduction details were provided, without inferring any unspecified defect.
- Reason: The user explicitly cancelled the remaining Phase 10 bug investigation and Moto verification and accepted the limitation so production planning can continue. Existing host and partial-device evidence remains truthful and sufficient for this explicitly qualified stabilization closure.
- Consequences: No Phase 10 device check is retroactively marked passed. Phase 14 owns the Moto/device comfort, display/density, safe-area, accessibility, lifecycle, and representative-session verification for the density-aware production build. Phase 11 is only Ready — Awaiting Explicit Authorization and did not begin in this closure session.

## DEC-024 — Select Soft Circuit Workshop for final direction revision

- Status: Superseded by DEC-025
- Date: 2026-07-20
- Decision: Select Phase 11 Candidate A — Soft Circuit Workshop as the sole direction to revise toward final approval. Preserve its warm, tactile, domestic, character-first premise and WATT's visual priority, but remove overly childish, plastic, chunky, toy-like, or exaggerated presentation. Ground the style in believable electrical hardware, painted metal, rubber cable, switches, cooling equipment, monitors, restrained wear, labels, and improvised construction details. Keep numeric data crisp on Android, category and warning colors strongly separated, effects restrained, and the visual grammar continuous from workshop through city and cosmic scales.
- Reason: Candidate A best supports early attachment, infrastructure accumulation, and the permanent domestic-to-cosmic premise. The required revisions address its main identified risk without importing another candidate's identity.
- Consequences: Fredoka, oversized pill controls, thick cartoon outlines, pristine plastic surfaces, and exaggerated bounce are rejected. Blueprint Bureau's industrial-dashboard/drafting identity and Midnight Appliance Theatre's heavy glow/noise are also rejected and must not be mixed into the selected system. Atkinson Hyperlegible Next/Mono, mature tactile hardware, smaller radii, controlled edge wear, and restrained effects form the final proposal. Candidate selection is accepted, but the direction is not locked and Phase 11 is not complete until the user explicitly approves the revised final package.

## DEC-025 — Supersede dashboard composition with Living Animated Workshop Diorama

- Status: Superseded by DEC-026
- Date: 2026-07-20
- Decision: Reject the Soft Circuit Workshop final package's main-screen composition and flat environmental treatment. Replace it with **Living Animated Workshop Diorama** and lock the hierarchy as: world first (WATT plus evolving physical infrastructure), character second (requests, expressions, reactions), numbers third (details in drawers and contextual panels). The routine portrait screen uses a compact 10–12% status rail, a 60–65% layered animated cutaway, WATT physically occupying about 20–30% of that scene, an attached request near the scene bottom, compact navigation, and partial-height Build/Upgrade drawers that preserve the visible world. Reports may remain card-based secondary overlays.
- Reason: The rejected package retained dashboard-first gameplay and treated the environment as an illustration inside equipment cards. That contradicted the intended visible-accumulation fantasy and detached WATT from the world. A living diorama makes physical change, character behavior, and scale escalation the primary play surface while keeping detailed numbers available without dominating it.
- Consequences: Preserve the Atkinson font proposal, verified contrasts, semantic category colors, graphite/fastener/cable/vent/label/cooling/wear language, provenance work, production planning, and phone-scale review process. Redesign WATT as a non-toy physical resident with authored body/cable behavior. Purchases use installation anchors, cable-path animation, and milestone visual states rather than free physics or one rendered object per owned unit. The earlier `selected_direction/` package is superseded evidence only. The world-first structure is decided; approval remains required for the revised visual execution before Phase 11 can lock. Runtime integration, font import, skinning, and Phase 12 remain prohibited.

## DEC-026 — Reopen Phase 11 for a major visual and narrative pivot

- Status: Accepted
- Date: 2026-07-20
- Decision: Stop the Living Animated Workshop Diorama revision and remove every current Phase 11 package from approval consideration. Preserve the three-candidate comparison, rejected Soft Circuit final proposal, and incomplete Living Workshop sources as clearly labeled superseded exploration. Phase 11 remains open with no selected visual or narrative direction while a substantial pivot is defined in a future session.
- Reason: The user is reconsidering the visual and narrative direction substantially and explicitly directed that current refinement stop. Continuing to polish, render, or infer the next direction would create misleading approval evidence and premature production assumptions.
- Consequences: No current hierarchy, main-screen composition, WATT housing, environment plan, or production estimate is locked. Compatible technical evidence—Atkinson font/licensing records, tested contrast pairs, semantic category separation, provenance methods, and validation process—may be reconsidered later but is not automatically part of the next direction. Runtime files, fonts, production skinning, and Phase 12 remain untouched and prohibited. The next Codex session must begin by obtaining/reading the new direction brief and re-auditing Phase 11 scope rather than resuming either superseded package.

## Proposed decision template

```markdown
## DEC-XXX — Short title

- Status: Proposed | Accepted | Rejected | Superseded by DEC-XXX
- Date:
- Decision:
- Reason:
- Consequences:
```
