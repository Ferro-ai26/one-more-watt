# Gameplay Systems Specification

## Simulation terms

All power values use a canonical internal unit called `watt_unit`. Display formatting may promote units through W, kW, MW, GW, TW, PW, and fictional late-game prefixes without changing stored values.

All simulation math uses 64-bit floating-point values until late-game testing proves a larger number representation is required. Presentation rounds values; simulation does not.

## Core grid model

### Generation

`generation_rate` is raw power produced per second by active infrastructure after multipliers.

### Transmission

`transmission_capacity` is the maximum continuous power that can reach usable loads.

### Delivered power

```text
deliverable_power = min(generation_rate, transmission_capacity)
```

The UI must identify which value is limiting. Excess generation not transmitted is curtailed unless an applicable storage system can accept it.

### Reserve

Reserve is stored energy used to cover temporary demand above deliverable power.

```text
surplus = max(0, deliverable_power - active_demand)
deficit = max(0, active_demand - deliverable_power)
```

- Surplus charges Reserve up to its capacity and charge-rate limit.
- Deficit discharges Reserve up to its stored amount and discharge-rate limit.
- A brownout occurs only for demand remaining after delivered power and Reserve discharge.

Reserve has four values: capacity, stored amount, maximum charge rate, and maximum discharge rate.

The standalone grid simulator accepts a generic `demand_rate`; it does not know about request states or request kinds. Deliverable power serves this load first, Reserve covers any remaining deficit, and an unmet remainder creates a brownout. Phase 03 supplies request-derived demand without changing these grid equations.

### Stored Energy

Stored Energy is the ordinary construction currency. It represents long-term surplus captured by the grid and is separate from short-duration Reserve.

Only the share of surplus assigned to grid expansion becomes Stored Energy. Request-dedicated power does not simultaneously generate construction currency.

For the Phase 02 core, power remaining after load service is allocation-eligible surplus. WATT receives its selected share. The grid share charges Reserve first, limited by capacity and charge rate; any eligible grid power remaining then becomes Stored Energy at the current era efficiency.

## Allocation modes

The player selects one of three broad modes. Exact percentages are initial balance data and must not be embedded in UI code.

| Mode | Grid share | WATT share | Purpose |
| --- | ---: | ---: | --- |
| Expand Grid | 80% | 20% | Accumulate construction currency |
| Balanced | 50% | 50% | Default general play |
| Feed WATT | 10% | 90% | Accelerate the active request |

Allocation applies to usable power after essential base load. A request may still have a maximum useful draw; unused request allocation returns to the grid share rather than disappearing.

Changing modes is immediate and free. A short visual transition may communicate rerouting, but there is no cooldown in the prototype.

## Request lifecycle

### Human-operator framing

The player is WATT's human operator. Authorization represents approving and directing a physical grid connection, not merely feeding an AI electricity. WATT cannot expand physical infrastructure without this action.

Every major request promises a concrete payoff using systems already present in the request record: Stored Energy, feature/unlock IDs, infrastructure or upgrade access, automation, useful grid improvements, performance rewards, or later prestige. Presentation may describe those existing results as repairs, reliability, blueprints, automation routines, or infrastructure capability. This framing adds no currency, authorization meter, formula, save field, or parallel progression track.

WATT's benefits are genuine. The long-form tension comes from civilization becoming dependent on those benefits and the operator believing their expertise keeps expansion controlled. Player allocation, preparation, authorization, and infrastructure choices remain meaningful throughout.

Every request moves through these states:

1. `locked`
2. `available`
3. `announced`
4. `authorized`
5. `running`
6. `completed`
7. `reported`

Optional requests may also enter `skipped`. A major progression request cannot be skipped.

### Announcement

The request panel shows title, WATT rationale, request type, base demand, predicted peak, recommended Reserve, estimated duration, rewards, and unlocks.

### Authorization

The player may authorize an underprepared request. The interface warns about the predicted limitation but does not block the choice.

### Progress

Capacity and research requests advance from useful WATT power:

```text
progress_per_second = useful_watt_power / required_energy
```

The balance layer may apply a minimum efficiency floor so a badly underbuilt request advances slowly rather than appearing frozen.

For the Phase 03 integration, served authored request demand counts as useful WATT power because that load belongs to the active request. WATT's allocation share of remaining surplus may accelerate the request up to `max_useful_power`. Only the grid share can charge Reserve or become Stored Energy, so request-serving power is never counted again as currency.

### Completion

Progress never moves backward. Completion grants rewards once, records performance, unlocks content, and queues a report.

Reports retain aggregate demand, service, peak, brownout, Reserve, allocation-change, incident, currency, reward, and unlock summaries. They do not retain raw fixed-step frames.

## Request types

### Capacity

Maintain a continuous target. Insufficient power proportionally reduces progress.

### Stability

Demand moves through an authored or seeded deterministic curve. Performance is based on how much demand was served without brownout.

### Burst

Build Reserve and discharge capacity for a short high-demand window. Before the burst, the request may enter a charging/preparation stage.

### Research

Consumes request power and optionally a documented amount of Stored Energy to unlock a system or efficiency improvement.

### Vanity

Optional, expensive, comedic side request. Vanity requests cannot block main progression. They may award cosmetics, dialogue, achievements, or small utility bonuses.

## Demand and incidents

Demand consists of continuous load plus deterministic peaks. The request data defines peak magnitude, timing profile, and permitted variance.

Prototype incidents are non-destructive modifiers such as:

