extends Control

signal hit(orb)
signal expired(orb)

var safe := false
var radius := 48.0
var lifetime := 2.2
var age := 0.0
var active := true

func setup(is_safe: bool, orb_radius: float, duration: float) -> void:
	safe = is_safe
	radius = orb_radius
	lifetime = duration
	custom_minimum_size = Vector2(radius * 2.0, radius * 2.0)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP

func _process(delta: float) -> void:
	if not active:
		return
	age += delta
	if age >= lifetime:
		active = false
		expired.emit(self)
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	var center := size / 2.0
	var fill := GameConfig.red_color() if safe else Color("25a9ef")
	if not safe and int(get_instance_id()) % 2 == 0:
		fill = Color("f3bc38")
	draw_circle(center, radius + 5.0, Color(fill, 0.18))
	draw_circle(center, radius, fill)
	draw_arc(center, radius + 3.0, -PI / 2.0, -PI / 2.0 + TAU * (1.0 - age / lifetime), 40, Color.WHITE, 4.0, true)
	draw_circle(center - Vector2(radius * 0.3, radius * 0.3), radius * 0.15, Color(1, 1, 1, 0.28))

func _gui_input(event: InputEvent) -> void:
	if not active:
		return
	var pressed: bool = event is InputEventScreenTouch and event.pressed
	pressed = pressed or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if pressed:
		if event.position.distance_to(size / 2.0) <= radius:
			active = false
			hit.emit(self)
			queue_free()
		accept_event()
