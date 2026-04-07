extends Node2D

const BAR_W := 180.0
const BAR_H := 14.0
const GAP := 6.0
const MARGIN := Vector2(16.0, 16.0)
const FONT_SIZE := 10

var _player: Node = null


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if _player == null:
		return
	var hp_ratio: float = float(_player.health) / float(_player.MAX_HEALTH)
	var fo_ratio: float = float(_player.folego) / float(_player.MAX_FOLEGO)
	_draw_bar(MARGIN, hp_ratio, Color(0.85, 0.15, 0.15),
			"%d/%d" % [_player.health, _player.MAX_HEALTH])
	_draw_bar(MARGIN + Vector2(0.0, BAR_H + GAP), fo_ratio, Color(0.15, 0.75, 0.25),
			"%d/%d" % [int(_player.folego), int(_player.MAX_FOLEGO)])


func _draw_bar(pos: Vector2, ratio: float, color: Color, label: String) -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(pos, Vector2(BAR_W, BAR_H)), Color(0.1, 0.1, 0.1))
	draw_rect(Rect2(pos, Vector2(BAR_W * ratio, BAR_H)), color)
	draw_rect(Rect2(pos, Vector2(BAR_W, BAR_H)), Color(0, 0, 0), false, 1.0)
	draw_string(font, Vector2(pos.x, pos.y + BAR_H - 2.0), label,
			HORIZONTAL_ALIGNMENT_CENTER, BAR_W, FONT_SIZE, Color.BLACK)
