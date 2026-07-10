# Stage 1.5 Design Review

## What Felt Bad Before

- The shrine route was too large and too noisy for the current art quality. It read as tile spam instead of a composed combat slice.
- The HUD mixed real information with debug-like boon text, which made abilities feel vague and cheap.
- The fight started too early, before the player had a clear reason to care about the pickup shrine.
- Actor scale was still a little timid, so the player did not own the screen enough.
- The northern route could pinch movement and made the altar area feel less intentional.

## What Changed

- Rebuilt the playable space as a compact arena with an entrance, central fighting floor, side cover, altar focal point, and northern sanctum.
- Moved the combat trial behind a single shrine pickup. The player claims Ash Burst first, then the arena starts.
- Added Ash Burst as a readable active ability on `R`: a close-range ash shockwave with cooldown, VFX, sound, stagger, and HUD feedback.
- Reworked the HUD into a smaller top-left combat block. Ash Brand only appears when relevant, and Ash Burst only appears after it is unlocked.
- Added a world-space shrine prompt so the ability is taught where it is earned instead of living as permanent vague HUD text.
- Enlarged player and enemy visuals and adjusted shadows so actors feel more grounded and important.
- Widened the northern altar route and updated the deterministic playtest to verify traversal, visibility, perfect dodge, Collect, and the compact trial.

## Why

This sprint favors a stronger first screenshot and a more understandable first minute over map size. One clear arena with one obvious ability is more useful right now than a sprawling route full of mixed-quality props.

## Still Weak

- The project still needs a final cohesive paid-or-verified-free fantasy art set before it can look professional.
- The arena is more composed now, but it still depends on procedural/vector support art and existing tile assets.
- Ash Burst is functionally clear, but it needs human feel testing for cooldown, radius, and impact.
- Headless tests cannot judge whether the screen composition, audio mix, and animation timing actually feel exciting.

## What To Judge Next

- Does the first screenshot now read as an intentional arena instead of a messy test map?
- Does claiming Ash Burst and pressing `R` feel immediately understandable and useful?
- Does the compact encounter layout create good movement decisions without feeling cramped?
