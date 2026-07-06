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

## Stage 1.1B Combat Feel and Performance

- GUI launch is available, but no computer-control tool was available to drive real keyboard/mouse playthroughs. Because of that, deterministic in-game harness coverage was added instead of claiming manual playtesting.
- Kept the Stage 1.1 disappearing-entity fix intact. The root cause remains the old Y-sorted arena root drawing floor/walls while actors were under a child sort wrapper.
- Added a runtime render-layer integrity guard in `ShrineArena.gd` so ground/decal/shadow layers stay outside Y-sort and `ActorsAndTallProps` remains the shared Y-sorted layer for characters and tall props.
- Set project physics to 120 ticks per second and kept V-Sync enabled without hard-locking max FPS.
- Added `PerformanceStats` for FPS, display refresh, average frame time, p95 frame time, physics tick rate, active enemy count, player state, and lightweight mode.
- Added `F2` lightweight performance mode. It currently reduces selected particle/decal load and exists as a future mobile-performance hook.

### Combat Timing Values

- Player move speed: 372.
- Player acceleration/deceleration: 3200 / 3600.
- Light attack startup: 0.09s.
- Light attack active window: 0.10s.
- Light attack recovery: 0.16s.
- Attack input buffer window: 0.11s near the end of recovery.
- Active attack forward lunge target speed: 92.
- Dodge speed: 790.
- Dodge duration: 0.27s.
- Dodge invulnerability: 0.18s.
- Dodge recovery: 0.09s.
- Stamina regen: 62 per second after a 0.30s delay.
- Guardian wind-up / active / recovery: 0.52s / 0.16s / 0.68s.

### Measurements

- Headless deterministic harness, uncapped smoke: measured about 132 FPS, average frame time about 7.58 ms, p95 about 8.33 ms, physics 120 Hz.
- Fixed 120 FPS harness: passed with average frame time 8.33 ms and p95 8.33 ms.
- Fixed 60 FPS harness: passed with average frame time 16.67 ms and p95 16.67 ms.
- Headless display reports display refresh as 0 Hz, so real monitor refresh must be verified through the in-game debug overlay during human playtesting.

### Automated Test Coverage

- Unit tests cover stamina spend/regeneration, 120 Hz project physics setting, dodge gating, enemy damage, invulnerability math, enemy state transitions, movement normalization, route/camera bounds, world-space aim, frame-rate-independent velocity math, and attack buffering.
- The playtest harness drives `InputRouter`, not direct player state transitions, for route movement, visibility, aim, moving attacks, dodge direction, dodging an enemy attack, flask interruption, and defeating guardians.
- Harness setup directly places/resets player and guardian state between scenarios. That is intentional test setup, not a simulation of normal play.
- Headless screenshots are skipped under the dummy renderer. Visual screenshots still require a display renderer or manual capture.

### Still Needs Human Playtesting

- Actual keyboard/mouse feel at desktop refresh rates.
- Whether attack buffering feels responsive rather than spammy.
- Whether dodge invulnerability and enemy recovery feel fair under pressure from multiple guardians.

## Stage 1.1C Visual Difference and Framing Pass

- Inspected the playable build before this pass. The project was clean on `feature/stage-1-1b-combat-feel-performance`, with no configured Git remote and `gh` unauthenticated.
- The disappearing-entity root cause from Stage 1.1 remains fixed: actors are not under UI/CanvasLayer nodes, ground is outside Y-sort, and player/guardians/tall props share the `ActorsAndTallProps` Y-sorted layer.
- The build still felt visually similar because the camera limits and screenshot points centered the old rectangular central arena, the side spaces were not prominent, and the player/enemy vector actors still read too close to placeholder silhouettes at gameplay scale.
- One actual route bug was found: the left central pillar was placed on the diagonal approach to the left side space. The deterministic harness stopped near `(-427, -147)` when trying to reach `(-560, -145)`. Moving that pillar opened the side route while preserving cover and depth.
- Camera framing was tightened by moving the shared route zoom to `1.20`, expanding drawn camera edge limits to include designed exterior masonry, disabling built-in Camera2D smoothing, and keeping one script-controlled camera interpolation path.
- The playtest harness now snaps the camera after scenario teleports, so screenshots test level framing instead of recording artificial camera catch-up after a teleport.
- The shrine route now has wider left and right side spaces, a clearer entrance, an irregular central combat area, and a more distinct northern altar platform. Exterior masonry is drawn around the route so camera edges show designed space rather than raw renderer black.
- Player and Shrine Guardian visuals remain original code-drawn art, but the silhouettes were expanded with layered cloak/armor panels, stronger mask shapes, weapon details, and clearer shadows.
- The HUD now displays `Stage 1.1C` and the current Git commit through `BuildInfo.gd`, so screenshots and local play sessions identify the build.
- No relics, pity systems, currency, bosses, new weapons, new enemy types, save files, shops, procedural generation, or progression systems were added.

### Stage 1.1C Verification

- `godot_console --headless --path . -s tests/test_runner.gd`: passed.
- `godot_console --headless --path . --scene res://scenes/arena/ShrineArena.tscn --quit`: passed.
- `godot_console --path . --fixed-fps 120 --scene res://tests/PlaytestHarness.tscn`: passed.
- `godot_console --path . --fixed-fps 60 --scene res://tests/PlaytestHarness.tscn`: passed.
- `godot_console --path . --quit-after 180`: passed.
- Display-renderer harness artifacts generated: `entrance.png`, `central_arena.png`, `left_side_path.png`, `right_side_path.png`, `northern_altar.png`, and `combat_encounter.png` under ignored `playtest_artifacts/`.
- Harness performance snapshot on the development PC: about 170 FPS reported, display refresh about 170 Hz, p95 frame time 8.33 ms under fixed 120 FPS simulation, physics 120 Hz.

### Stage 1.1C Remaining Human Checks

- Whether the darker exterior masonry around side paths reads as designed shrine space rather than leftover empty space.
- Whether the faster movement, 92-speed attack lunge, and 790-speed dodge feel responsive under real keyboard/mouse input.
- Whether the camera follow feels comfortable during continuous human movement instead of only deterministic test routes.

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

1. Run a human keyboard/mouse playtest pass and tune camera speed, dodge distance, and attack lunge from direct feel.
2. Add a small visual QA checklist for every route screenshot so darkness, player visibility, and side-space readability are reviewed consistently.
3. Add one more automated route scenario that walks behind each pillar and confirms the player is visually layered correctly.
