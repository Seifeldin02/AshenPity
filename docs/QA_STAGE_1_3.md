# QA Stage 1.3

## Scope

This QA note covers the Stage 1.3 combat identity sandbox:

- light combo
- heavy attack
- dodge and perfect dodge
- Ash Brand
- Collect
- enemy variants
- Ash Trial waves
- debug and performance readout
- mobile control surface

## Automated Logic Tests

Command:

```powershell
godot_console --headless --path . -s tests/test_runner.gd
```

Coverage includes:

- stamina cannot spend below zero
- stamina regeneration
- dodge requires enough stamina
- 120 Hz physics configuration
- enemy damage application
- dodge invulnerability timing
- movement input normalization
- route bounds
- camera coverage math
- world-space aim direction
- frame-rate-independent movement math
- attack buffering math
- perfect-dodge timing math
- Ash Brand hit progress and Collect readiness
- enemy configuration presence

## Deterministic Playtest Harness

Commands:

```powershell
godot_console --path . --fixed-fps 120 --scene res://tests/PlaytestHarness.tscn
godot_console --path . --fixed-fps 60 --scene res://tests/PlaytestHarness.tscn
```

The harness uses `InputRouter` instead of bypassing normal gameplay input. It sets up positions between scenarios, then drives movement and actions through the same input layer used by desktop and mobile controls.

Coverage includes:

- movement through route checkpoints
- visibility screenshots when a display renderer is available
- actor variant screenshots
- mouse/world aim calculations
- light attack while moving
- heavy attack
- dodge using movement direction
- dodge using facing direction while stationary
- perfect dodge through an enemy attack
- Ash Brand application
- Brand hit progress
- Collect execution and Brand consumption
- flask interruption by enemy damage
- clearing the full Ash Trial

Local artifacts are written to ignored `playtest_artifacts/`.

## Runtime Smoke Test

Command:

```powershell
godot_console --path . --quit-after 180
```

This catches boot-time parse/runtime errors with a display renderer. It does not replace a human play session.

## Known Automation Limits

- The harness cannot judge whether combat feels fun, readable, or satisfying.
- The harness does not replace real mouse and keyboard play at a monitor refresh rate.
- The harness uses deterministic setup between scenarios and is not a full natural playthrough.
- The Bell-Bearer is tested as an elite encounter, not as a final production boss.
- Mobile controls still need real landscape phone testing.

## Human Playtest Priorities

1. Judge whether perfect dodge into Ash Brand into Collect feels earned, readable, and worth using.
2. Judge whether light combo, heavy attack, dodge recovery, and stamina costs feel aggressive without becoming spammy.
3. Judge whether the four enemy silhouettes and telegraphs are readable during actual movement and camera follow.
