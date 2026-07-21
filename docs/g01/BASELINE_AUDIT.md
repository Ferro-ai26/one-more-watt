# G01 Baseline First-Hour Audit

Status: Deterministic baseline; not player evidence

## Current route

The canonical earned-currency Eras 1–4 route remains deterministic and passes 1,393 reachability/balance checks:

- 115.4 mechanical minutes and 135.5 structured-model minutes through Era 4
- Era 2 at 11.7 minutes and Era 3 at 37.0 minutes
- 22.3 minutes of explicit idle earning
- 300-second longest modeled purchase gap
- 1,625.2 seconds of recoverable brownout
- 34 purchases

At the 30-minute deterministic point the route is still in Era 2. At 60 minutes it is at the late Era 3 purchase/request boundary. These positions are scripted-route estimates only; the G01 recorder will capture observed 10/30/60-minute states without coaching or injected currency.

## Baseline risks to observe

- The optimized route reaches the documented five-minute purchase-gap ceiling, so the observed session must distinguish forced stalls from voluntary planning or unknown inactivity.
- Reachability uses a fixed purchase route and cannot establish whether alternate purchases are legible or viable.
- The accumulated brownout total proves recoverability, not whether feedback is understandable or enjoyable.
- Existing recommendation text may make the intended route easy to follow without establishing that the player understands the tradeoff.
- Automated route duration excludes real report/dialogue reading and subjective decision time.

## Category distinction matrix

| Category | Current mechanical identity | Representative requests | Baseline question |
| --- | --- | --- | --- |
| Capacity | Sustained request energy against continuous demand and useful-power cap | `era01_finish_booting`, `era02_organize_photographs`, `era05_coordinate_community_solar` | Does sustained Generation/Transmission preparation feel different from following the displayed bottleneck? |
| Stability | Deterministic changing demand scored by served energy, brownout duration, and ending Reserve | `era01_basic_arithmetic`, `era03_predict_package_arrival`, `era05_restore_evening_service` | Does the player prepare headroom and interpret service quality rather than merely accept a slower bar? |
| Burst | Authored peaks test Reserve amount and discharge support | `era01_understand_tuesdays`, `era02_rewrite_text_message`, `era04_stabilize_shared_backup` | Can the player anticipate the peak and explain why Reserve changed the outcome? |
| Research | Request power plus an atomic, disclosed Stored Energy authorization cost | `era01_friendlier_thanks`, `era03_write_grocery_list`, `era05_automate_routine_switchovers` | Does the upfront opportunity cost compete visibly with grid expansion? |
| Vanity | Optional request with non-blocking cosmetic/dialogue utility | `era01_larger_loading_dot`, `era03_rename_every_device`, `era05_synchronize_porches` | Is opting in or skipping an expressive choice rather than a hidden optimal path? |

The labels and data shapes are distinct. G01 has not yet demonstrated that the resulting player decisions feel distinct or meaningful.
