extends Control

const OrbScript = preload("res://scripts/orb.gd")

var page := "menu"
var root_box: VBoxContainer
var playfield: Control
var hud_label: Label
var power_label: Label
var pause_button: Button
var rng := RandomNumberGenerator.new()
var score := 0
var combo := 0
var peak_combo := 0
var lives := 3
var elapsed := 0.0
var spawn_clock := 0.0
var slow_left := 0.0
var shield := false
var paused := false
var last_reward := 0

func _ready() -> void:
	rng.randomize()
	AppState.changed.connect(_on_data_changed)
	show_menu()

func _process(delta: float) -> void:
	if page != "game" or paused:
		return
	elapsed += delta
	slow_left = maxf(0.0, slow_left - delta)
	spawn_clock -= delta
	if spawn_clock <= 0.0:
		spawn_orb()
		var level := int(elapsed / 15.0)
		var interval := maxf(0.43, 1.2 - level * 0.09)
		spawn_clock = interval * (1.6 if slow_left > 0.0 else 1.0)
	update_hud()

func reset_screen(title: String) -> VBoxContainer:
	for child in get_children():
		child.queue_free()
	root_box = VBoxContainer.new()
	root_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_box.add_theme_constant_override("separation", 14)
	add_child(root_box)
	var header := make_label(title, 40, true)
	header.custom_minimum_size.y = 90
	root_box.add_child(header)
	return root_box

