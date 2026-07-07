# Editing Guide

## Rules For This Stage

- Keep the world small.
- Do not add relics, pity systems, currency, shops, permanent progression, procedural generation, weapon selection, or a full boss.
- Keep values centralized in `scripts/autoload/GameBalance.gd`.
- Keep desktop and mobile controls routed through `InputRouter`.
- Run tests before committing.

## Tuning Player Movement

Edit `scripts/autoload/GameBalance.gd`:

- `PLAYER_MOVE_SPEED`
- `PLAYER_ACCELERATION`
- `PLAYER_DECELERATION`
- `PLAYER_DODGE_SPEED`
- `PLAYER_DODGE_DURATION`
- `PLAYER_DODGE_INVULNERABLE`
- `PLAYER_DODGE_RECOVERY`
- `PLAYER_PERFECT_DODGE_WINDOW`

The movement implementation is in `scripts/player/PlayerController.gd`. It should stay in `_physics_process` and use `delta`.

## Tuning Attacks

Edit `scripts/autoload/GameBalance.gd`:

- `LIGHT_COMBO`
- `HEAVY_ATTACK`
- `COLLECT_ATTACK`
- `PLAYER_ATTACK_COST`
- `PLAYER_HEAVY_COST`
- `PLAYER_COLLECT_COST`
- `PLAYER_ATTACK_BUFFER_WINDOW`

Each attack dictionary controls startup, active time, recovery, damage, stagger damage, range, arc width, knockback, lunge speed, and lunge duration.

The player controller consumes those dictionaries. Avoid copying timing numbers into the controller.

## Tuning Ash Brand

Edit `scripts/autoload/GameBalance.gd`:

- `ASH_BRAND_DURATION`
- `ASH_BRAND_HITS_TO_COLLECT`
- `COLLECT_TARGET_RANGE`
- `PLAYER_PERFECT_DODGE_WINDOW`

The Brand flow is split across player and enemy:

- Player detects perfect dodge and starts Collect.
- Enemy stores Brand duration and hit progress.
- HUD and mobile controls show Collect readiness.

## Tuning Enemies

Edit `ENEMY_CONFIGS` in `scripts/autoload/GameBalance.gd`.

Each enemy kind can define:

- health
- speed
- detection range
- attack range
- damage
- stagger threshold
- windup, active, and recovery timing
- attack size
- projectile use
- Bell-Bearer alternate attack timing

The current enemy kinds are:

- `guardian`
- `hound`
- `archer`
- `bell_bearer`

## Changing The Ash Trial

Edit `scripts/trial/AshTrial.gd`.

Keep the encounter compact. Stage 1.3 is for a small combat sandbox, not a campaign.

## Changing The Level

Edit `scripts/world/ShrineRoute.gd` for route data and `scripts/world/ShrineRouteLayer.gd` for world drawing.

Do not put floor art into the Y-sorted actor layer. Ground, decals, and shadows must stay outside the actor/tall-prop sort layer.

## Changing Visuals

- Player visual: `scripts/player/PlayerVisual.gd`
- Enemy visuals: `scripts/enemies/ShrineGuardianVisual.gd`
- Combat effects: `scripts/effects/CombatEffect.gd`

All current visuals are original code-drawn shapes. Do not add commercial-game rips or unverified sprites.

## Changing Audio

Current audio is generated procedurally in `scripts/autoload/CombatAudio.gd`.

If external audio is added later, put it under `assets/third_party/`, include the license file, and update `docs/ASSET_CREDITS.md`.

## Required Checks

Run:

```powershell
godot_console --headless --path . -s tests/test_runner.gd
godot_console --path . --fixed-fps 120 --scene res://tests/PlaytestHarness.tscn
godot_console --path . --fixed-fps 60 --scene res://tests/PlaytestHarness.tscn
godot_console --path . --quit-after 180
```

The display harness writes local artifacts to `playtest_artifacts/`, which is ignored by Git.
