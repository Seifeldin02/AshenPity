# Mobile Foundation

Ashen Pity is designed for mobile from the beginning instead of treating touch support as a late port.

## Current Design

- The game uses shared gameplay actions for desktop and mobile input.
- Movement and aim are separated so attacks can be aimed independently from walking.
- The arena uses a 16:9 landscape layout that leaves lower corners available for touch controls.
- HUD elements stay near safe margins and avoid the center combat lane.
- Touch controls can be shown on desktop with `M` for fast testing.
- Touch buttons call the same attack, dodge, flask, and pause actions used by desktop play.
- The right-side drag zone controls aim direction without replacing desktop mouse aim.

## Desktop Touch Testing

Press `M` while running the game to show or hide the mobile controls. This lets designers test joystick, aim-zone, attack, dodge, flask, and pause layout without deploying to a phone.

## Future Android Export Requirements

Before production Android export, the project will need:

- Android SDK and build template setup in Godot.
- Signing key management outside the repository.
- Device performance testing.
- Touch latency checks.
- Safe-area testing across several landscape phone sizes.
- Export preset review.

This stage does not attempt a production Android export unless a complete Android SDK setup already exists.
