# Gameplay Gate G01 — Core Gameplay and Fun Validation

Status: Ready — Awaiting Explicit Authorization

## Purpose

Pause era production after Era 5 and determine whether the completed first 30–60 minutes are understandable, active, varied, and fun enough to support the City Data Center and first Prestige loop.

This is an inserted product-validation gate, not a renumbered phase. Phase 17 remains the future Era 6 implementation contract and cannot begin until G01 produces an explicit proceed/revise/stop decision and the user separately authorizes Phase 17.

## Authority and entry state

- `DEC-039` closes Phase 16 with its physical-phone matrix explicitly unperformed and deferred; no Android check is converted into a pass.
- `DEC-040` defines City Data Center/Era 6 as the final content era of base game v1.0 and inserts this gate before Phase 17.
- Eras 1–5, their save compatibility, the locked Cheerful Electrical Doomsday direction, the human-operator role, and the reusable production-functional presentation system are the testable baseline.
- Existing gameplay formulas and balance data remain authoritative until measured G01 evidence supports a documented revision.

## Objective

Improve and validate the first 30–60 minutes so the player makes legible preparation and allocation decisions instead of following a highlighted stat and waiting. The gate must establish whether several approaches are viable, whether each request category creates a different planning problem, and whether purchases and grid events receive satisfying environmental, report, and WATT feedback.

## Included

### Baseline observation and measurement

- Define a local, privacy-preserving session log or manual observation sheet for G01 evidence. Do not add remote analytics, accounts, or network services.
- Measure time to first authorization, first purchase, allocation unlock, each early-era transition, first brownout, and the 30- and 60-minute marks.
- Measure active decision count, uninterrupted waiting time, longest stall, purchase timing/category, limiting-resource history, allocation-mode changes and dwell time, Reserve use, request preparation, brownouts, recoveries, report views, and abandoned or deferred choices.
- Separate deterministic simulation evidence from observed fresh-player behavior. Never present a scripted route as player evidence.

### Mechanically distinct request categories

Audit and, when authorized by this gate, revise Eras 1–5 so the categories ask recognizably different questions while retaining the established request lifecycle:

- Capacity tests sustained delivery and throughput preparation.
- Stability tests service quality across a known demand curve and rewards resilient configuration.
- Burst tests Reserve amount, charge timing, and discharge capability around a disclosed peak.
- Research tests whether the player accepts an upfront Stored Energy/opportunity cost for a useful system payoff.
- Vanity remains optional and expressive; it cannot block progression or become the optimal source of required power.

Category identity must come from mechanics, forecasts, decisions, and reports—not labels alone.

### Grid decision quality

- Strengthen tradeoffs involving Generation, Transmission, Reserve capacity/rates, current Stored Energy, purchases, and the three allocation modes.
- Ensure recommended actions explain why they help without reducing play to buying the highlighted resource.
- Test preparation choices such as early generation, transmission headroom, Reserve-first safety, Stored Energy saving, purchase timing, and allocation switching.
- Preserve at least two viable preparation approaches for representative early and mid-game requests. Approaches may differ in speed, service quality, Stored Energy outcome, or risk, but neither may depend on hidden information or punitive loss.
- Identify and revise progression intervals that can be solved only by buying the highlighted stat and passively waiting, unless the wait is short, intentional, and followed by a meaningful decision.

### Feedback, reports, and character

- Improve environmental feedback for purchases, bottlenecks, Reserve support, brownouts, recoveries, and request completions while keeping the evolving world and WATT primary.
- Make purchases visibly alter representative infrastructure or authored milestone states rather than only changing numbers.
- Improve performance reports so they explain the player's preparation, allocation, bottleneck, service result, resource outcome, and one useful next lesson.
- Add or refine WATT reactions for preparation choices, brownouts, recoveries, purchases, completions, and reports without spam or repeated lines.
- Perform a focused early-era WATT dialogue pass for Eras 1–5. Preserve the locked helpful-to-persuasive human-operator voice, payoff-first requests, comic contradiction, and provisional-copy boundary outside the reviewed lines.

### Fresh-player validation