func make_label(content: String, font_size: int = 25, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = content
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", GameConfig.TEXT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func make_button(content: String, action: Callable, accent: bool = false) -> Button:
	var button := Button.new()
	button.text = content
	button.custom_minimum_size.y = 72
	button.add_theme_font_size_override("font_size", 25)
	button.add_theme_color_override("font_color", GameConfig.TEXT)
	var style := StyleBoxFlat.new()
	style.bg_color = GameConfig.RED if accent else GameConfig.PANEL
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.content_margin_left = 12
	style.content_margin_right = 12
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.pressed.connect(action)
	return button

func add_page_button(content: String, action: Callable, accent: bool = false) -> Button:
	var button := make_button(content, action, accent)
	root_box.add_child(button)
	return button

func add_spacer() -> void:
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_box.add_child(spacer)

func add_back() -> void:
	add_spacer()
	add_page_button("Back", show_menu)

func show_menu() -> void:
	page = "menu"
	paused = false
	reset_screen("DON'T TOUCH RED")
	root_box.add_child(make_label("RED = SAFE   •   NON-RED = DANGEROUS", 23, true))
	root_box.add_child(make_label("Best: %d     Coins: %d" % [AppState.data["best_score"], AppState.data["coins"]], 25, true))
	add_spacer()
	add_page_button("PLAY", start_game, true)
	add_page_button("Shop & Skins", show_shop)
	add_page_button("Missions & Daily", show_missions)
	add_page_button("Statistics & Achievements", show_stats)
	add_page_button("Settings", show_settings)
	add_spacer()
	root_box.add_child(make_label("v%s  •  Offline" % GameConfig.VERSION, 18, true))

func start_game() -> void:
	page = "game"
	score = 0
	combo = 0
	peak_combo = 0
	lives = GameConfig.STARTING_LIVES
	elapsed = 0.0
	spawn_clock = 0.3
	slow_left = 0.0
	shield = false
	paused = false
	reset_screen("DON'T TOUCH RED")
	hud_label = make_label("", 25, true)
	root_box.add_child(hud_label)
	playfield = Control.new()
	playfield.size_flags_vertical = Control.SIZE_EXPAND_FILL
	playfield.mouse_filter = Control.MOUSE_FILTER_PASS
	root_box.add_child(playfield)
	var powers := HBoxContainer.new()
	powers.add_theme_constant_override("separation", 12)
	root_box.add_child(powers)
	var shield_button := make_button("Shield", func(): activate_power("shield"))
	var slow_button := make_button("Slow", func(): activate_power("slow"))
	shield_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slow_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	powers.add_child(shield_button)
	powers.add_child(slow_button)
	power_label = make_label("", 19, true)
	root_box.add_child(power_label)
	pause_button = add_page_button("Pause", toggle_pause)
	update_hud()

func spawn_orb() -> void:
	if not is_instance_valid(playfield) or playfield.size.x < 100.0 or playfield.size.y < 130.0:
		return
	var level := int(elapsed / 15.0)
	var radius := maxf(28.0, 48.0 - level * 1.5)
	var lifetime := maxf(1.15, 2.5 - level * 0.15)
	if slow_left > 0.0:
		lifetime *= 1.6
	var orb = OrbScript.new()
	orb.setup(rng.randf() < 0.7, radius, lifetime)
	var bounds := playfield.size - Vector2(radius * 2.0, radius * 2.0)
	var position_found := false
	for attempt in 12:
		var point := Vector2(rng.randf_range(0.0, bounds.x), rng.randf_range(0.0, bounds.y))
		var clear := true
		for other in playfield.get_children():
			if point.distance_to(other.position) < radius * 2.2:
				clear = false
				break
		if clear:
			orb.position = point
			position_found = true
			break
	if not position_found:
		orb.free()
		return
	playfield.add_child(orb)
	orb.hit.connect(_on_orb_hit)
	orb.expired.connect(_on_orb_expired)

func _on_orb_hit(orb) -> void:
	if paused or page != "game":
		return
	if orb.safe:
		combo += 1
		peak_combo = maxi(peak_combo, combo)
		score += 10 * mini(5, 1 + combo / 5)
		AppState.add_red()
		Sound.play("hit")
	else:
		take_damage()
	update_hud()

func _on_orb_expired(orb) -> void:
	if page == "game" and not paused and orb.safe:
		take_damage()

func take_damage() -> void:
	combo = 0
	if shield:
		shield = false
		Sound.play("reward")
		return
	lives -= 1
	Sound.play("hurt")
	Sound.buzz()
	if lives <= 0:
		finish_game()

func activate_power(id: String) -> void:
	if page != "game" or paused or not AppState.use_power(id):
		return
	if id == "shield":
		shield = true
	elif id == "slow":
		slow_left = 8.0
	Sound.play("reward")
	update_hud()

func toggle_pause() -> void:
	if page != "game":
		return
	paused = not paused
	for orb in playfield.get_children():
		orb.set_process(not paused)
	pause_button.text = "Resume" if paused else "Pause"
	if paused:
		power_label.text = "PAUSED — tap Resume to continue"
	else:
		update_hud()

func update_hud() -> void:
	if page != "game" or not is_instance_valid(hud_label):
		return
	hud_label.text = "Score %d    Combo %d    Lives %d" % [score, combo, lives]
	if not paused:
		power_label.text = "Shield %d%s    Slow %d%s" % [AppState.data["powerups"]["shield"], " ACTIVE" if shield else "", AppState.data["powerups"]["slow"], " %.0fs" % slow_left if slow_left > 0.0 else ""]

func finish_game() -> void:
	if page != "game":
		return
	last_reward = AppState.finish_run(score, peak_combo, elapsed)
	page = "gameover"
	reset_screen("GAME OVER")
	add_spacer()
	root_box.add_child(make_label("Score: %d" % score, 38, true))
	root_box.add_child(make_label("Best: %d    Longest combo: %d" % [AppState.data["best_score"], peak_combo], 25, true))
	root_box.add_child(make_label("+%d coins" % last_reward, 27, true))
	add_spacer()
	add_page_button("Play Again", start_game, true)
	add_page_button("Main Menu", show_menu)

func show_shop() -> void:
	page = "shop"
	reset_screen("SHOP & SKINS")
	root_box.add_child(make_label("Coins: %d" % AppState.data["coins"], 27, true))
	root_box.add_child(make_label("Red stays safe in every skin.", 20, true))
	for id in GameConfig.SKINS:
		var skin: Dictionary = GameConfig.SKINS[id]
		var label: String = skin["name"]
		if AppState.data["selected_skin"] == id:
			label += "  ✓ Selected"
		elif AppState.data["owned_skins"].has(id):
			label += "  • Select"
		else:
			label += "  • %d coins" % skin["price"]
		add_page_button(label, func():
			AppState.buy_skin(id)
			show_shop())
	root_box.add_child(make_label("POWER-UPS", 24, true))
	for id in GameConfig.POWER_PRICES:
		add_page_button("%s • %d coins • owned %d" % [id.capitalize(), GameConfig.POWER_PRICES[id], AppState.data["powerups"][id]], func():
			AppState.buy_power(id)
			show_shop())
	add_back()

func show_missions() -> void:
	page = "missions"
	reset_screen("MISSIONS")
	root_box.add_child(make_label("Coins: %d" % AppState.data["coins"], 25, true))
	mission_button("red_50", "Tap 50 red orbs", 50, 75, AppState.data["total_red"])
	mission_button("games_10", "Play 10 games", 10, 60, AppState.data["games_played"])
	mission_button("combo_15", "Reach a 15 combo", 15, 80, AppState.data["longest_combo"])
	root_box.add_child(make_label("DAILY CHALLENGE • %s" % AppState.data["daily_date"], 24, true))
	var daily := "Tap 30 red orbs: %d/30 • 50 coins" % mini(30, AppState.data["daily_red"])
	if AppState.data["daily_claimed"]:
		daily += " ✓ Claimed"
	add_page_button(daily, func():
		AppState.claim_daily()
		show_missions())
	add_back()

func mission_button(id: String, title: String, target: int, reward: int, progress: int) -> void:
	var label := "%s: %d/%d • %d coins" % [title, mini(progress, target), target, reward]
	if AppState.data["mission_claims"].has(id):
		label += " ✓ Claimed"
	add_page_button(label, func():
		AppState.claim_mission(id, target, reward, progress)
		show_missions())

func show_stats() -> void:
	page = "stats"
	reset_screen("STATISTICS")
	var stats := "Games: %d\nBest score: %d\nTotal score: %d\nRed taps: %d\nLongest combo: %d\nTime played: %d min" % [AppState.data["games_played"], AppState.data["best_score"], AppState.data["total_score"], AppState.data["total_red"], AppState.data["longest_combo"], int(AppState.data["total_time"] / 60.0)]
	root_box.add_child(make_label(stats, 24, true))
	root_box.add_child(make_label("ACHIEVEMENTS", 27, true))
	var achievement_names := {"first_game": "First game", "red_100": "100 red taps", "combo_20": "20 combo", "score_500": "500 points"}
	for id in achievement_names:
		root_box.add_child(make_label(("✓ " if AppState.data["achievements"].has(id) else "○ ") + achievement_names[id], 21, true))
	root_box.add_child(make_label("LOCAL LEADERBOARD", 27, true))
	var board: Array = AppState.data["leaderboard"]
	for i in mini(board.size(), 5):
		root_box.add_child(make_label("%d. %d • %s" % [i + 1, board[i]["score"], board[i]["date"]], 21, true))
	add_back()

func show_settings() -> void:
	page = "settings"
	reset_screen("SETTINGS")
	add_page_button("Sound: %s" % ("On" if AppState.data["sound"] else "Off"), func():
		AppState.data["sound"] = not AppState.data["sound"]
		AppState.save()
		show_settings())
	add_page_button("Vibration: %s" % ("On" if AppState.data["vibration"] else "Off"), func():
		AppState.data["vibration"] = not AppState.data["vibration"]
		AppState.save()
		show_settings())
	root_box.add_child(make_label("Gameplay and saves work offline.\nYour progress is stored on this device.", 22, true))
	add_back()

func _on_data_changed() -> void:
	if page == "game":
		update_hud()
