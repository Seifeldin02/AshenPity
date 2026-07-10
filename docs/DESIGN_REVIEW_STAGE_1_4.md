# Stage 1.4 Design Review

## What Felt Bad Before

- The shrine floor looked like noisy procedural blocks instead of a designed place.
- Wall pieces read as cheap drawn rectangles and made the room feel assembled from mismatched parts.
- Random crack marks and debris lines created visual clutter without improving navigation.
- Actor bobbing and shadow placement made characters feel slightly detached from the ground.
- The HUD explained core mechanics like debug text instead of giving clear combat verbs.
- Boon pickup text did not clearly explain what changed or why the player should care.

## What Changed

- Reworked the shrine floor renderer to use the dungeon floor assets more directly.
- Added dark shrine runners and medallions to create a readable north/south route, central arena focus, and altar approach.
- Reduced random ash/crack noise and softened torch light pools.
- Simplified wall rendering so walls use tiled wall textures instead of mostly procedural line work.
- Reduced player and enemy vertical bob so sprites feel more grounded.
- Added stronger heavy/Collect blade accents in the player slash rendering.
- Reworked HUD copy so Ash Brand, Collect, parry, flask, and boons are described as direct combat actions.
- Added HUD backplates so health, stamina, brand status, and boon text remain readable over the world.
- Updated boon descriptions to explain the actual input/payoff.
- Updated the visible build label to `Ashen Pity - Shrine Design Pass v0.5.6`.

## Why It Changed

The main design problem was not missing systems. The prototype had enough combat verbs, but the surface presentation made them feel disposable. This pass prioritizes composition, readability, and player understanding: the shrine now has a central route and focal points, while the HUD tells the player what to do during combat instead of only naming systems.

## What Still Feels Weak

- The actor sprites are acceptable but still not strong enough to carry the final identity.
- The dungeon tiles are cleaner now, but the material palette is still limited and could use a proper art pass.
- The HUD is clearer but still functional rather than beautiful.
- Attack telegraphs are improved, but boss-level attacks still need more bespoke animation and audio timing.
- The playtest harness proves functionality and visibility, not whether the combat feels exciting by hand.

## What To Judge Next

- Whether the new floor runners and medallions make the route feel intentional instead of noisy.
- Whether the HUD explains `E` parry, `Q` Collect, and `F` flask clearly enough during a real fight.
- Whether reduced bobbing makes the player and enemies feel grounded while preserving smooth movement.
