# Ashen Pity

Ashen Pity is an original 2D top-down dark-fantasy action roguelite prototype built in Godot 4 with GDScript.

This repository is the real Godot foundation for the project. The older Raylib technical prototype is intentionally not reused, copied, migrated, inspected, or depended on.

## Current Prototype Scope

Stage 1 is a compact combat foundation:

- Title screen into a shrine arena.
- One playable hooded cursed wanderer.
- Mouse-aimed sword attacks.
- Stamina, dodge roll, healing flask, hit reactions, and death.
- Three Shrine Guardians with telegraphed melee attacks.
- Minimal victory flow back to title.
- Desktop and mobile-oriented controls.

This stage does not include relic pulls, pity systems, permanent upgrades, shops, bosses, save files, procedural generation, character selection, or long-term progression.

## PC Controls

- `WASD`: Move
- Mouse: Aim
- Left mouse: Light attack
- `Space`: Dodge roll
- `F`: Healing flask
- `Escape`: Pause
- `F1`: Debug overlay
- `F2`: Toggle lightweight performance mode
- `M`: Toggle mobile controls for desktop testing

## Mobile Controls

- Left virtual joystick: Move
- Right drag zone: Aim
- Attack button: Light attack
- Dodge button: Dodge roll
- Flask button: Heal
- Pause button: Pause

The mobile controls are shown on touch devices and can be toggled on desktop with `M`.

## Setup

Requirements:

- Godot 4 Standard edition
- Git
- GitHub CLI, optional for publishing

Open the project folder in Godot 4 and run the project. The main scene is `scenes/boot/Boot.tscn`.

## Run From Command Line

```powershell
godot --path .
```

For tests:

```powershell
godot --headless --path . -s tests/test_runner.gd
godot --headless --path . --scene res://tests/PlaytestHarness.tscn
```

## Project Structure

```text
scenes/boot/      startup scene
scenes/menu/      title, victory, and pause flows
scenes/arena/     shrine combat room
scenes/player/    player scene
scenes/enemies/   Shrine Guardian scene
scenes/ui/        HUD and touch controls
scripts/          gameplay, combat, input, UI, and world scripts
assets/           original sprites, environment art, UI, effects, audio placeholders
docs/             roadmap, mobile notes, and devlog
tests/            headless gameplay logic tests
tools/            local helper scripts
```

## Current State

Stage 1.1 is playable as a local prototype. The player can enter a connected shrine route, fight three Shrine Guardians, die and restart, or clear the route and reach the victory screen.

Implemented foundation:

- Original code-drawn 2D dark shrine route with walls, cracks, ash, torchlight, and layered props.
- Hooded cursed wanderer player with readable mask, cloak, sword, hit flash, dodge dust, and slash arcs.
- Mouse-facing light attack with anticipation, active frames, recovery, stamina cost, knockback, hit stop, and screen shake.
- Stamina, health, two-charge healing flask, interruptible healing, death prompt, and pause flow.
- Shrine Guardian enemy with patrol, chase, telegraph, attack, recovery, stagger, ash dissolve, and health UI.
- Mobile controls that can be shown on touch devices or toggled on desktop with `M`.
- Headless gameplay test runner for core combat logic.
- Deterministic playtest harness for movement, visibility, aim, attack, dodge, flask interruption, and clearing three guardians.

## Refresh Rate and Diagnostics

- Physics runs at 120 ticks per second.
- V-Sync is enabled by default; the game is not hard-locked to 120 FPS.
- The prototype targets 60/90/120 Hz displays and should use the device display refresh rate where supported.
- Press `F1` to show FPS, display refresh rate, average frame time, p95 frame time, physics tick rate, active enemy count, player state, and performance mode.
- Press `F2` to toggle lightweight performance mode, which currently reduces selected particle/decal load for future mobile testing.

## Shrine Route

The current level is a compact three-part route:

- Shrine Entrance Hall: start area with broken walls, torches, and a side alcove.
- Central Shrine Arena: irregular combat space with pillars, broken walls, and a cracked ash brazier landmark.
- Broken Altar Platform: northern destination with stairs, a raised-looking platform, and a broken altar.

## Known Limitations

- Art is hand-authored prototype vector work, not final production art.
- Audio is represented by placeholder hooks only.
- Android export is documented but not produced in this stage.
- Only one arena and one enemy type exist.
- Touch controls are implemented for the prototype but still need device testing on real phones.
- Balance is first-pass and intentionally conservative.
- The route is handcrafted and compact; no procedural generation or campaign structure exists yet.
- Headless screenshot capture is unavailable with the dummy renderer, so harness screenshot steps log a skip unless run with a display renderer.

## Future Roadmap

See `docs/ROADMAP.md`.
