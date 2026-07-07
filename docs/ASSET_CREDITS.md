# Asset Credits

## Stage 1.3 Asset Policy

No external art, sprite, font, or audio assets were added for Stage 1.3.

All current character visuals, enemy visuals, environment drawing, combat effects, and UI shapes are original project-authored code-drawn assets made inside this repository.

## Visual Assets

- Player hooded wanderer: original vector-style drawing in `scripts/player/PlayerVisual.gd`.
- Shrine Guardian: original vector-style drawing in `scripts/enemies/ShrineGuardianVisual.gd`.
- Ashbound Hound: original vector-style drawing in `scripts/enemies/ShrineGuardianVisual.gd`.
- Reliquary Archer: original vector-style drawing in `scripts/enemies/ShrineGuardianVisual.gd`.
- Bell-Bearer: original vector-style drawing in `scripts/enemies/ShrineGuardianVisual.gd`.
- Shrine environment, floor, cracks, ash, walls, torch pools, and props: original code-drawn world art in `scripts/world/ShrineRouteLayer.gd`.
- Combat effects: original code-drawn temporary effects in `scripts/effects/CombatEffect.gd`.

## Audio Assets

Stage 1.3 uses runtime procedural audio generated in `scripts/autoload/CombatAudio.gd`.

Procedural cues currently include:

- sword whoosh
- light hit
- heavy hit
- armor hit
- enemy stagger
- perfect dodge
- Ash Brand applied
- Collect execution
- player hurt
- dodge
- flask use
- enemy death

No third-party audio files are present.

## Fonts

The project uses Godot's default UI font.

## Future External Assets

If external assets are added later:

- Use only original, CC0, CC-BY, or clearly commercial-use licensed assets.
- Place third-party files under `assets/third_party/`.
- Include the original license text and source URL.
- Update this document in the same commit.
- Do not add copyrighted sprites, ripped assets, screenshots, recognizable commercial characters, or unverified downloads.
