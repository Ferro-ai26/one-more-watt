# Progression and Balance Specification

## Status

This document supplies a playable first-pass economy for Eras 1–3 and scaling rules for implementation. Values are tuning data. Change them in data files and record material changes in `DECISION_LOG.md`.

## Design targets

| Milestone | First-run target |
| --- | ---: |
| First completed request | 20–30 seconds |
| First infrastructure purchase | Under 60 seconds |
| Allocation mode introduced | 2–3 minutes |
| First automatic generation | Under 4 minutes |
| First harmless brownout | 5–8 minutes |
| Era 2 arrival | 10–15 minutes |
| Transmission introduced | 18–25 minutes |
| Reserve becomes strategically relevant | 25–35 minutes |
| Era 3 arrival | 30–45 minutes |
| Prototype content completion | 75–120 minutes |

These are elapsed first-run targets, not required continuous screen time.

## Cost formula

Infrastructure uses geometric cost growth:

```text
next_cost = floor(base_cost × growth_rate ^ owned_count)
```

Recommended growth rates:

- High-volume basic equipment: 1.13–1.16
- Standard equipment: 1.16–1.19
- Major facilities: 1.20–1.24
- Unique infrastructure: authored fixed cost

Bulk-purchase costs must equal the sum of individual sequential prices, allowing only final display rounding.

## Production multipliers

Multipliers are grouped and applied consistently:

```text
item_output = base_output
            × item_upgrade_multiplier
            × milestone_multiplier
            × category_multiplier
            × global_multiplier
            × prestige_multiplier
```

Add multipliers within a named group only when explicitly documented; multiply different groups. This prevents ambiguous stacking.

## Milestone baseline

| Owned | Suggested cumulative multiplier |
| ---: | ---: |
| 10 | ×2 |
| 25 | ×4 |
| 50 | ×8 |
| 100 | ×16 |
| 250 | ×40 |
| 500 | ×100 |
| 1,000 | Special achievement/synergy |

Exact milestones may vary by unique or low-volume infrastructure.

## Era 1 initial economy — Cold Boot

Starting state:

- Generation: 5 W
- Transmission: 8 W
- Reserve: 0/10 joule-equivalent units
- Stored Energy: 0
- Allocation: Balanced after it unlocks; tutorial directs all usable power contextually before then
- Infrastructure: 1 Wall Outlet and WATT's old computer are represented visually; the outlet is the first counted producer

| Infrastructure | Category | Base cost | Growth | Base effect |
| --- | --- | ---: | ---: | --- |
| Wall Outlet | Generation | 10 | 1.15 | +5 W generation |
| Questionable Power Strip | Transmission | 35 | 1.17 | +18 W transmission |
| Laptop Battery | Reserve | 60 | 1.18 | +30 reserve, +8 W discharge |
| Tiny Desk Fan | Support | 100 | 1.18 | +10% request efficiency for Cold Boot |
| Extension Cord | Transmission | 180 | 1.16 | +75 W transmission |

Era 1 should contain five main requests and one optional vanity request. Main-request energy requirements should rise from approximately 75 to 1,500 energy units.

The Phase 05 `Finish Booting` sample awards 12 Stored Energy. With one starting Wall Outlet, the exact next-outlet cost is 11, leaving one Stored Energy after the first purchase and satisfying the onboarding requirement that the first completion funds a visible improvement.

Era 2 unlock rule: complete the Era 1 capstone request `Understand Tuesdays` and own at least one Reserve item.

## Era 2 initial economy — Bedroom Assistant

| Infrastructure | Category | Base cost | Growth | Base effect |
| --- | --- | ---: | ---: | --- |
| Upgraded Breaker | Transmission | 450 | 1.17 | +250 W transmission |
| Portable Generator | Generation | 700 | 1.16 | +120 W generation |
| Rooftop Solar Panel | Generation/Solar | 1,100 | 1.15 | +180 W generation |
| Home Battery | Reserve | 1,800 | 1.18 | +700 reserve, +150 W discharge |
| Second Questionable Power Strip | Transmission | 2,400 | 1.17 | +900 W transmission |
| Gaming GPU | Generation/Compute | 4,000 | 1.20 | +650 W generation; increases WATT demand by 5% while active |

