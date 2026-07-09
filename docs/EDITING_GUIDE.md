# Editing Guide

## Player Movement

Edit `scripts/autoload/GameBalance.gd`:

- `PLAYER_MOVE_SPEED`
- `PLAYER_ACCELERATION`
- `PLAYER_DECELERATION`

Implementation lives in `scripts/player/PlayerController.gd`, mainly `_physics_process`, `_get_move_input`, `_update_aim`, and `_apply_weighted_movement`.

## Combo Speed

Edit `LIGHT_COMBO` in `scripts/autoload/GameBalance.gd`.

Each hit has:

- `windup`
- `active`
- `recovery`
- `stamina`
- `range`
- `width`
- `height`
- `lunge`

Input buffering is controlled by `PLAYER_ATTACK_BUFFER_WINDOW`.

Late attack-recovery dodge cancel is controlled by `PLAYER_DODGE_CANCEL_AFTER`.

Attack-after-dodge feel is controlled by `PLAYER_DODGE_ATTACK_BUFFER_WINDOW`.

Repeated heavy attack spam is controlled by:

- `PLAYER_HEAVY_CHAIN_WINDOW`
- `PLAYER_HEAVY_CHAIN_COST_STEP`
- `PLAYER_HEAVY_CHAIN_MAX`

## Attack Damage And Impact

Edit `scripts/autoload/GameBalance.gd`:

- `LIGHT_COMBO[*].damage`
- `LIGHT_COMBO[*].stagger`
- `LIGHT_COMBO[*].knockback`
- `HEAVY_ATTACK.damage`
- `HEAVY_ATTACK.stagger`
- `HEAVY_ATTACK.knockback`
- `COLLECT_ATTACK.damage`
- `COLLECT_ATTACK.stagger`
- `COLLECT_ATTACK.knockback`
- `COUNTER_HIT_DAMAGE_MULTIPLIER`
- `COUNTER_HIT_STAGGER_MULTIPLIER`
- `REAR_HIT_DAMAGE_MULTIPLIER`
- `REAR_HIT_STAGGER_BONUS`
- `RECOVERY_PUNISH_STAGGER_BONUS`

Hit stop, screen shake, and hit VFX are triggered in `scripts/world/ShrineArena.gd` in `_on_hit_confirmed`.

Counter-hit and rear-hit punish rules are applied in `scripts/enemies/ShrineGuardian.gd`.

## Dodge Timing

Edit `scripts/autoload/GameBalance.gd`:

- `PLAYER_DODGE_SPEED`
- `PLAYER_DODGE_TIME`
- `PLAYER_DODGE_INVULN_TIME`
- `PLAYER_DODGE_RECOVERY`
- `PLAYER_DODGE_COST`
- `PLAYER_DODGE_CANCEL_AFTER`
- `PLAYER_DODGE_ATTACK_BUFFER_WINDOW`
- `PLAYER_PERFECT_DODGE_STAMINA_RESTORE`

The dodge state implementation is in `scripts/player/PlayerController.gd`.

## Parry Timing

Edit `scripts/autoload/GameBalance.gd`:

- `PLAYER_PARRY_COST`
- `PLAYER_PARRY_STARTUP`
- `PLAYER_PARRY_ACTIVE`
- `PLAYER_PARRY_RECOVERY`
- `PLAYER_PARRY_STAMINA_RESTORE`
- `PLAYER_PARRY_DAMAGE`
- `PLAYER_PARRY_STAGGER`
- `PLAYER_PARRY_KNOCKBACK`
- `PLAYER_PARRY_BRAND_DURATION`
- `PLAYER_PARRY_COLLECT_DAMAGE_MULTIPLIER`
- `PLAYER_PARRY_COLLECT_STAGGER_BONUS`
- `PLAYER_PARRY_COLLECT_KNOCKBACK_BONUS`
- `BOSS_PARRY_STAGGER_RESIST`

Player-side timing lives in `scripts/player/PlayerController.gd`.

Enemy/projectile parry checks live in `scripts/enemies/ShrineGuardian.gd` and `scripts/enemies/EnemyProjectile.gd`.

## Ash Brand Rules

Edit `scripts/autoload/GameBalance.gd`:

