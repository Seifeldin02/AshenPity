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

Hit stop, screen shake, and hit VFX are triggered in `scripts/world/ShrineArena.gd` in `_on_hit_confirmed`.

## Dodge Timing

Edit `scripts/autoload/GameBalance.gd`:

- `PLAYER_DODGE_SPEED`
- `PLAYER_DODGE_TIME`
- `PLAYER_DODGE_INVULN_TIME`
- `PLAYER_DODGE_RECOVERY`
- `PLAYER_DODGE_COST`

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

Audio files live in `assets/audio/kenney/`.

Cue mapping lives in `scripts/autoload/CombatAudio.gd` under `CUE_PATHS`.

To swap a sound, replace the OGG file or change the path in `CUE_PATHS`.

## Sprites

Player sprites live in `assets/sprites/kenney/player_*.png`.

Enemy sprites live in:

- `assets/sprites/kenney/melee_*.png`
- `assets/sprites/kenney/hound_*.png`
- `assets/sprites/kenney/archer_*.png`
- `assets/sprites/kenney/elite_*.png`

Sprite selection happens in:

- `scripts/player/PlayerVisual.gd`
- `scripts/enemies/ShrineGuardianVisual.gd`

## VFX

VFX textures live in `assets/effects/kenney/`.

Effect behavior lives in `scripts/effects/CombatEffect.gd`.

Hit and perfect-dodge effect spawning happens in `scripts/world/ShrineArena.gd`.

## Wave Setup

Edit `scripts/trial/AshTrial.gd`.

Current waves:

- Wave 1: two `guardian`
- Wave 2: one `hound`, one `guardian`
- Wave 3: one `archer`, one `guardian`
- Final: one `bell_bearer`

Keep Stage 1 changes focused on this small combat trial unless the project scope changes.
