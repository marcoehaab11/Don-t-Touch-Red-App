# Release Checklist

- [ ] Test red, non-red, combo, lives, difficulty, game over, restart, and pause
- [ ] Test shop, skins, power-ups, missions, daily reset, achievements, and local leaderboard
- [ ] Test every screen at narrow and wide phone sizes; check touch targets and text clipping
- [ ] Test debug APK on supported Android devices and orientations
- [ ] Profile spawn performance, memory, startup, and battery use
- [ ] Test fresh save, upgrades, interrupted writes, and reinstall behavior
- [ ] Confirm ad behavior and consent if ads are added
- [ ] Confirm purchase verification and restore if billing is added
- [ ] Publish an accurate privacy policy and complete Play data safety disclosures
- [ ] Replace placeholder app icon and review screenshots and feature graphic
- [ ] Review title, description, category, content rating, and store listing
- [ ] Increment Android version code and set version name
- [ ] Set final package ID before first publication
- [ ] Verify private release signing and backup the upload key
- [ ] Export and test `Don'tTouchRed-release.aab`
- [ ] Run `python tools/validate.py` and headless Godot checks
- [ ] Review tracked files for secrets, keys, and generated binaries
- [ ] Submit to a Google Play internal test track, then review before production
