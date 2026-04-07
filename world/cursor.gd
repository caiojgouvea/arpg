extends Node2D

const COLOR := Color(1.0, 1.0, 1.0, 0.9)
const SIZE := 8.0
const GAP := 3.0
const WIDTH := 1.5


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _process(_delta: float) -> void:
	var paused := get_tree().paused
	visible = not paused
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		global_position = get_global_mouse_position()


func _draw() -> void:
	draw_line(Vector2(-SIZE - GAP, 0), Vector2(-GAP, 0), COLOR, WIDTH)
	draw_line(Vector2(GAP, 0),         Vector2(SIZE + GAP, 0), COLOR, WIDTH)
	draw_line(Vector2(0, -SIZE - GAP), Vector2(0, -GAP), COLOR, WIDTH)
	draw_line(Vector2(0, GAP),         Vector2(0, SIZE + GAP), COLOR, WIDTH)
	draw_circle(Vector2.ZERO, 1.5, COLOR)