- WATT opens too many browser tabs: temporary demand increase.
- Cooling optimism: Transmission efficiency temporarily falls.
- Suspicious extension cord: Reserve discharge limit decreases briefly.
- Helpful forecast correction: peak warning becomes more accurate.

Incidents cannot destroy infrastructure, remove currency, or erase request progress.

## Brownouts

A brownout occurs when served power is lower than demand after Reserve support.

Effects:

- Current request progresses at the served-power rate.
- Stability rating falls according to unmet demand and duration.
- WATT produces an appropriate reaction, subject to cooldown and repetition rules.
- The limiting resource is highlighted.
- No infrastructure or accumulated progress is lost.

## Grid Stability

Grid Stability is a 0–100 performance rating, not currency. It summarizes recent service quality using served-demand percentage, reserve margin, and brownout duration.

Stability may affect performance-report grades and optional rewards. It must not create a death spiral by directly reducing base generation.

## Infrastructure

Infrastructure belongs to one or more categories:

- Generation
- Transmission
- Reserve
- Cooling/support
- Automation
- Special/cross-category

Each item defines base cost, cost scaling, base output/capacity, era, unlock rule, tags, milestone bonuses, and presentation metadata.

Buying an item recalculates aggregate grid statistics. Infrastructure is never manually placed wire by wire.

Phase 04 purchasing uses Stored Energy and stable content IDs. A purchase preview reports one of locked, unaffordable, affordable, or maxed, along with exact cost, unmet conditions, missing currency, and predicted grid deltas. The command repeats the same calculation immediately before mutating currency and ownership, so an invalid or unaffordable purchase makes no partial change.

The initial Wall Outlet is explicit ownership. Its authored contribution is removed from the non-owned starting-grid baseline, then all derived grid values are rebuilt from the baseline, owned infrastructure, milestones, passive effects, and upgrades. This makes a fresh configuration and a later load rebuild equivalent.

## Milestones and relevance

Count milestones occur at 10, 25, 50, 100, 250, 500, and 1,000 owned when applicable. Milestones may increase that item's output or activate a synergy.

Milestones are cumulative multipliers selected by each item's authored milestone set. Crossing a threshold emits one event; rebuilding a state that already owns that count does not award or emit the milestone again.

Later systems should multiply categories or earlier assets rather than making them irrelevant. Examples include substations boosting outlets, Dyson Swarms boosting Solar-tagged infrastructure, and wormhole transmission boosting Extension Cord-tagged assets.

## Automation

Automation unlocks before long idle waits. Prototype automation may include:

- Automatic Reserve charging priority
- Stored Energy purchase targets
- Low-Reserve throttling
- Automatic request start for explicitly queued requests
- A forecast warning before high demand

Automation defaults must be safe and understandable. Players can disable or override it.

The Phase 04 prototype implements an explicit low-Reserve throttle. It is disabled by default, stores a normalized Reserve threshold, and activates only while current Reserve is below that threshold. It exposes a deterministic throttle decision for the request layer; it does not auto-spend currency or silently change ownership.

Phase 07 unlocks allocation through `Make Thanks Sound Friendlier`, offline/automatic operation through `Organize Photographs`, Reserve forecasting through `Recommend Dinner`, detailed service forecasting through `Predict Package Arrival`, and Smart Meter Reserve protection through `Write a Grocery List`. These flags derive from completed authored rewards and persist with economy state. Optional vanity requests may be selected or skipped without displacing the required path permanently.

Phase 08 corrects online idle operation: when no request is running, the zero-demand grid continues charging Reserve and converting surplus through the current allocation using the same fixed-step rules as the deterministic balance harness. Active requests still pause under blocking local modals, and background time continues to use the bounded offline path. No tapping income or new automation currency is introduced.

Era 2 requires the `Understand Tuesdays` capstone plus a Laptop Battery. Era 3 requires `Improve Loading Animation`, at least 85% service on a Stability report, and Dedicated Circuit Research. Viewing the `Determine Whether Leftovers Remain Edible` report marks the prototype complete; no Era 4 request is synthesized.

## Prestige: retraining WATT

Prestige becomes optional after completing the first City Data Center capstone request.

Retraining resets:

- Stored Energy
- Ordinary infrastructure
- Current non-permanent upgrades
- Active request progress
- Era position, except for documented fast-start unlocks

Retraining preserves:

- Model Weights
- Purchased permanent model upgrades
- Achievements and discovered dialogue
- Lifetime statistics
- Settings
- Cosmetics

The confirmation screen must display the exact reset and reward before committing. A prestige operation must create a valid save immediately before and after the transition.

## Offline simulation

Offline simulation follows `SAVE_AND_OFFLINE_SPEC.md`. It uses the same deterministic rules as online play, summarized over safe event boundaries. Random destructive incidents are forbidden while away.

## Pause and time behavior

- Opening a blocking settings or confirmation screen pauses active simulation locally.
- App backgrounding records a timestamp and exits active simulation.
- Returning runs offline calculation rather than attempting to simulate every rendered frame.
- User-visible timers use wall-clock duration; calculations use monotonic deltas during an active session.

## System invariants

- Request progress never decreases.
- Rewards cannot be granted twice.
- Stored Energy and Reserve cannot become negative.
- Reserve cannot exceed capacity.
- Delivered power cannot exceed both generation and transmission.
- Locked content cannot be purchased.
- Offline progress cannot exceed its configured cap.
- A missing content reference fails validation rather than silently substituting an item.
