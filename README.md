# Ashen Pity

Ashen Pity is an original 2D top-down dark-fantasy action roguelite prototype built in Godot 4 with GDScript.

This repository is the real Godot foundation for the project. The older Raylib technical prototype is intentionally not reused, copied, migrated, inspected, or depended on.

## Current Prototype Status

Version 0.5.5 is a shrine expansion combat sandbox with run-only boon pickups and a combat presentation polish pass. The build label is:

```text
Ashen Pity - Combat Polish v0.5.5
```

Current scope:

- Title screen into the shrine arena.
- One playable hooded wanderer.
- Fast mouse-aimed movement, dodge, parry, light combo, heavy attack, flask, and death/restart.
- Ash Brand: a perfect dodge or parry marks that enemy for 3 seconds; hesitating loses the Collect opportunity.
- Collect: landing follow-up hits on a Branded enemy opens a `Q` dash-through payoff. Collect is tuned as the hardest hit, heavy is second, light combo hits are weakest.
- Two healing flasks, with one flask charge restored after each cleared stage.
- Three in-world run boons: Ember Step, Grave Guard, and Reaper Vow.
- Clearer combat UX: boon descriptions, Ash Brand countdown, red enemy/boss health bars, and more readable pickup banners.
- Filled attack telegraphs, slash shapes, impact bursts, and cleaner hurt/death sprite transparency.
- One repeatable nine-stage Ash Trial through the expanded shrine route.
- Enemy variants for the trial: Shrine Guardian, Ashbound Hound, Reliquary Archer, Bell-Bearer elite, and Ashen Judicator final encounter.
- Minimal Ash Trial Complete summary with replay.
- Desktop controls and mobile-oriented controls using the same input router.

This version does not include relic pulls, pity systems, permanent upgrades, shops, save files, procedural generation, character selection, or long-term progression.

## PC Controls

- `WASD`: Move
- Mouse: Aim
- Left mouse: Three-hit light combo
- Right mouse: Heavy attack
- `Space`: Dodge roll
- `E`: Parry
- `Q`: Collect when Ash Brand is primed
- `F`: Healing flask
- `Escape`: Pause
- `F1`: Debug and performance overlay
- `F2`: Toggle lightweight performance mode
- `M`: Toggle mobile controls for desktop testing

## Mobile Controls

- Left virtual joystick: Move
- Right drag zone: Aim
- Attack button: Light combo
- Heavy button: Heavy attack
- Dodge button: Dodge roll
- Parry button: Parry
- Flask button: Heal
- Collect button: Appears when Collect is available
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
godot_console --path .
```

Headless logic tests:

```powershell
godot_console --headless --path . -s tests/test_runner.gd
```

Deterministic display playtest harness:

```powershell
godot_console --path . --fixed-fps 120 --scene res://tests/PlaytestHarness.tscn
```

## Refresh Rate And Diagnostics

- Physics runs at 120 ticks per second.
- V-Sync is enabled by default; the game is not hard-locked to 120 FPS.
- The prototype targets 60/90/120 Hz displays and should use the device display refresh rate where supported.
- Press `F1` to show FPS, display refresh rate, average frame time, p95 frame time, physics tick rate, active enemy count, player state, Ash Brand state, and Collect availability.
- Press `F2` to toggle lightweight performance mode.

## Shrine Route

The current level is an expanded but still compact shrine route:

- Shrine Entrance Hall: start area with broken walls, torches, and a side alcove.
- Pilgrim Court: lower approach where the trial starts with more breathing room and side cover.
- Central Shrine Arena: irregular combat space with side paths, pillars, broken walls, and a cracked ash brazier landmark.
- West Ossuary and Deep Crypt: side chambers with bone debris and pressure from fast enemies.
- East Reliquary and Deep Chapel: side chambers with ranged crossfire and shelf props.
- North Nave: transition area before the final gate.
- Broken Altar and Sanctum: raised-looking destination and Ashen Judicator final encounter.
- Loot Shrines: optional side-route pickups that modify perfect dodge, parry, or Collect for the current run only.

The first room stays simple enough to function as a tutorial space.

## Project Structure

```text
scenes/boot/      startup scene
scenes/menu/      title, victory, and pause flows
scenes/arena/     shrine combat scene
scenes/player/    player scene
scenes/enemies/   enemy scene
scenes/ui/        HUD and touch controls
scripts/          gameplay, combat, input, UI, effects, trial, and world scripts
assets/           original project asset folders
docs/             roadmap, architecture, QA notes, and editing guidance
tests/            headless logic tests and deterministic playtest harness
tools/            local helper scripts
```

## Where To Edit Core Systems

- Player movement, dodge, parry, combo, heavy, Collect, stamina, damage, and flask: `scripts/player/PlayerController.gd`.
- Combat timing, dodge cancel, parry timing, heavy anti-spam costs, stamina costs, counter hits, rear hits, stagger, enemy health, and enemy tuning: `scripts/autoload/GameBalance.gd`.
- Desktop, touch, and simulated test input: `scripts/autoload/InputRouter.gd`.
- Ash Trial waves and enemy spawning: `scripts/trial/AshTrial.gd`.
- Enemy behavior for Guardian, Hound, Archer, Bell-Bearer, and Ashen Judicator: `scripts/enemies/ShrineGuardian.gd`.
- Enemy projectile behavior: `scripts/enemies/EnemyProjectile.gd`.
- Player visual drawing and slash trails: `scripts/player/PlayerVisual.gd`.
- Enemy visual drawing and Ash Brand indicators: `scripts/enemies/ShrineGuardianVisual.gd`.
- Combat audio cue loading and fallback tones: `scripts/autoload/CombatAudio.gd`.
- Lightweight combat VFX and bounded hit arcs: `scripts/effects/CombatEffect.gd`.
- HUD, enemy bars, Ash Brand/Collect indicator, trial summary, and debug overlay: `scripts/ui/HUD.gd` and `scenes/ui/HUD.tscn`.
- Shrine route layout, walls, obstacles, torches, spawns, and camera limits: `scripts/world/ShrineRoute.gd`.
- Run-only loot pickup behavior: `scripts/world/LootShrine.gd`.
- Naturalized floor and room landmark drawing: `scripts/world/ShrineRouteLayer.gd`.
- Torch, pillar, wall, and broken wall prop visuals: `scripts/world/ShrineProp.gd` and `scripts/world/ShrineWallVisual.gd`.

More detail is in `docs/FILE_MAP.md` and `docs/EDITING_GUIDE.md`.

## Known Limitations

- Art uses curated public/free prototype assets and is not final production key art.
- Audio uses curated public/free prototype SFX and is not final mixed sound design.
- The Ash Trial enemy variants share one configurable enemy controller and scene.
- Run boons are first-pass combat modifiers, not a permanent relic/progression system.
- Parry now immediately primes a 3-second Collect window and gives that Collect extra damage, stagger, and knockback, but this still needs real human feel testing.
- Touch controls need real landscape phone testing.
- Balance is first-pass and must be judged through human playtesting.
- The Ashen Judicator is a first-pass final encounter, not production boss design.
- No Android export is produced in this stage.
- No progression, relic, pity, shop, save, or reward economy exists yet by design.

## Future Roadmap

See `docs/ROADMAP.md`.
