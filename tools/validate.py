"""Fast repository checks. Run with: python tools/validate.py"""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
required = [
    "project.godot", "export_presets.cfg", ".gitignore", "README.md",
    "scenes/main.tscn", "scripts/main.gd", "scripts/orb.gd",
    "scripts/app_state.gd", "scripts/game_config.gd", "scripts/sound.gd",
    "docs/GAME_DESIGN.md", "docs/ARCHITECTURE.md", "docs/DEVELOPMENT.md",
    "docs/ANDROID_BUILD.md", "docs/MONETIZATION.md",
    "docs/RELEASE_CHECKLIST.md", "docs/GOOGLE_PLAY_LISTING.md",
]
errors = [f"Missing {name}" for name in required if not (ROOT / name).is_file()]
project = (ROOT / "project.godot").read_text(encoding="utf-8")
config = (ROOT / "scripts/game_config.gd").read_text(encoding="utf-8")
preset = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
scene = (ROOT / "scenes/main.tscn").read_text(encoding="utf-8")
ignore = (ROOT / ".gitignore").read_text(encoding="utf-8")
for needle in ('run/main_scene="res://scenes/main.tscn"', 'AppState="*res://scripts/app_state.gd"'):
    if needle not in project:
        errors.append(f"project.godot lacks {needle}")
if 'res://scripts/main.gd' not in scene:
    errors.append("Main scene script is missing")
for name in ("VERSION", "ANDROID_VERSION_CODE", "PACKAGE_NAME"):
    match = re.search(rf"const {name} := (.+)", config)
    if not match:
        errors.append(f"Missing central {name}")
        continue
    value = match.group(1).strip()
    field = {"VERSION": "version/name", "ANDROID_VERSION_CODE": "version/code", "PACKAGE_NAME": "package/unique_name"}[name]
    if f"{field}={value}" not in preset:
        errors.append(f"{field} differs from GameConfig.{name}")
for pattern in (".godot/", "*.keystore", "*.jks", "*.aab", "*.apk"):
    if pattern not in ignore:
        errors.append(f".gitignore lacks {pattern}")
for file in ROOT.rglob("*"):
    relative = file.relative_to(ROOT)
    ignored_generated = (
        any(part in {".git", ".godot"} for part in relative.parts)
        or relative.parts[0] == "build"
        or relative.parts[:2] == ("android", "build")
    )
    if file.is_file() and not ignored_generated:
        if file.suffix.lower() in {".keystore", ".jks", ".p12", ".pem", ".key", ".apk", ".aab"}:
            errors.append(f"Sensitive or generated file found: {relative}")
for error in errors:
    print("ERROR:", error)
print(f"Validation: {'failed' if errors else 'passed'} ({len(errors)} error(s))")
sys.exit(1 if errors else 0)