- Run fresh-player sessions that begin without inherited saves, debug intervention, coaching through the intended answer, or prior knowledge of the optimal route.
- Target at least five complete 30–60 minute sessions across more than one tester where practical. Record tester context, platform/device, session length, reached era/request, assistance given, and incomplete sessions truthfully.
- Ask players what WATT wants, what is limiting progress, why they made their last purchase, what allocation mode does, how Reserve differs from Stored Energy, and whether they want to authorize the next request.
- Record confusion, compelling moments, idle/wait frustration, perceived agency, strategy used, report usefulness, WATT appeal, and desire to continue.
- If the minimum fresh-player evidence cannot be obtained, the gate cannot return `PROCEED`; it must return `REVISE` or `STOP` with the limitation disclosed.

## Required deliverables

1. Baseline first-30/60-minute route and decision-quality audit.
2. Request-category distinction matrix covering Capacity, Stability, Burst, Research, and Vanity.
3. Measured pacing, stall, waiting, purchase, limiting-resource, Reserve, and allocation-behavior report.
4. Documented tuning/mechanic revisions limited to Eras 1–5, with before/after evidence and deterministic tests.
5. Environmental feedback and performance-report improvement record with contextual captures.
6. Focused Eras 1–5 WATT dialogue review and provenance/localization validation.
7. Fresh-player test report with raw session summaries and synthesized findings kept distinct.
8. Known-issue and release-readiness impact assessment.
9. Explicit `PROCEED`, `REVISE`, or `STOP` recommendation and user decision before Phase 17.

## Acceptance criteria

- [ ] The first 30–60 minutes are measured from fresh starts with no debug intervention.
- [ ] Capacity, Stability, Burst, Research, and Vanity create mechanically distinguishable decisions.
- [ ] Generation, Transmission, Reserve, Stored Energy, purchases, and allocation modes each matter in observed or representative play.
- [ ] The main path is not reducible to repeatedly buying the highlighted stat and waiting.
- [ ] At least two viable preparation approaches are demonstrated for representative early and mid-game requests.
- [ ] No required approach depends on hidden odds, punitive loss, wire placement, a new currency, or remote services.
- [ ] Purchases, brownouts, recoveries, and completions receive readable environmental feedback.
- [ ] Performance reports explain outcomes and support a useful next decision.
- [ ] WATT reactions and the focused Eras 1–5 dialogue pass preserve the locked character/operator direction.
- [ ] Pacing, stalls, waiting, purchases, Reserve use, and allocation behavior are recorded and analyzed.
- [ ] At least five truthful fresh-player 30–60 minute sessions are recorded, or the gate explicitly cannot return `PROCEED`.
- [ ] Save/offline compatibility, deterministic simulation, accessibility layouts, headless launch, and the complete repository regression pass after any approved changes.
- [ ] Contextual manual evidence is reviewed; any physical-device checks actually performed are recorded, and none are inferred.
- [ ] An explicit user-approved `PROCEED`, `REVISE`, or `STOP` decision is recorded before Phase 17.

## Excluded

- Era 6, City Data Center, idle-transition, Model Retraining, Prestige, or any Phase 17 implementation
- Eras 7–16 or other post-launch expansion content
- A new player currency, permission meter, energy variable, or monetization system
- Wire-by-wire placement, resident simulation, recurring degradation chores, random offline disasters, or punitive progress loss
- Broad final-art replacement or closure of `ISSUE-007`
- Production publishing, store submission, or Phase 18+ work
- Remote analytics, accounts, advertisements, purchases, or live generative AI

## Decision standard

- **PROCEED:** The evidence supports the first 30–60 minutes as understandable, varied, and sufficiently engaging; remaining issues have accepted scope; Phase 17 may be proposed for separate explicit authorization.
- **REVISE:** The core has promise, but one or more acceptance criteria require another bounded G01 iteration. G01 remains active; Phase 17 stays prohibited.
- **STOP:** Evidence does not justify further era production without a material product rethink. Record the reasons and do not begin Phase 17.

The recommendation is not phase authorization. Even a user-approved `PROCEED` result requires a separate explicit instruction before Phase 17 begins.

## Stop conditions

- Stop and request a product decision if a proposed mechanic would materially change the three-variable grid model, request lifecycle, player currency structure, save guarantees, human-operator role, or locked visual direction.
- Stop if fresh-player evidence is unavailable rather than fabricating a fun/retention conclusion.
- Do not begin Phase 17, Era 6, Prestige, or any later phase during G01.
