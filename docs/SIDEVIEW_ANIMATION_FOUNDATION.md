# Side-View Animation Foundation

Ashen Pity now boots directly into `scenes/sideview/SideViewAnimationTest.tscn`. The former boot flow, top-down arena, enemies, HUD, mobile overlay, world art, and combat autoloads are disconnected from the runnable build. Their files remain only as inactive history/reference while the project changes direction.

## Active Foundation

- `scripts/player/sideview/PlayerSideViewController.gd` handles horizontal movement, acceleration, facing, and action input.
- `scripts/player/sideview/PlayerActionState.gd` owns action locks and clean state transitions.
- `scripts/player/sideview/PlayerAnimationController.gd` builds and plays idle, run, normal attack, heavy attack, parry, skill, hurt, and death animations.
- `scripts/player/sideview/WeaponSocket.gd` contains the per-animation weapon socket position and rotation tables.
- `scripts/player/sideview/WeaponVisual.gd` renders the starter longsword as a separate sprite.
- `resources/player/SideViewAnimationTuning.tres` exposes movement speed, acceleration, animation timing, and movement allowed during actions.

The playable frames under `assets/sprites/sideview/wanderer/` are derived from the user-provided hooded armored wanderer reference. The separate starter longsword and ash cross-cut effect were created for this project to match that character. Source sheets and transparent processing intermediates are kept under `assets/sprites/sideview/source/`; `.gdignore` prevents Godot from importing them into the active game.

All animations run at 12 FPS or faster. The skill body animation and ash cross-cut effect run at 24 FPS. Action lock duration is edited in `SideViewAnimationTuning.tres`; weapon alignment is edited frame-by-frame in `WeaponSocket.gd`.

## Manual Polish Remaining

- Judge whether each sword grip stays convincingly inside the hands during every transitional frame.
- Judge whether the run cycle cadence matches the final side-view movement speed.
- Decide whether future production sprites should retain this painted pixel-art scale or move to larger hand-authored sheets before enemies and levels return.
