extends Node2D

const FONT_SIZE := 13
const LIFETIME := 0.9

var _amount := 0
var _color := Color.WHITE
var _elapsed := 0.0
var _vel := Vector2.ZERO


func init(amount: int, color: Color = Color.WHITE) -> void:
	_amount = amount
	_color = color
	_vel = Vector2(randf_range(-15.0, 15.0), -55.0)
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	position += _vel * delta
	_vel.y += 35.0 * delta
	modulate.a = 1.0 - (_elapsed / LIFETIME)
	if _elapsed >= LIFETIME:
		queue_free()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var text := str(_amount)
	var outline := Color(0.45, 0.45, 0.45)
	var offsets := [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]
	for o in offsets:
		draw_string(font, o, text, HORIZONTAL_ALIGNMENT_CENTER, -1, FONT_SIZE, outline)
	draw_string(font, Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_CENTER, -1, FONT_SIZE, _color)
