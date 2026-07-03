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
