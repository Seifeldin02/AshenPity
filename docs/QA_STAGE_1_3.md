# QA v0.5.1 Shrine Expansion

## What Changed

- Added parry on `E` and the mobile Parry button.
- v0.5.1 made successful parries immediately prime Collect, with extra Collect damage, stagger, and knockback.
- Added heavy attack chain stamina scaling so repeated heavies become expensive instead of being the default winning strategy.
- Expanded the Ash Trial from four waves to seven stages across the shrine route.
- Added the Ashen Judicator final encounter with sweep, lunge, slam, and toll projectile patterns.
- Expanded the shrine route with the Pilgrim Court, west ossuary, deep crypt, east reliquary, deep chapel, north nave, and final sanctum spaces while leaving the first room as a safer tutorial space.
- Added generated Judicator sprite variants and generated raster shrine props for stairs, brazier, sealed door, bone debris, and reliquary shelves.
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
godot_console --path . --quit-after 5
```

## Automated Coverage

The logic tests cover stamina, dodge gating, 120 Hz physics, enemy damage, invulnerability, movement normalization, route/camera bounds, aim direction, frame-rate independence, attack buffering, perfect-dodge timing, heavy anti-spam cost scaling, parry timing values, parry-primed Collect payoff values, Ash Brand progress, and enemy configs.

The playtest harness uses `InputRouter` and exercises route movement through the lower court and deep side rooms, visibility screenshots, actor variants including Ashen Judicator, screen-edge aim, moving light attacks, heavy attacks, dodge direction, parry, immediate parry-primed Collect damage, perfect dodge, Ash Brand, Collect, flask interruption, and clearing the seven-stage Ash Trial.

Latest local results:

- `godot_console --headless --path . -s tests/test_runner.gd`: passed.
- `godot_console --path . --fixed-fps 120 --scene res://tests/PlaytestHarness.tscn`: passed.
- `godot_console --path . --quit-after 5`: passed.
- Harness performance snapshot: 170 FPS reported, 170 Hz display refresh, 8.33 ms p95 frame time under fixed 120 FPS simulation, physics 120 Hz.
- Known warning: the playtest harness still reports ObjectDB leaked instances at process exit.

## What Automation Cannot Judge

- Whether the new public-domain actor art is the right long-term style for Ashen Pity.
- Whether the new hit sounds feel strong enough on real speakers/headphones.
- Whether parry feels strict-but-fair in real fights.
- Whether Collect feels satisfying when earned naturally in a real fight.
- Whether the Judicator patterns are readable and punishable without feeling cheap.
- Whether the hound, archer, guardian, and elite are clear enough under combat pressure.
- Whether the brighter tiled shrine route has the right amount of depth without becoming visually noisy.

## Manual Playtest Checklist

1. Confirm the game no longer reads as stick figures or tiny joke characters.
2. Confirm left-click combo, right-click heavy, dodge, and `Q` Collect all feel responsive.
3. Confirm hit stop, screen shake, sound, flash, knockback, and particles are noticeable but not obnoxious.
4. Confirm all four enemy sprites are distinct in motion.
5. Confirm the map feels more like a shrine route and less like a flat rectangle.
6. Confirm heavy spam is no longer the best strategy.
7. Confirm the expanded stages do not feel like walking too far between fights.
