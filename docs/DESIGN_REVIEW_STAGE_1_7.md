# Stage 1.7 Clarity and Polish Review

## What Glitches Were Fixed

- Removed the duplicate drawn weapon overlay from the player visual, which was fighting the sprite art and making the main character look jittery/glitched during movement and attacks.
- Reduced exaggerated bob, rotation, squash, and stretch values on the player so idle, run, dodge, hurt, attack, and Collect transitions read cleaner.
- Removed the large black HUD backplate behind the player bars. The main HUD no longer looks like a broken debug panel.
- Replaced circular/line projectile visuals with shaped bolts.

## What Visuals Were Removed or Replaced

- Removed normal-gameplay `draw_arc`, `draw_circle`, `draw_line`, and `draw_polyline` placeholder calls from the world, enemy, effect, player, and HUD scripts.
- Replaced Ash Brand rings with a floating ember mark above the target.
- Replaced ring-shaped boss and Ash Burst effects with smoke, shards, blade cuts, and jagged burst shapes.
- Replaced sketchy wall strokes with block seams, stone chips, and broken plates.
- Reworked shrine pickups, floor markers, light pools, and boss-dais art away from circles/lines toward slab, diamond, and flame-shaped forms.

## Readability Improvements

- Boss health remains top-screen and boss-only.
- Normal enemies keep local health bars only when damaged.
- The HUD is smaller, cleaner, and less debug-like.
- Enemy telegraphs and combat effects are less dominated by placeholder circles, making the player, enemy, and incoming danger easier to parse.
- The player silhouette is clearer because the sprite art is no longer covered by a second procedural sword.

## Still Weak

- The art direction is cleaner, but it still needs a more cohesive final sprite and tileset pass.
- Human playtesting is still needed for animation feel, especially attack cancel timing, hurt readability, and whether boss effects are exciting without becoming noisy.
- The arena composition is less cluttered than before, but the environment still needs a stronger authored visual identity before it will feel production-grade.
