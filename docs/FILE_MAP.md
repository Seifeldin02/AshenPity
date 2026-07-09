# File Map

## Player And Combat

- `scripts/player/PlayerController.gd`
  - Player movement, stamina, light combo, heavy attack, heavy anti-spam chain cost, dodge cancel, parry, perfect dodge, Ash Brand targeting, Collect, flask, hurt, death, hitboxes, and combat state names.
- `scripts/player/PlayerVisual.gd`
  - Sprite-based player presentation using `assets/sprites/upgrade/player_*.png`, bounded vector slash arcs, dodge afterimages, hit flash, and shadow.
- `scripts/autoload/GameBalance.gd`
  - Central editable values for speed, stamina costs, combo timings, damage, stagger, knockback, dodge timing, perfect-dodge window, Ash Brand rules, enemy health, and enemy attack tuning.
- `scripts/combat/CombatMath.gd`
  - Pure combat math used by tests: stamina spend, normalization, aim direction, attack buffering, invulnerability, perfect dodge, and Collect readiness.

## Enemies

- `scripts/enemies/ShrineGuardian.gd`
  - Shared enemy controller for Shrine Guardian, Ashbound Hound, Reliquary Archer, Bell-Bearer, and Ashen Judicator. Owns AI states, lateral pressure, parry response, attacks, projectiles, boss attack patterns, counter/rear-hit punish rules, Brand state, stagger, death, and enemy audio cues.
- `scripts/enemies/ShrineGuardianVisual.gd`
  - Sprite-based enemy visuals using `assets/sprites/upgrade/melee_*`, `hound_*`, `archer_*`, `elite_*`, and `judicator_*`, plus telegraphs, Brand rings, bounded attack arcs, boss pattern tells, stagger sparks, and death smoke.
- `scripts/enemies/EnemyProjectile.gd`
  - Reliquary Archer and Judicator projectile movement, hit detection, player damage, parry, and perfect-dodge interaction.
- `scenes/enemies/ShrineGuardian.tscn`
  - Shared enemy scene with body collision, attack area, particles, and visual child.

## Ash Trial

- `scripts/trial/AshTrial.gd`
  - Seven-stage Ash Trial setup, spawn points, enemy kind selection, wave transitions, final Judicator encounter, trial completion, and replay reset.
- `scripts/world/ShrineArena.gd`
  - Runtime assembly for the shrine scene, player/trial/HUD/mobile controls, camera follow, hit stop, screen shake, hit VFX, perfect-dodge VFX, and debug overlay.

## Audio And VFX

- `scripts/autoload/CombatAudio.gd`
  - Loads curated OGG files from `assets/audio/upgrade/` and plays named cues. Procedural tones remain as fallback if files are missing.
- `scripts/effects/CombatEffect.gd`
  - Bounded hit sparks, heavy impact, Collect cross-cut, Ash Brand pulse, perfect-dodge flash, and death smoke using `assets/effects/upgrade/` plus vector lines/arcs.

## Assets

- `assets/sprites/upgrade/`
  - Current runtime player and enemy sprite frames, including generated Judicator variants.
- `assets/effects/upgrade/`
  - Current runtime spark, flame, smoke, and blood/impact textures.
- `assets/audio/upgrade/`
  - Current runtime combat OGG sounds.
- `assets/environment/upgrade/`
  - Current runtime stone floor/wall textures plus raster torch, pillar, broken wall, stairs, brazier, sealed door, bone debris, and reliquary prop sprites.
- `assets/third_party/upgrade_licenses/`
  - License/source notes for the curated public asset sources.

## Input And UI

- `scripts/autoload/InputRouter.gd`
  - Shared desktop, mobile, and test input state for move, aim, light attack, heavy attack, dodge, parry, flask, Collect, pause, debug, and mobile controls.
- `scripts/ui/HUD.gd`
  - HUD bars, enemy health, Ash Brand/Collect prompt, wave labels, trial-complete panel, build label, and debug/performance overlay.
- `scripts/ui/MobileControls.gd`
  - Virtual joystick, aim drag, attack, heavy, dodge, parry, flask, Collect, pause, and desktop mobile-toggle support.

## Level And Camera

- `scripts/world/ShrineRoute.gd`
  - Shrine route geometry, expanded room rectangles, camera limits/zoom, player start, obstacles, walls, torches, props, and spawn anchors.
- `scripts/world/ShrineRouteLayer.gd`
  - Naturalized ground slabs, texture grain, route shapes, cracks, ash, torch light pools, room landmarks, generated prop rasters, and environmental drawing.
- `scripts/world/ShrineWallVisual.gd`
  - Textured wall, broken wall, and altar rendering for the tall Y-sorted prop layer.
- `scripts/world/ShrineProp.gd`
  - Raster torch and pillar prop drawing in the Y-sorted actor/tall-prop layer.

## Tests

- `tests/test_runner.gd`
  - Headless logic tests.
- `tests/playtest_harness.gd`
  - Deterministic in-game playtest harness using `InputRouter`.
- `tests/PlaytestHarness.tscn`
  - Scene wrapper for the playtest harness.
