# QA Stage 1.3 Visual Combat Upgrade

## What Changed

- Replaced the previous small placeholder actor sprites with a darker Dungeon Crawl based hooded player and four distinct enemy silhouettes.
- Replaced the weak combat cue bank with StarNinjas sword impacts and rubberduck RPG sounds.
- Removed texture-based slash rendering from player/enemy attacks so a bad slash texture cannot cover the screen.
- Added bounded vector weapon arcs, tighter spark/impact bursts, death smoke, and Collect cross-cut feedback.
- Added Screaming Brain stone floor/wall tiles to the shrine route and wall visuals.
- Adjusted shrine camera zoom and obstacle layout so actors read larger and the central combat floor is less cluttered.

## Final Commands

Run after implementation:

```powershell
godot_console --headless --path . -s tests/test_runner.gd
godot_console --path . --fixed-fps 120 --scene res://tests/PlaytestHarness.tscn
godot_console --path . --quit-after 3
```

## Automated Coverage

The logic tests cover stamina, dodge gating, 120 Hz physics, enemy damage, invulnerability, movement normalization, route/camera bounds, aim direction, frame-rate independence, attack buffering, perfect-dodge timing, Ash Brand progress, and enemy configs.

The playtest harness uses `InputRouter` and exercises route movement, visibility screenshots, actor variants, screen-edge aim, moving light attacks, heavy attacks, dodge direction, perfect dodge, Ash Brand, Collect, flask interruption, and clearing the Ash Trial.

## What Automation Cannot Judge

- Whether the new public-domain actor art is the right long-term style for Ashen Pity.
- Whether the new hit sounds feel strong enough on real speakers/headphones.
- Whether Collect feels satisfying when earned naturally in a real fight.
- Whether the hound, archer, guardian, and elite are clear enough under combat pressure.
- Whether the brighter tiled shrine route has the right amount of depth without becoming visually noisy.

## Manual Playtest Checklist

1. Confirm the game no longer reads as stick figures or tiny joke characters.
2. Confirm left-click combo, right-click heavy, dodge, and `Q` Collect all feel responsive.
3. Confirm hit stop, screen shake, sound, flash, knockback, and particles are noticeable but not obnoxious.
4. Confirm all four enemy sprites are distinct in motion.
5. Confirm the map feels more like a shrine route and less like a flat rectangle.
