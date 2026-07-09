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

## Stage 1.3 Combat Identity and Presentation

- Added Ash Brand as the first signature combat mechanic. A perfect dodge through an enemy attack Brands that enemy, follow-up hits prime Collect, and `Q` performs a dash-through payoff that consumes the Brand.
- Kept the Stage 1.1 render hierarchy intact. Player and enemies still live in the world actor layer, not in UI, and ground remains outside Y-sort.
- Added a three-hit light combo with per-hit timing, range, arc width, damage, stagger, lunge, and input buffering.
- Added a right-click heavy attack with higher stamina cost, slower startup, stronger hit feedback, and higher stagger damage.
- Added the Bell-Bearer as a Stage 1.3 elite sandbox enemy, not a full boss.
- Added Ashbound Hound and Reliquary Archer variants through the existing enemy architecture so the trial has different combat pressures without adding a campaign or progression systems.
- Added the Ash Trial wave controller in the existing shrine arena: two Guardians, then Hound plus Guardian, then Archer plus Guardian, then Bell-Bearer.
- Added public/free sprite-based actor variants and stronger combat presentation: bounded slash arcs, hit sparks, Brand rings, Collect bursts, stagger flashes, death bursts, and stronger shadows.
- Added runtime OGG audio cues for sword whoosh, hits, armor hits, stagger, perfect dodge, Ash Brand, Collect, hurt, dodge, flask, and enemy death, with procedural tones kept only as fallback.
- Added a HUD Ash Brand/Collect indicator and mobile Collect/Heavy buttons that continue to route through `InputRouter`.
- Added Stage 1.3 deterministic playtest coverage for light attack while moving, heavy attack, perfect dodge, Ash Brand, Collect, flask interruption, actor variants, and the full Ash Trial.

### Stage 1.3 Combat Timing Values

- Light combo hit 1: startup 0.075s, active 0.09s, recovery 0.14s.
- Light combo hit 2: startup 0.085s, active 0.095s, recovery 0.15s.
- Light combo hit 3: startup 0.11s, active 0.11s, recovery 0.18s.
- Heavy attack: startup 0.22s, active 0.14s, recovery 0.28s.
- Collect: startup 0.05s, active 0.12s, recovery 0.16s.
- Dodge duration: 0.27s.
- Dodge invulnerability: 0.18s.
- Perfect-dodge Brand window: 0.16s from dodge start.
- Ash Brand duration: 5.0s.
- Brand hits required for Collect: 2.

### Stage 1.3 Out Of Scope

- No relics, pity systems, currency, shops, permanent upgrades, save files, procedural generation, weapon selection, multiple playable characters, full boss, or long-term progression were added.
- The Bell-Bearer is intentionally an elite combat test, not the final Pity Collector boss.

### Stage 1.3 Known Limitations

- The combat now has stronger automated coverage, but actual feel still requires human keyboard/mouse playtesting.
- The enemy variants share one configurable enemy scene and controller.
- The current public/free audio bank is stronger than the procedural fallback, but final sound design will still need mixing and human taste testing.
- Touch controls need real landscape phone validation.

## Raylib Prototype Separation

The older Raylib prototype was not reused because it was an abandoned technical experiment. This Godot project needs a clean foundation for scene composition, mobile input, combat readability, and visual atmosphere from day one.

## Current Visual and Gameplay Limitations

- Prototype art uses curated public/free assets and is not final key art.
- Combat is intentionally limited to one player weapon and one configurable enemy scene with four Stage 1.3 variants.
- The arena is handcrafted and compact.
- Audio uses curated public/free prototype SFX and is not final mixed sound design.
- Touch UI needs real-device validation before Android production work.
- Enemy formations and balance are rough first-pass values for feel testing.
- There is no progression, relic system, boss, save data, shop, or reward economy in this milestone by design.

## Best Next Tasks After This Milestone

1. Run a human keyboard/mouse playtest pass and tune camera speed, dodge distance, and attack lunge from direct feel.
2. Add a small visual QA checklist for every route screenshot so darkness, player visibility, and side-space readability are reviewed consistently.
3. Add one more automated route scenario that walks behind each pillar and confirms the player is visually layered correctly.

## Stage 1.3B Naturalization and Combat Fluidity Pass

- Replaced the obvious repeated floor-tile look with deterministic naturalized stone slabs, muted texture grain, and softer seams in `ShrineRouteLayer.gd`.
- Added raster torch, pillar, and broken wall prop assets under `assets/environment/upgrade/`, then wired them into `ShrineProp.gd` and `ShrineWallVisual.gd`.
- Added visual lean, squash, stride bob, attack anticipation, and stagger shake to player/enemy visual scripts so sprites feel less like static cards sliding across the floor.
- Tuned movement for stronger 120 Hz feel: higher acceleration/deceleration, faster dodge, shorter dodge recovery, quicker stamina regeneration, and lower regen delay.
- Added late attack-recovery dodge cancel and attack buffering out of dodge recovery for more fluid combat without removing all commitment.
- Added perfect-dodge stamina restore, counter-hit damage/stagger bonus during enemy windup, rear-hit bonus for positioning, and extra stagger when punishing enemy recovery.
- Added small lateral pressure to guardian and hound chase behavior so enemy movement is less one-dimensional.

### Stage 1.3B Verification

- `godot_console --headless --path . -s tests/test_runner.gd`: passed.
- `godot_console --path . --fixed-fps 120 --scene res://tests/PlaytestHarness.tscn`: passed.
- `godot_console --path . --quit-after 3`: passed.
- Harness snapshot on the development PC: about 171 FPS reported, display refresh about 170 Hz, p95 frame time 8.33 ms under fixed 120 FPS simulation, physics 120 Hz.
- The harness still reports the existing ObjectDB leak warning at exit.

