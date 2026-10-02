# Android Build

This repository includes an Android export preset, but no signing identity or generated binary. Validate on a real Android device before release.

1. Install Godot 4.7.2 and its matching Android export templates.
2. Install OpenJDK 17 and the Android SDK packages required by [Godot's Android export guide](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html).
3. In Godot, set **Editor Settings → Export → Android → Java SDK Path** and **Android SDK Path**.
4. Open `project.godot`; choose **Project → Install Android Build Template**. The generated `android/build/` stays ignored by Git.
5. Open **Project → Export → Android**. Check the placeholder package ID, version name, and version code. Export with debug enabled to `build/Don'tTouchRed-debug.apk` for device testing.

## Release AAB

1. Choose the final production package ID before first publication. Update `scripts/game_config.gd` and `export_presets.cfg` together; run `python tools/validate.py`.
2. Increase `ANDROID_VERSION_CODE` above the previous Play release and sync `version/code` in the preset. Choose a display `VERSION` and sync `version/name`.
3. Create a private release keystore with `keytool -genkeypair -v -keystore <private-path>/upload.jks -alias upload -keyalg RSA -keysize 3072 -validity 10000`. Keep the file and passwords outside the repository, with a secure backup.
4. In the Android export preset, select **AAB** export format. Enter the private release keystore path, alias, and password in the Release signing fields. Godot also accepts `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `GODOT_ANDROID_KEYSTORE_RELEASE_USER`, and `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD` environment variables.
5. Turn **Export With Debug** off. Export to `build/Don'tTouchRed-release.aab`. Check the resulting bundle on a test track before production submission.

No signing key or password belongs in the project or GitHub. If a future CI release job is added, provide these values through GitHub Secrets and create the keystore file only inside the ephemeral runner. This project currently uses manual Android export because release signing and device validation require owner setup.
