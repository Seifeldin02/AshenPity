# Architecture

## Scene Flow

- `scenes/boot/Boot.tscn` starts the project.
- `scripts/autoload/SceneFlow.gd` owns high-level scene transitions.
- `scenes/menu/TitleScreen.tscn` displays the build label and starts the arena.
- `scenes/arena/ShrineArena.tscn` assembles the world, player, HUD, mobile controls, camera, and Ash Trial.

## Render Structure

The world scene keeps gameplay actors out of UI layers.

```text
World
  Ground
  GroundDecals
  Shadows
  ActorsAndTallProps (Y-sorted)
    Player
    Enemies
    Pillars
    Torches
    Broken walls
    Altar props
  ForegroundCanopy
  Collision
  Camera2D

UI (CanvasLayer scenes)
  HUD
  Pause panel
  Mobile controls
  Debug overlay
```

Ground art is not Y-sorted with actors. Player, enemies, and tall props share the same Y-sorted layer so actors can pass behind pillars without disappearing behind the floor.

## Gameplay Input

`scripts/autoload/InputRouter.gd` is the shared input abstraction.

Desktop input, mobile buttons, touch drag aim, and deterministic playtest inputs all resolve into the same movement, aim, attack, heavy, dodge, collect, flask, pause, debug, and mobile-toggle state.

Gameplay scripts should read intent from `InputRouter` rather than duplicating direct input handling.

## Combat Ownership

- `scripts/autoload/GameBalance.gd` owns timing, stamina, damage, range, stagger, and enemy tuning values.
- `scripts/player/PlayerController.gd` owns the player combat state machine.
- `scripts/enemies/ShrineGuardian.gd` owns the configurable enemy finite state machine.
- `scripts/combat/CombatMath.gd` owns pure helper math that can be unit tested.
- `scripts/trial/AshTrial.gd` owns the encounter waves.

Rendering and feedback are separate where practical:

- `scripts/player/PlayerVisual.gd` draws player silhouettes, slash trails, dodge trails, and hit flash.
- `scripts/enemies/ShrineGuardianVisual.gd` draws all current enemy silhouettes and Brand indicators.
- `scripts/effects/CombatEffect.gd` creates temporary hit, Brand, perfect-dodge, Collect, and death effects.
- `scripts/autoload/CombatAudio.gd` creates original procedural combat audio cues at runtime.

## Performance Direction

- Physics is configured for 120 ticks per second.
- Movement and combat timers use `delta`.
- V-Sync is enabled by default and the game is not hard locked to 120 FPS.
- `scripts/autoload/PerformanceStats.gd` tracks FPS, frame time, p95 frame time, display refresh rate, physics tick rate, active enemies, and lightweight mode.
- `F1` shows diagnostics. `F2` toggles lightweight performance mode.

## Mobile Direction

Mobile controls are implemented as a `CanvasLayer` UI that writes to `InputRouter`. The same player controller handles desktop and touch input. Stage 1.3 adds a Collect button that appears only when usable.

No production Android export is attempted in this milestone.
