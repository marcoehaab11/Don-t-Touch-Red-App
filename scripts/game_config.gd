extends Node

const VERSION := "1.0.0"
const ANDROID_VERSION_CODE := 1
const PACKAGE_NAME := "com.example.donttouchred"
const SAVE_PATH := "user://save.json"
const RED := Color("ff3b4f")
const BG := Color("0b1020")
const PANEL := Color("182238")
const TEXT := Color("f5f7ff")
const MUTED := Color("aab5ce")
const STARTING_LIVES := 3
const MAX_LIVES := 5
const SKINS := {
	"classic": {"name": "Classic", "price": 0, "color": "ff3b4f"},
	"coral": {"name": "Coral", "price": 120, "color": "ff625d"},
	"ruby": {"name": "Ruby", "price": 240, "color": "d7173b"},
	"neon": {"name": "Neon", "price": 400, "color": "ff1744"}
}
const POWER_PRICES := {"shield": 35, "slow": 30}

func red_color() -> Color:
	return Color(SKINS[AppState.data.get("selected_skin", "classic")]["color"])
