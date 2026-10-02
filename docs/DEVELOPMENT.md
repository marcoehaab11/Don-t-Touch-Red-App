# Development

1. Install Godot 4.7.2 and open `project.godot`.
2. Run the project with F5. Check red taps, dangerous taps, red expiration, combos, lives, pause, both power-ups, game over, restart, and all menu pages.
3. Run `python tools/validate.py`.
4. Run `godot --headless --path . --editor --quit` and `godot --headless --path . --quit-after 30` with the matching Godot binary.
5. Run `DTR_TEST_MODE=1 godot --headless --path . --script res://tests/smoke.gd` (PowerShell: `$env:DTR_TEST_MODE='1'; godot --headless --path . --script res://tests/smoke.gd`). Test mode avoids writing save data.
6. Commit a working phase with a clear message and push it. GitHub Actions runs the same structural and Godot checks.

`scripts/game_config.gd` is the human-edited source for version `1.0.0`, Android code `1`, and package `com.example.donttouchred`. Copy those three values into `export_presets.cfg` after changes; `tools/validate.py` enforces agreement. Increase the Android version code for every Play release, even if the display version changes only slightly. Replace the example package before first production release; Android treats package IDs as permanent after publication.

Balances and skin prices are in `GameConfig`; run behavior is in `main.gd`. UI is drawn from Godot Controls, so no external graphics license is needed. Save data is local to the Godot user data directory and is not included in Git.
