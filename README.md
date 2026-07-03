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

The project is in Stage 1 combat foundation development. The priority is game feel, visual readability, and a small polished room over broad feature count.

## Known Limitations

- Art is hand-authored prototype vector work, not final production art.
- Audio is represented by placeholder hooks and lightweight generated feedback.
- Android export is documented but not produced in this stage.
- Only one arena and one enemy type exist.

## Future Roadmap

See `docs/ROADMAP.md`.
