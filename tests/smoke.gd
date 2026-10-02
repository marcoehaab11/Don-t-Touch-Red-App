extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var state = root.get_node("AppState")
	state.data = state.default_data()
	state.data["sound"] = false
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	if scene.page != "menu" or scene.root_box.get_child_count() < 5:
		fail("menu did not initialize")
		return
	scene.start_game()
	await process_frame
	if scene.page != "game" or scene.lives != 3 or scene.playfield == null:
		fail("game did not initialize")
		return
	var red = load("res://scripts/orb.gd").new()
	red.safe = true
	scene._on_orb_hit(red)
	if scene.score != 10 or scene.combo != 1 or state.data["total_red"] != 1:
		fail("red scoring failed")
		return
	var danger = load("res://scripts/orb.gd").new()
	danger.safe = false
	scene._on_orb_hit(danger)
	if scene.lives != 2 or scene.combo != 0:
		fail("danger damage failed")
		return
	scene.activate_power("shield")
	scene._on_orb_hit(danger)
	if scene.lives != 2 or scene.shield:
		fail("shield failed")
		return
	scene.activate_power("slow")
	if scene.slow_left <= 0.0 or state.data["powerups"]["slow"] != 0:
		fail("slow power failed")
		return
	scene.spawn_orb()
	if scene.playfield.get_child_count() < 1:
		fail("orb did not spawn")
		return
	scene.toggle_pause()
	if not scene.paused:
		fail("pause failed")
		return
	scene.toggle_pause()
	if scene.paused:
		fail("resume failed")
		return
	scene.take_damage()
	scene.take_damage()
	if scene.page != "gameover" or state.data["games_played"] != 1:
		fail("game over failed")
		return
	scene.start_game()
	await process_frame
	if scene.page != "game" or scene.score != 0 or scene.lives != 3:
		fail("restart failed")
		return
	scene.show_shop()
	await process_frame
	if scene.page != "shop" or not fits(scene):
		fail("shop failed")
		return
	scene.show_missions()
	await process_frame
	if scene.page != "missions" or not fits(scene):
		fail("missions failed")
		return
	scene.show_stats()
	await process_frame
	if scene.page != "stats" or not fits(scene):
		fail("stats failed")
		return
	scene.show_settings()
	await process_frame
	if scene.page != "settings" or not fits(scene):
		fail("settings failed")
		return
	state.data["coins"] = 500
	if not state.buy_skin("neon") or state.data["selected_skin"] != "neon":
		fail("skin purchase failed")
		return
	if not state.buy_power("shield") or state.data["powerups"]["shield"] != 1:
		fail("power purchase failed")
		return
	state.data["daily_red"] = 30
	state.data["daily_date"] = Time.get_date_string_from_system()
	if not state.claim_daily() or state.claim_daily():
		fail("daily claim failed")
		return
	red.free()
	danger.free()
	scene.queue_free()
	var sound = root.get_node("Sound")
	sound.player.stop()
	sound.player.stream = null
	sound.tones.clear()
	await process_frame
	await process_frame
	print("Smoke checks passed")
	quit(0)

func fail(message: String) -> void:
	push_error(message)
	quit(1)

func fits(scene) -> bool:
	for control in scene.root_box.get_children():
		if control is Control and control.position.y + control.size.y > scene.size.y + 2.0:
			return false
	return true
