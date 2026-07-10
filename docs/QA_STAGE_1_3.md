# QA v0.5.2 Shrine Expansion

## What Changed

- Added parry on `E` and the mobile Parry button.
- v0.5.1 made successful parries immediately prime Collect, with extra Collect damage, stagger, and knockback.
- Added heavy attack chain stamina scaling so repeated heavies become expensive instead of being the default winning strategy.
- Expanded the Ash Trial from four waves to seven stages across the shrine route.
- Added the Ashen Judicator final encounter with sweep, lunge, slam, and toll projectile patterns.
- Expanded the shrine route with the Pilgrim Court, west ossuary, deep crypt, east reliquary, deep chapel, north nave, and final sanctum spaces while leaving the first room as a safer tutorial space.
- Added generated Judicator sprite variants and generated raster shrine props for stairs, brazier, sealed door, bone debris, and reliquary shelves.
- Replaced the previous small placeholder actor sprites with a darker Dungeon Crawl based hooded player and four distinct enemy silhouettes.
- v0.5.2 switches the current actor sprites to the Simple Souls Set runtime crops and uses cropped Screaming Brain Studios CC0 dungeon tiles for stone floors and walls.
- v0.5.2 replaces the broken chest-like brazier crop with an original cleaned brazier sprite and reduces loud prop repetition in the combat route.
- v0.5.2 changes parry-created Ash Brand to expire after 3 seconds if Collect is not used.
- v0.5.2 confirms damage hierarchy: Collect is strongest, heavy is second, light combo hits are weakest.
- v0.5.2 restores one flask charge after each cleared stage, clamped to two charges.
- v0.5.2 gives Guardian, Hound, Archer, and Bell-Bearer more distinct attack pattern data and telegraph shapes.
- v0.5.4 adds three in-world run boons: Ember Step, Grave Guard, and Reaper Vow.
- v0.5.4 expands the Ash Trial to nine stages with Split Crypts and Nave Pressure before the final Judicator fight.
- v0.5.4 gives Guardian a shield bash, Hound a short snap, and Archer a fan-shot pattern.
- v0.5.4 makes the HUD explicitly show `F Flask`, active boons, and pickup banners.
- v0.5.4 further reduces repeated floor texture noise with larger uneven authored slabs.
- v0.5.5 fixes red-box hurt sprites, upgrades enemy/boss health bars to red rectangles, adds Ash Brand countdown UX, replaces line/circle telegraphs with filled danger shapes, and swaps runtime shrine props to stronger raster assets.
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

The playtest harness uses `InputRouter` and exercises route movement through the lower court and deep side rooms, visibility screenshots, actor variants including Ashen Judicator, screen-edge aim, moving light attacks, heavy attacks, dodge direction, parry, immediate parry-primed Collect damage, perfect dodge, Ash Brand, Collect, flask interruption, and clearing the nine-stage Ash Trial.

Latest local results:

- `godot_console --headless --path . -s tests/test_runner.gd`: passed.
- `godot_console --path . --fixed-fps 120 --scene res://tests/PlaytestHarness.tscn`: passed.
- `godot_console --path . --quit-after 5`: passed.
- Latest harness performance snapshot: 170 FPS reported, 170 Hz display refresh, 8.33 ms p95 frame time under fixed 120 FPS simulation, physics 120 Hz.
- Known warning: the playtest harness still reports ObjectDB leaked instances at process exit.

## What Automation Cannot Judge

- Whether the new public-domain actor art is the right long-term style for Ashen Pity.
- Whether the new hit sounds feel strong enough on real speakers/headphones.
- Whether parry feels strict-but-fair in real fights.
- Whether Collect feels satisfying when earned naturally in a real fight.
- Whether the Judicator patterns are readable and punishable without feeling cheap.
- Whether the hound, archer, guardian, and elite are clear enough under combat pressure.
- Whether the brighter tiled shrine route has the right amount of depth without becoming visually noisy.
- Whether the new run boons create real decision-making or are just automatic power creep.
- Whether the new filled telegraphs are cool and readable under actual combat pressure.

## Manual Playtest Checklist

1. Confirm the game no longer reads as stick figures or tiny joke characters.
2. Confirm left-click combo, right-click heavy, dodge, and `Q` Collect all feel responsive.
3. Confirm hit stop, screen shake, sound, flash, knockback, and particles are noticeable but not obnoxious.
4. Confirm all four enemy sprites are distinct in motion.
5. Confirm the map feels more like a shrine route and less like a flat rectangle.
6. Confirm heavy spam is no longer the best strategy.
7. Confirm the expanded stages do not feel like walking too far between fights.
8. Confirm the three loot shrines are discoverable without becoming mandatory chores.
9. Confirm the new HUD explains boons without adding too much left-side clutter.
