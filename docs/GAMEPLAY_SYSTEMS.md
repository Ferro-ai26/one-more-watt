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

### Stored Energy

Stored Energy is the ordinary construction currency. It represents long-term surplus captured by the grid and is separate from short-duration Reserve.

Only the share of surplus assigned to grid expansion becomes Stored Energy. Request-dedicated power does not simultaneously generate construction currency.

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

### Completion

Progress never moves backward. Completion grants rewards once, records performance, unlocks content, and queues a report.

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

## Milestones and relevance

Count milestones occur at 10, 25, 50, 100, 250, 500, and 1,000 owned when applicable. Milestones may increase that item's output or activate a synergy.

Later systems should multiply categories or earlier assets rather than making them irrelevant. Examples include substations boosting outlets, Dyson Swarms boosting Solar-tagged infrastructure, and wormhole transmission boosting Extension Cord-tagged assets.

## Automation

Automation unlocks before long idle waits. Prototype automation may include:

- Automatic Reserve charging priority
- Stored Energy purchase targets
- Low-Reserve throttling
- Automatic request start for explicitly queued requests
- A forecast warning before high demand

Automation defaults must be safe and understandable. Players can disable or override it.

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

