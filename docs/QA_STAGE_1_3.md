# QA Stage 1.3 Visual Combat Upgrade

## What Changed

- Replaced code-drawn actor bodies with curated sprite assets.
- Replaced procedural-only combat sounds with Kenney OGG combat cues.
- Replaced simple vector hit effects with Kenney slash, spark, star, smoke, and twirl textures.
- Kept the existing movement, camera, Ash Trial, combo, heavy attack, Ash Brand, and Collect systems.

## Final Commands

Run after implementation:

```powershell
godot_console --headless --path . -s tests/test_runner.gd
godot_console --path . --fixed-fps 120 --scene res://tests/PlaytestHarness.tscn
godot_console --path . --quit-after 180
```

## Automated Coverage

The logic tests cover stamina, dodge gating, 120 Hz physics, enemy damage, invulnerability, movement normalization, route/camera bounds, aim direction, frame-rate independence, attack buffering, perfect-dodge timing, Ash Brand progress, and enemy configs.

The playtest harness uses `InputRouter` and covers route movement, visibility screenshots, actor variant screenshots, screen-edge aim, moving light attacks, heavy attacks, dodge direction, perfect dodge, Ash Brand, Collect, flask interruption, and clearing the Ash Trial.

## What Automation Cannot Judge

- Whether the new sprite scale reads well during real mouse/keyboard play.
- Whether hit impact sounds feel strong enough on speakers/headphones.
- Whether Collect feels satisfying enough when earned naturally.
- Whether the hound, archer, guardian, and elite silhouettes are clear under real combat pressure.
- Whether mobile button placement still feels good on a real landscape phone.

## Manual Playtest Checklist

1. Confirm the game no longer reads as stick figures.
2. Confirm left-click combo, right-click heavy, dodge, and `Q` Collect all feel responsive.
3. Confirm hit stop, screen shake, sound, flash, knockback, and particles are noticeable but not noisy.
4. Confirm all four enemy sprites are distinct.
5. Confirm the final Bell-Bearer encourages perfect dodge into Ash Brand into Collect.