## v0.5 Shrine Expansion and Parry Pass

- Added `E` parry and mobile Parry support. Parry has a short startup, active window, stamina cost, recovery, stamina restore on success, and enemy stagger/damage payoff.
- Heavy attack spam was constrained by `PLAYER_HEAVY_CHAIN_WINDOW`, `PLAYER_HEAVY_CHAIN_COST_STEP`, and `PLAYER_HEAVY_CHAIN_MAX`. The first heavy keeps its normal cost, then repeated heavies become increasingly expensive inside the chain window.
- Added the Ashen Judicator as a first-pass final encounter. It uses the existing enemy architecture with `attack_style = "boss"` and cycles four readable patterns: sweep, lunge, slam, and toll projectiles.
- Expanded the shrine route into six playable beats: entrance lesson, central shrine, west ossuary, east reliquary, north nave/Bell Gate, and final sanctum. The first room remains a simpler tutorial space.
- Added generated v0.5 raster assets for Judicator sprites, stairs, ash brazier, sealed door, bone debris, and reliquary shelves.
- Replaced remaining hand-drawn stairs/central landmark rendering with runtime raster props in `ShrineRouteLayer.gd`.
- Updated deterministic tests for heavy anti-spam, parry timing, Judicator config, expanded route bounds, parry interaction, Judicator screenshot coverage, and the full six-stage Ash Trial.

### v0.5 Verification

- `godot_console --headless --path . -s tests/test_runner.gd`: passed.
- `godot_console --path . --fixed-fps 120 --scene res://tests/PlaytestHarness.tscn`: passed.
- `godot_console --path . --quit-after 5`: passed.
- Harness snapshot on the development PC: 170 FPS reported, display refresh about 170 Hz, p95 frame time 8.33 ms under fixed 120 FPS simulation, physics 120 Hz.
- Known warning remains: the display playtest harness reports ObjectDB leaked instances at exit.

### v0.5 Needs Human Judgment

- Whether parry timing feels fair during real keyboard/mouse combat.
- Whether the Judicator's lunge, slam, and toll attacks are readable enough without becoming easy.
- Whether the expanded route has the right density of fights versus movement.

## v0.5.1 Response Pass

- The previous v0.5 pass still did not make parry feel important enough. Parry now immediately primes Collect, extends the Brand duration, restores stamina, damages/staggers the enemy, and gives the next Collect extra damage, stagger, and knockback.
- The shrine route was pushed farther than the v0.5 version: the player now starts in a lower Pilgrim Court, can route into deeper west/east side spaces, and the camera limits/visibility test points cover those added rooms.
- The Ash Trial is now seven stages instead of six: lower court, entrance pressure, central shrine, deep ossuary, reliquary crossfire, Bell Gate, and final Judicator sanctum.
- The deterministic playtest harness now verifies movement through the added rooms and checks that a successful parry can convert directly into immediate Collect damage.

### v0.5.1 Verification

- `godot_console --headless --path . -s tests/test_runner.gd`: passed.
- `godot_console --path . --fixed-fps 120 --scene res://tests/PlaytestHarness.tscn`: passed.
- Harness snapshot on the development PC: 170 FPS reported, display refresh about 170 Hz, p95 frame time 8.33 ms under fixed 120 FPS simulation, physics 120 Hz.
- The playtest harness still reports the existing ObjectDB leak warning at process exit.

## v0.5.2 Ash Brand Timeout, Flask, UI, and Shrine Material Pass

- Changed parry-created Ash Brand from a generous extended payoff into a short punish window. A successful parry now primes Collect for 3 seconds through `PLAYER_PARRY_BRAND_DURATION`; waiting too long drops the opportunity.
- Rebalanced the damage hierarchy so Collect is the hardest-hitting player attack, heavy is second, and light combo hits are weakest. Parry-primed Collect still gets extra damage, stagger, and knockback.
- Added one flask charge restoration after each cleared Ash Trial stage, clamped to the two-flask maximum.
- Updated the HUD presentation toward a Souls-style read: a long squared red health bar, shorter squared green stamina bar, and cleaner screen-fixed layout.
- Added Simple Souls Set runtime actor sprites for player and enemy variants, with license/source sheets recorded under `assets/third_party/simple_souls/`.
- Replaced the noisy full-sheet floor/wall usage with cropped Screaming Brain Studios CC0 dungeon tiles under `assets/environment/sbs_dungeon/`.
- Rebuilt the runtime brazier after discovering the previous crop was actually a chest-like UI/object tile. The new brazier is an original cleaned sprite made for Ashen Pity and no longer reads as loot noise.
- Updated enemy attack selection so Guardian, Hound, Archer, and Bell-Bearer use more distinct patterns, timing, hit shapes, and telegraphs instead of all feeling like the same grunt swing.

### v0.5.2 Verification

- `godot_console --headless --path . -s tests/test_runner.gd`: passed.
- `godot_console --path . --quit-after 5`: passed.
- `godot_console --path . --fixed-fps 120 --scene res://tests/PlaytestHarness.tscn`: passed.
- Harness snapshot on the development PC: 157 FPS reported, display refresh about 170 Hz, p95 frame time 8.33 ms under fixed 120 FPS simulation, physics 120 Hz.
- Known warning remains: the display playtest harness reports ObjectDB leaked instances at exit.
