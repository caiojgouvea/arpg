extends Node2D

const COLOR := Color(1.0, 1.0, 1.0, 0.9)
const SIZE := 8.0
const GAP := 3.0
const WIDTH := 1.5


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()


func _draw() -> void:
	# Linhas da mira
	draw_line(Vector2(-SIZE - GAP, 0), Vector2(-GAP, 0), COLOR, WIDTH)
	draw_line(Vector2(GAP, 0),         Vector2(SIZE + GAP, 0), COLOR, WIDTH)
	draw_line(Vector2(0, -SIZE - GAP), Vector2(0, -GAP), COLOR, WIDTH)
	draw_line(Vector2(0, GAP),         Vector2(0, SIZE + GAP), COLOR, WIDTH)
	# Ponto central
	draw_circle(Vector2.ZERO, 1.5, COLOR)
