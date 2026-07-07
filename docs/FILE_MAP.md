# File Map

## Player

- `scripts/player/PlayerController.gd`
  - Player movement, acceleration, deceleration, mouse facing, stamina, flask, hurt/death, dodge, perfect-dodge timing, light combo, heavy attack, Ash Brand tracking, Collect execution, attack hitboxes, hit stop signals, and playtest reset hooks.
- `scripts/player/PlayerVisual.gd`
  - Hooded wanderer drawing, cloak bob, mask, sword orientation, slash trails, dodge trail, shadow, hurt flash, and pose rendering.
- `scenes/player/Player.tscn`
  - Player scene root, collision, hitbox, hurtbox, and visual child wiring.

## Player Combat Tuning

- `scripts/autoload/GameBalance.gd`
  - Edit player speed, acceleration, stamina, light combo dictionaries, heavy attack dictionary, Collect attack dictionary, dodge duration, invulnerability, perfect-dodge window, Ash Brand duration, Brand hit threshold, damage, stagger, ranges, and costs here.
- `scripts/combat/CombatMath.gd`
  - Pure math for normalized input, stamina spend, invulnerability, attack buffering, aim direction, route bounds, perfect dodge, and Collect readiness.

## Input

- `scripts/autoload/InputRouter.gd`
  - Desktop, mobile, and simulated test input state.
- `scripts/ui/MobileControls.gd`
  - Virtual joystick, aim drag zone, attack, heavy, dodge, flask, Collect, pause, and desktop mobile-control toggling.
- `scenes/ui/MobileControls.tscn`
  - Mobile control layout.

## Ash Brand And Collect

- `scripts/player/PlayerController.gd`
  - Detects perfect dodge, stores the current Branded target, validates Collect, starts Collect, and consumes the Brand.
- `scripts/enemies/ShrineGuardian.gd`
  - Applies Brand, tracks Brand hit progress, exposes Collect readiness, and consumes Brand.
- `scripts/enemies/ShrineGuardianVisual.gd`
  - Draws Brand ring, particles, and Collect-ready visual state.
- `scripts/ui/HUD.gd`
  - Shows Ash Brand and Collect HUD state.
- `scripts/ui/MobileControls.gd`
  - Shows the mobile Collect button only while usable.

## Enemies

- `scripts/enemies/ShrineGuardian.gd`
  - Shared enemy controller for `guardian`, `hound`, `archer`, and `bell_bearer`.
  - Controls idle, patrol, chase, windup, attack active, recovery, stagger, dying, death, hit reactions, projectile firing, and Brand state.
- `scripts/enemies/ShrineGuardianVisual.gd`
  - Draws Guardian armor, Hound low silhouette, Archer bow silhouette, Bell-Bearer elite silhouette, telegraphs, attacks, shadows, stagger flash, and death dissolve.
- `scripts/enemies/EnemyProjectile.gd`
  - Reliquary Archer projectile behavior, collision, damage, and perfect-dodge interaction.
- `scenes/enemies/ShrineGuardian.tscn`
  - Enemy scene with shared collision, hitbox, attack area, and visual node.

## Enemy Tuning

- `scripts/autoload/GameBalance.gd`
  - `ENEMY_CONFIGS` sets health, speed, detection, attack range, damage, stagger threshold, attack timing, projectile use, and Bell-Bearer alternate attack timing.

## Ash Trial

- `scripts/trial/AshTrial.gd`
  - Wave definitions, spawn positions, active enemy tracking, wave start signals, trial completion, and replay reset.
- `scripts/world/ShrineArena.gd`
  - Instantiates the trial, binds enemies to HUD/debug, receives hit/perfect-dodge/trial signals, and displays the completion summary.

## Level Layout

- `scripts/world/ShrineRoute.gd`
  - Shrine route bounds, camera limits, player start, trial/legacy spawn points, walls, obstacles, torches, props, pillars, and landmarks.
- `scripts/world/ShrineRouteLayer.gd`
  - Ground, decals, ash, cracks, masonry, torch pools, walls, and foreground route drawing.
- `scripts/world/ShrineArena.gd`
  - Builds collision, render layers, camera following, route props, and actor/tall-prop Y-sort structure.

## UI

- `scripts/ui/HUD.gd`
  - Health, stamina, flask count, enemy health, Ash Brand prompt, wave label, pause/death/trial panels, debug overlay, performance readout, and build label.
- `scenes/ui/HUD.tscn`
  - HUD node layout.
- `scripts/ui/TitleScreen.gd`
  - Title screen build label and start/quit callbacks.
- `scenes/menu/TitleScreen.tscn`
  - Title screen layout.

## Audio And VFX

- `scripts/autoload/CombatAudio.gd`
  - Original procedural audio cues for sword whoosh, light hit, heavy hit, armor hit, stagger, perfect dodge, Ash Brand, Collect, player hurt, dodge, flask, and enemy death.
- `scripts/effects/CombatEffect.gd`
  - Temporary drawn combat effects for sparks, heavy impacts, Collect, Brand, perfect dodge, and death bursts.

## Tests

- `tests/test_runner.gd`
  - Headless pure logic tests.
- `tests/playtest_harness.gd`
  - Deterministic in-game playtest scenarios using `InputRouter`.
- `tests/PlaytestHarness.tscn`
  - Scene wrapper for the harness.

## Build Label

- `scripts/autoload/BuildInfo.gd`
  - Build version string and short Git commit hash for HUD/debug/title display.
