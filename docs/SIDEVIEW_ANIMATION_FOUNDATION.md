# Side-View Animation Foundation

The runnable project is `scenes/sideview/SideViewAnimationTest.tscn`. It contains only the side-view character, separate starter sword, flat test floor, camera, controls, and an animation lab hidden behind `F2`. The old top-down world, enemies, HUD, and combat systems remain disconnected from the active scene.

## Pipeline

The supplied artwork is flattened full-body art, not separable limbs, so the project uses a hybrid frame-by-frame pipeline rather than a false skeletal rig:

- `AnimatedSprite2D` displays unique normalized character drawings.
- `AnimationPlayer` interpolates restrained secondary root motion without rotating, warping, or scaling the body art.
- `WeaponSocket/WeaponPivot/WeaponVisual` keeps the sword separate and smoothly interpolates grip position, angle, and draw depth.
- `WeaponBladeTrail` samples the real blade-tip marker. Ash Cross-Cut's impact appears only where the two authored blade paths intersect.

`tools/build_sideview_animation_assets.py` extracts poses at real transparent gaps, removes adjacent-pose bleed, aligns the foot anchor, and places every drawing on a stable 512 by 512 canvas.

## Frame Counts And Rates

| Animation | Unique frames | Playback rate |
| --- | ---: | ---: |
| Idle | 4 | 14 FPS |
| Run | 8 | 24 FPS |
| Normal attack | 7 | 24 FPS |
| Heavy attack | 8 | 24 FPS |
| Parry | 6 | 24 FPS |
| Ash Cross-Cut | 8 | 28 FPS |
| Hurt placeholder | 2 | 24 FPS |
| Death placeholder | 6 | 24 FPS |

Frame holds vary per pose to preserve anticipation, impact, and recovery. They do not duplicate source drawings. World movement uses `delta` in `_physics_process`, and the project remains configured for 120 physics ticks per second; sprite drawing FPS is independent of monitor refresh rate.

## Editing Map

- Frame files, ordering, playback, and secondary motion: `scripts/player/sideview/PlayerAnimationController.gd`
- Playback FPS, frame holds, movement, buffer window, and socket smoothing: `scripts/player/sideview/AnimationTuning.gd` and `resources/player/SideViewAnimationTuning.tres`
- Action locks, late-recovery input buffering, and locomotion return: `scripts/player/sideview/PlayerActionState.gd`
- Grip offsets, sword angles, and front/behind depth per frame: `scripts/player/sideview/WeaponSocket.gd`
- Blade-following trails: `scripts/player/sideview/WeaponBladeTrail.gd`
- Lab hotkeys and hidden readout: `scripts/player/sideview/AnimationReviewController.gd`

Press `F2` to enter the lab. `1` through `6` select Idle, Run, Normal, Heavy, Parry, and Ash Cross-Cut. `P` pauses, Left/Right steps frames while paused, `7/8/9` select 0.25x/0.5x/1x speed, and `V` shows the weapon pivot.

## Missing Artist Poses

- There is no dedicated hurt sequence; the placeholder uses the first two unique death drawings.
- The flattened character does not provide independent cape layers, so cape delay is authored into each body frame rather than simulated separately.
- No weapon-contact recoil pose exists for parry because this milestone intentionally has no enemy or incoming weapon.

The next manual pass should judge stride-to-world-speed matching, grip placement at every stepped frame, and whether the two Cross-Cut blade paths read clearly without the impact sprite.
