# Architecture

`scenes/main.tscn` starts a single responsive Control scene. `scripts/main.gd` builds the menu, game HUD, shop, missions, statistics, settings, and game-over views. It owns the run state and spawn timer. Each orb is a `scripts/orb.gd` Control that draws itself, detects a tap within its circle, and emits hit or expiration signals.

Autoloads keep shared responsibilities out of the scene: `GameConfig` holds app identity and balance data; `AppState` owns JSON persistence, economy, achievements, daily state, and local leaderboard; `Sound` creates tiny PCM effects and triggers vibration. No network dependency is needed for a run.

`AppState` saves to `user://save.json`. It accepts only known fields with matching top-level types when loading. Save version 1 is stored for future migration; any schema change should add a migration before increasing it. Local leaderboard records are `{score, date}` entries ordered by descending score.

Future online leaderboard or cloud save providers should be separate adapters that synchronize with `AppState` without making gameplay depend on a network response. Ads and purchases should likewise sit behind a service interface; only verified purchase callbacks may grant coins or items.
