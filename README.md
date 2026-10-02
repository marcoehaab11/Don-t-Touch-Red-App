# Don't Touch Red

A fast, offline reflex game for portrait phones. Tap red orbs before they expire, and keep away from every non-red orb.

## Game Concept

**RED = SAFE. NON-RED = DANGEROUS.** Tapping red earns points. Tapping a blue or yellow orb, or missing a red orb, costs a life. A run ends at zero lives.

## Features

- Fast reflex gameplay with a combo multiplier, three lives, and increasing spawn speed
- Shield and slow-time power-ups, earned coins, and a coin shop
- Four red skins, three persistent missions, and a daily challenge
- Statistics, achievements, and an offline local top-ten leaderboard
- Offline JSON saves, synthesized sound effects, optional vibration, and a portrait mobile UI
- Android export preset and version checks

Online leaderboards, ads, billing, cloud saves, and analytics are **planned integrations**, not active services.

## Tech Stack

Godot 4.x, GDScript, Android export, and a planned Google Play release. The project is developed against Godot **4.7.2**.

## Project Structure

- `project.godot`, `scenes/`: project setup and entry scene
- `scripts/main.gd`: screens, run loop, scoring, power-up use, and navigation
- `scripts/orb.gd`: tappable orb and expiration timer
- `scripts/app_state.gd`: saves, economy, missions, statistics, and local leaderboard
- `scripts/game_config.gd`: identity, version, colors, catalog, and balance constants
- `scripts/sound.gd`: generated sound effects and haptics
- `export_presets.cfg`: Android export defaults
- `tools/validate.py`, `.github/workflows/validate.yml`: repository checks
- `docs/`, `store-assets/`: developer, release, and store materials

## How to Run

1. Install Godot 4.7.2 (standard, non-.NET edition).
2. Clone this repository and import its `project.godot` in Godot Project Manager.
3. Press **F6** from `scenes/main.tscn`, or **F5** to run the project.

Headless check: `godot --headless --path . --editor --quit` then `godot --headless --path . --quit-after 30`.

## Android Build

Install the matching Godot export templates, OpenJDK 17, Android SDK, and Godot Android build template. Configure Java SDK Path and Android SDK Path in Editor Settings. Use **Project → Export → Android** for a debug APK. For a release AAB, create a private release keystore, choose the AAB export format, enter signing details, turn off **Export With Debug**, and save as `build/Don'tTouchRed-release.aab`. The package currently uses the placeholder `com.example.donttouchred`; replace it before publishing. See [Android build instructions](docs/ANDROID_BUILD.md).

No APK or AAB has been generated or submitted as part of the source tree.

## Development

Run `python tools/validate.py` and the two headless Godot commands before each commit. CI repeats these checks. Update `scripts/game_config.gd` first when changing the version or package, then sync `export_presets.cfg`; validation fails if they differ. Increase `ANDROID_VERSION_CODE` for every Play release. See [development guide](docs/DEVELOPMENT.md).

## Future Features

AdMob, Google Play Billing, Google Play Games, online leaderboards, cloud save, and analytics need platform accounts, SDKs, consent flows, and device testing before activation. See [monetization plan](docs/MONETIZATION.md).
