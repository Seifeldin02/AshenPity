# File Map

## Player And Combat

- `scripts/player/PlayerController.gd`
  - Player movement, stamina, light combo, heavy attack, dodge, perfect dodge, Ash Brand targeting, Collect, flask, hurt, death, hitboxes, and combat state names.
- `scripts/player/PlayerVisual.gd`
  - Sprite-based player presentation using `assets/sprites/kenney/player_*.png`, attack slash textures, dodge afterimages, hit flash, and shadow.
- `scripts/autoload/GameBalance.gd`
  - Central editable values for speed, stamina costs, combo timings, damage, stagger, knockback, dodge timing, perfect-dodge window, Ash Brand rules, enemy health, and enemy attack tuning.
- `scripts/combat/CombatMath.gd`
  - Pure combat math used by tests: stamina spend, normalization, aim direction, attack buffering, invulnerability, perfect dodge, and Collect readiness.

## Enemies

- `scripts/enemies/ShrineGuardian.gd`
  - Shared enemy controller for Shrine Guardian, Ashbound Hound, Reliquary Archer, and Bell-Bearer. Owns AI states, attacks, projectiles, Brand state, stagger, death, and enemy audio cues.
- `scripts/enemies/ShrineGuardianVisual.gd`
  - Sprite-based enemy visuals using `assets/sprites/kenney/melee_*`, `hound_*`, `archer_*`, and `elite_*`, plus telegraphs, Brand rings, attack slashes, stagger stars, and death smoke.
- `scripts/enemies/EnemyProjectile.gd`
  - Reliquary Archer projectile movement, hit detection, player damage, and perfect-dodge interaction.
- `scenes/enemies/ShrineGuardian.tscn`
  - Shared enemy scene with body collision, attack area, particles, and visual child.

## Ash Trial

- `scripts/trial/AshTrial.gd`
  - Wave setup, spawn points, enemy kind selection, wave transitions, trial completion, and replay reset.
- `scripts/world/ShrineArena.gd`
  - Runtime assembly for the shrine scene, player/trial/HUD/mobile controls, camera follow, hit stop, screen shake, hit VFX, perfect-dodge VFX, and debug overlay.

## Audio And VFX

- `scripts/autoload/CombatAudio.gd`
  - Loads Kenney OGG files from `assets/audio/kenney/` and plays named cues. Procedural tones remain as fallback if files are missing.
- `scripts/effects/CombatEffect.gd`
  - Texture-based hit sparks, heavy impact, Collect cross-cut, Ash Brand pulse, perfect-dodge flash, and death smoke using `assets/effects/kenney/`.

## Assets

- `assets/sprites/kenney/`
  - Curated, enlarged character sprite frames.
- `assets/effects/kenney/`
  - Curated slash, spark, smoke, star, and twirl textures.
- `assets/audio/kenney/`
  - Curated combat OGG sounds.
- `assets/third_party/kenney/licenses/`
  - CC0 license/source notes for the curated asset sources.

## Input And UI

- `scripts/autoload/InputRouter.gd`
  - Shared desktop, mobile, and test input state for move, aim, light attack, heavy attack, dodge, flask, Collect, pause, debug, and mobile controls.
- `scripts/ui/HUD.gd`
  - HUD bars, enemy health, Ash Brand/Collect prompt, wave labels, trial-complete panel, build label, and debug/performance overlay.
- `scripts/ui/MobileControls.gd`
  - Virtual joystick, aim drag, attack, heavy, dodge, flask, Collect, pause, and desktop mobile-toggle support.

## Level And Camera

- `scripts/world/ShrineRoute.gd`
  - Shrine route geometry, camera limits, player start, obstacles, walls, torches, props, and spawn anchors.
- `scripts/world/ShrineRouteLayer.gd`
  - Ground, cracks, ash, walls, torches, masonry, and environmental drawing.

## Tests

- `tests/test_runner.gd`
  - Headless logic tests.
- `tests/playtest_harness.gd`
  - Deterministic in-game playtest harness using `InputRouter`.
- `tests/PlaytestHarness.tscn`
  - Scene wrapper for the playtest harness.