- `PLAYER_PERFECT_DODGE_WINDOW`
- `ASH_BRAND_DURATION`
- `ASH_BRAND_HITS_TO_COLLECT`
- `COLLECT_TARGET_RANGE`
- `COLLECT_ATTACK`
- `PLAYER_PARRY_BRAND_DURATION`

Player-side detection and Collect execution are in `scripts/player/PlayerController.gd`.

Enemy-side Brand storage and Collect readiness are in `scripts/enemies/ShrineGuardian.gd`.

Parry-created Brands intentionally use the shorter `PLAYER_PARRY_BRAND_DURATION` timeout. The current value is 3 seconds, so waiting too long after a successful parry loses the free Collect punish.

## Enemy Stats

Edit `ENEMY_CONFIGS` in `scripts/autoload/GameBalance.gd`.

Per enemy kind you can change:

- display name
- max health
- movement speed
- detection range
- attack range
- damage
- knockback
- windup
- active window
- recovery
- stagger threshold
- attack style

## Sounds

Audio files live in `assets/audio/upgrade/`.

Cue mapping lives in `scripts/autoload/CombatAudio.gd` under `CUE_PATHS`.

To swap a sound, replace the OGG file or change the path in `CUE_PATHS`.

## Sprites

Player sprites live in `assets/sprites/ashen_runtime/player_*.png`.

Enemy sprites live in:

- `assets/sprites/ashen_runtime/melee_*.png`
- `assets/sprites/ashen_runtime/hound_*.png`
- `assets/sprites/ashen_runtime/archer_*.png`
- `assets/sprites/ashen_runtime/elite_*.png`
- `assets/sprites/ashen_runtime/judicator_*.png`

Sprite selection happens in:

- `scripts/player/PlayerVisual.gd`
- `scripts/enemies/ShrineGuardianVisual.gd`

## VFX

Small VFX textures live in `assets/effects/upgrade/`.

Effect behavior lives in `scripts/effects/CombatEffect.gd`.

Hit and perfect-dodge effect spawning happens in `scripts/world/ShrineArena.gd`.

Player and enemy weapon arcs are now bounded vector drawings in `PlayerVisual.gd`, `ShrineGuardianVisual.gd`, and `CombatEffect.gd`. This avoids full-screen slash texture failures.

## Map And Camera

Playable route geometry, wall collision, obstacle placement, and camera zoom live in `scripts/world/ShrineRoute.gd`.

Ground texture drawing and shrine floor presentation live in `scripts/world/ShrineRouteLayer.gd`.

Wall, broken wall, and altar rendering live in `scripts/world/ShrineWallVisual.gd`.

Stone floor and wall tiles live in `assets/environment/sbs_dungeon/`.

Runtime torch/brazier, bones, urn, and reliquary props live in `assets/environment/simple_souls/`. The stairs and sealed door still live in `assets/environment/upgrade/`.

Natural floor tile generation lives in `scripts/world/ShrineRouteLayer.gd` in `_build_floor_cells`.

Stage flask restoration is triggered in `scripts/world/ShrineArena.gd` in `_on_trial_wave_started`. The player-side clamp is `restore_flask_charge` in `scripts/player/PlayerController.gd`.

## Wave Setup

Edit `scripts/trial/AshTrial.gd`.

Current stages:

- Stage 1: one `guardian` in the Pilgrim Court
- Stage 2: one `guardian`, one `hound` in the entrance route
- Stage 3: two `guardian`, one `hound` in the central shrine
- Stage 4: two `hound`, one `guardian`, one `archer` in the deep ossuary
- Stage 5: three `archer`, one `guardian` in the reliquary side route
- Stage 6: one `bell_bearer`, one `hound`, one `archer` at the Bell Gate
- Final: one `ashen_judicator`, two `guardian` in the sanctum

Keep new encounters inside the shrine route until the core combat survives human playtesting.

## Boss Pattern Setup

The Ashen Judicator uses `attack_style = "boss"` in `GameBalance.ENEMY_CONFIGS`.

Pattern cycling lives in `scripts/enemies/ShrineGuardian.gd` in `_begin_attack`, `_update_attack_hitbox`, and the `EnemyState.ACTIVE` branch. Current patterns are:

- `sweep`
- `lunge`
- `slam`
- `toll`