Era 2 introduces automatic production, allocation control, reserve spikes, and the first brownout. Main request requirements should range from approximately 3,000 to 45,000 energy units.

Era 3 unlock rule: complete `Improve Loading Animation`, reach 85% or greater service on one Stability request, and purchase the Dedicated Circuit research upgrade.

## Era 3 initial economy — Home Server Closet

| Infrastructure | Category | Base cost | Growth | Base effect |
| --- | --- | ---: | ---: | --- |
| Server Rack | Generation/Compute | 12,000 | 1.18 | +2.5 kW generation equivalent |
| Whole-Home Battery | Reserve | 22,000 | 1.19 | +12 k reserve, +3 kW discharge |
| Backup Generator | Generation | 30,000 | 1.17 | +7 kW generation |
| Smart Meter | Automation | 45,000 | 1.22 | Unlock forecast detail and reserve thresholds |
| Dedicated Cooling | Support | 65,000 | 1.19 | +20% Compute output |
| Reinforced Wiring | Transmission | 90,000 | 1.18 | +30 kW transmission |
| Outdoor Transformer | Transmission | 160,000 | 1.20 | +85 kW transmission |

Era 3 main request requirements should range from approximately 150,000 to 2,500,000 energy units and take 3–6 minutes when reasonably prepared.

Prototype completion rule: complete the Era 3 capstone `Determine Whether Leftovers Remain Edible` and view its performance report.

## Request duration calculation

Data defines a `required_energy` and `max_useful_power`.

```text
useful_power = min(allocated_watt_power, max_useful_power)
raw_seconds = required_energy / useful_power
```

The request preview estimates duration using current grid values and known demand events. It should state that estimates may change when allocation or infrastructure changes.

For prototype requests, underpower efficiency has a floor of 5% whenever at least 1 W reaches WATT. Zero delivered power produces zero progress.

## Stability scoring

Initial performance score:

```text
served_ratio = served_energy / demanded_energy
brownout_penalty = min(20, brownout_seconds / request_seconds × 40)
reserve_bonus = min(5, ending_reserve_ratio × 5)
stability_score = clamp(100 × served_ratio - brownout_penalty + reserve_bonus, 0, 100)
```

Performance grade:

- S: 98–100
- A: 90–97.99
- B: 75–89.99
- C: 50–74.99
- D: below 50

Main progression does not require an S grade. Optional rewards may reward high grades.

## Stored Energy conversion

The grid allocation share converts eligible surplus into Stored Energy at a configurable efficiency.

- Era 1 efficiency: 100%
- Era 2 efficiency: 95%
- Era 3 efficiency: 90%

Efficiency reduction is a balancing mechanism representing storage/management overhead. Upgrades can recover it. The UI displays effective income, not a hidden loss.

## Offline prototype values

- Offline progress unlocks during Era 2.
- Initial maximum offline duration: 2 hours.
- Initial offline efficiency: 80%.
- Smart Meter upgrade increases cap to 4 hours and efficiency to 90%.
- No offline simulation occurs for an unacknowledged tutorial that requires interaction.
- Active requests may complete offline, but the next main request does not auto-start unless request-queue automation is unlocked and enabled.

## First prestige framework

The first prestige is not implemented in the prototype but its data interfaces must not be blocked.

Provisional Model Weight reward:

```text
model_weights = floor(
    (lifetime_energy / city_reference_energy) ^ 0.35
    + completed_major_requests × 0.25
    + highest_stable_peak / city_reference_peak
)
```

The formula will be tuned in Phase 12. The preview must always use the same function that performs the award.

## Balance guardrails

- A player should not need to watch an unchanging screen for more than 30 seconds during the first five minutes.
- No single required purchase should demand more than five minutes of waiting before Era 3.
- A new bottleneck must be explained before it can meaningfully delay progression.
- Automation unlocks before the system it automates becomes repetitive.
- An obviously poor allocation choice must be recoverable immediately.
- The optimal choice should change based on request type and current bottleneck.
- Prestige must reduce repeated early-game time materially, not merely add a small percentage.

## Telemetry-free balancing

Until analytics is explicitly approved, balance through deterministic simulation reports and manual playtests. Record:

- Time to each request and era
- Purchases at each milestone
- Seconds spent with no affordable action
- Brownout count and cause
- Allocation-mode changes
- Offline return outcome
- Points of confusion or loss of interest
