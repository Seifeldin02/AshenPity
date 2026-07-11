# Stage 1.6 Design Review

## What Was Replaced

- Active player and enemy sprite paths now use the more detailed `assets/sprites/upgrade/` set instead of the flatter runtime crops.
- Normal enemies no longer use the top-screen boss bar. They use small local health bars near the enemy.
- The repeated floor texture now has a slab overlay pass, a stronger central/boss dais, and clearer arena framing.

## What Improved

- Boss/elite enemies now get the top-screen red boss bar; regular enemies stay local.
- Enemy spawns have ash/smoke arrival effects.
- Enemy hits spawn local blood, heavy, Collect, or Ash Burst effects.
- Enemy deaths spawn ash/smoke death payoff effects.
- The Bell-Bearer wave gets a stronger boss-spawn impact cue.
- The HUD is smaller and less debug-like, with shorter flask text and compact first-run hints.

## Still Weak

- The art direction is better, but still not final production art. A single professional dark-fantasy pack or commissioned set would improve the game far more than more code-side polish.
- The boss bar is functional and cleaner, but still needs a custom frame/icon treatment.
- Audio mix and animation timing still need human playtesting. Automated tests cannot judge hype, impact, or readability under real pressure.
