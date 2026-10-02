extends Node

signal changed

var data: Dictionary = {}

func _ready() -> void:
	load_data()

func default_data() -> Dictionary:
	return {
		"version": 1,
		"coins": 0,
		"best_score": 0,
		"games_played": 0,
		"total_red": 0,
		"total_score": 0,
		"longest_combo": 0,
		"total_time": 0.0,
		"selected_skin": "classic",
		"owned_skins": ["classic"],
		"powerups": {"shield": 1, "slow": 1},
		"sound": true,
		"vibration": true,
		"mission_claims": {},
		"daily_date": "",
		"daily_red": 0,
		"daily_claimed": false,
		"achievements": [],
		"leaderboard": []
	}

func load_data() -> void:
	data = default_data()
	if not FileAccess.file_exists(GameConfig.SAVE_PATH):
		roll_daily()
		return
	var file := FileAccess.open(GameConfig.SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		for key in data.keys():
			if parsed.has(key) and typeof(parsed[key]) == typeof(data[key]):
				data[key] = parsed[key]
	if not GameConfig.SKINS.has(data["selected_skin"]):
		data["selected_skin"] = "classic"
	roll_daily()

func save() -> void:
	var file := FileAccess.open(GameConfig.SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not save game: %s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(data))
	changed.emit()

func roll_daily() -> void:
	var date := Time.get_date_string_from_system()
	if data["daily_date"] != date:
		data["daily_date"] = date
		data["daily_red"] = 0
		data["daily_claimed"] = false
		save()

func add_red() -> void:
	data["total_red"] += 1
	roll_daily()
	data["daily_red"] += 1
	save()

func finish_run(score: int, combo: int, elapsed: float) -> int:
	data["games_played"] += 1
	data["total_score"] += score
	data["total_time"] += elapsed
	data["best_score"] = maxi(data["best_score"], score)
	data["longest_combo"] = maxi(data["longest_combo"], combo)
	var reward := score / 10
	data["coins"] += reward
	var board: Array = data["leaderboard"]
	board.append({"score": score, "date": Time.get_date_string_from_system()})
	board.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	board.resize(mini(board.size(), 10))
	data["leaderboard"] = board
	check_achievements()
	save()
	return reward

func check_achievements() -> void:
	var targets := {"first_game": data["games_played"] >= 1, "red_100": data["total_red"] >= 100, "combo_20": data["longest_combo"] >= 20, "score_500": data["best_score"] >= 500}
	for id in targets:
		if targets[id] and not data["achievements"].has(id):
			data["achievements"].append(id)

func claim_mission(id: String, target: int, reward: int, progress: int) -> bool:
	if progress < target or data["mission_claims"].has(id):
		return false
	data["mission_claims"][id] = true
	data["coins"] += reward
	save()
	return true

func claim_daily() -> bool:
	roll_daily()
	if data["daily_red"] < 30 or data["daily_claimed"]:
		return false
	data["daily_claimed"] = true
	data["coins"] += 50
	save()
	return true

func buy_skin(id: String) -> bool:
	if not GameConfig.SKINS.has(id):
		return false
	if data["owned_skins"].has(id):
		data["selected_skin"] = id
		save()
		return true
	var price: int = GameConfig.SKINS[id]["price"]
	if data["coins"] < price:
		return false
	data["coins"] -= price
	data["owned_skins"].append(id)
	data["selected_skin"] = id
	save()
	return true

func buy_power(id: String) -> bool:
	if not GameConfig.POWER_PRICES.has(id):
		return false
	var price: int = GameConfig.POWER_PRICES[id]
	if data["coins"] < price:
		return false
	data["coins"] -= price
	data["powerups"][id] = int(data["powerups"].get(id, 0)) + 1
	save()
	return true

func use_power(id: String) -> bool:
	if int(data["powerups"].get(id, 0)) <= 0:
		return false
	data["powerups"][id] -= 1
	save()
	return true
