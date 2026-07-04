# Ashen Pity Devlog

## Stage 1 Foundation

- Created a fresh Godot 4 project in this repository only.
- Initialized source control before major implementation.
- Added repository rules that keep scenes focused, combat values centralized, and copyrighted assets out of the project.
- Built the shrine arena as a handcrafted room with collision walls, floor cracks, ash, broken columns, torch pools, and Y-sorted props.
- Built the player around movement feel first: acceleration, deceleration, mouse aim, stamina-gated attacks, dodge invulnerability, healing commitment, hit flash, knockback, and death.
- Built one Shrine Guardian enemy with a small finite state machine: patrol, chase, wind-up, active attack, recovery, stagger, dying, and dead.
- Added mobile controls through a shared `InputRouter` so touch buttons and desktop inputs drive the same gameplay actions.
- Added a headless GDScript test runner for stamina spending, dodge gating, damage, invulnerability, enemy transitions, and diagonal movement normalization.

## Stage 1.1 Stabilization

- Fixed the disappearing-character bug by removing world art from the Y-sorted arena root. The old `ShrineArena` node had `y_sort_enabled = true` and also drew the floor, walls, and light pools in its own `_draw()`. Actors lived under a separate `ActorSort` wrapper. In the upper half of the map, negative-Y actors could sort behind the root canvas item, allowing floor or wall drawing to cover the characters.
- Rebuilt the scene hierarchy into explicit render layers: `Ground`, `GroundDecals`, `Shadows`, `ActorsAndTallProps`, `ForegroundCanopy`, `Collision`, and `Camera2D`.
- Kept floor and decals outside Y-sort. Player, guardians, pillars, torches, broken walls, and altar props now share one Y-sorted actor/tall-prop layer.
- Kept HUD, pause, debug text, and mobile controls in `CanvasLayer` scenes so UI stays screen-fixed and does not participate in world rendering.
- Added camera limits, subtle smoothing, a small zoom-in, and a larger drawn shrine backdrop so the camera no longer drifts into large black unused areas.
- Replaced the single rectangular arena with a compact shrine route: entrance hall, central shrine arena, and broken altar platform.
- Tuned movement acceleration, deceleration, attack timing, dodge timing, stamina recovery, hit stop, and dodge trail readability without adding new abilities.
- Added tests for route bounds, camera coverage, world-space aim direction, dodge invulnerability timing, and movement normalization.

## Camera and Viewport Decisions

- The project keeps a 1920x1080 landscape baseline with `canvas_items` stretch and `expand` aspect handling for desktop and future landscape phones.
- Camera limits match the handcrafted route extents and prevent the view from drifting far outside designed space.
- Mouse aim continues to use world-space conversion through `get_global_mouse_position()`, wrapped in combat math for test coverage.

## Stage 1.1 Out of Scope

- No relics, pity systems, gacha mechanics, currency, shops, bosses, extra weapons, new enemy types, save files, or persistent progression were added.

## Raylib Prototype Separation

The older Raylib prototype was not reused because it was an abandoned technical experiment. This Godot project needs a clean foundation for scene composition, mobile input, combat readability, and visual atmosphere from day one.

## Current Visual and Gameplay Limitations

- Prototype art is original and self-created, but not final key art.
- Combat is intentionally limited to one player weapon and one enemy type.
- The arena is handcrafted and compact.
- Audio remains placeholder-level for this milestone.
- Touch UI needs real-device validation before Android production work.
- Enemy formations and balance are rough first-pass values for feel testing.
- There is no progression, relic system, boss, save data, shop, or reward economy in this milestone by design.

## Best Next Tasks After This Milestone

1. Add a second weapon with a distinct stamina and timing profile.
2. Add a second enemy that pressures healing and positioning differently.
3. Prototype a first reward screen without permanent progression.
