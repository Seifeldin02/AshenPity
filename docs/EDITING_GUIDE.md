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

## Ash Brand Rules

Edit `scripts/autoload/GameBalance.gd`:

- `PLAYER_PERFECT_DODGE_WINDOW`
- `ASH_BRAND_DURATION`
- `ASH_BRAND_HITS_TO_COLLECT`
- `COLLECT_TARGET_RANGE`
- `COLLECT_ATTACK`

Player-side detection and Collect execution are in `scripts/player/PlayerController.gd`.

Enemy-side Brand storage and Collect readiness are in `scripts/enemies/ShrineGuardian.gd`.

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

Player sprites live in `assets/sprites/upgrade/player_*.png`.

Enemy sprites live in:

- `assets/sprites/upgrade/melee_*.png`
- `assets/sprites/upgrade/hound_*.png`
- `assets/sprites/upgrade/archer_*.png`
- `assets/sprites/upgrade/elite_*.png`

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

Stone tile textures live in `assets/environment/upgrade/`.

Torch, pillar, and broken wall raster props also live in `assets/environment/upgrade/`.

Natural floor slab generation lives in `scripts/world/ShrineRouteLayer.gd` in `_build_floor_cells`.

## Wave Setup

Edit `scripts/trial/AshTrial.gd`.

Current waves:

- Wave 1: two `guardian`
- Wave 2: one `hound`, one `guardian`
- Wave 3: one `archer`, one `guardian`
- Final: one `bell_bearer`

Keep Stage 1 changes focused on this small combat trial unless the project scope changes.
