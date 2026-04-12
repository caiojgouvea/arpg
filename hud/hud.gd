extends Node2D

const BAR_W := 180.0
const BAR_H := 14.0
const GAP := 6.0
const MARGIN := Vector2(16.0, 16.0)
const FONT_SIZE := 10

var _player: Node = null
var _last_level := 1
var _levelup_timer := 0.0


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	if _player != null and _player.level != _last_level:
		_last_level = _player.level
		_levelup_timer = 2.0
	if _levelup_timer > 0.0:
		_levelup_timer -= delta
	queue_redraw()
func _input(event: InputEvent) -> void:
	if _player != null and _player.dead:
		if event is InputEventKey and event.pressed:
			if event.physical_keycode == KEY_R:
				get_tree().reload_current_scene()
			elif event.physical_keycode == KEY_ENTER:
				get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")


func _draw() -> void:
	if _player == null:
		return

	if _player.dead:
		_draw_death_screen()
		return

	var hp_ratio: float  = float(_player.health)  / float(_player.MAX_HEALTH)
	var fo_ratio: float  = float(_player.folego)  / float(_player.MAX_FOLEGO)
	var mn_ratio: float  = float(_player.mana)    / float(_player.MAX_MANA)
	_draw_bar(MARGIN,                                hp_ratio, Color(0.85, 0.15, 0.15),
			"%d/%d" % [_player.health, _player.MAX_HEALTH])
	_draw_bar(MARGIN + Vector2(0.0, BAR_H + GAP),    fo_ratio, Color(0.15, 0.75, 0.25),
			"%d/%d" % [int(_player.folego), int(_player.MAX_FOLEGO)])
	_draw_bar(MARGIN + Vector2(0.0, (BAR_H + GAP)*2), mn_ratio, Color(0.15, 0.35, 0.9),
			"%d/%d" % [int(_player.mana), int(_player.MAX_MANA)])
	var xp_ratio: float = float(_player.xp) / float(_player.xp_to_next)
	_draw_bar(MARGIN + Vector2(0.0, (BAR_H + GAP)*3), xp_ratio, Color(0.85, 0.75, 0.05),
			"XP %d/%d" % [_player.xp, _player.xp_to_next])

	if _levelup_timer > 0.0:
		var font := ThemeDB.fallback_font
		var vp := get_viewport_rect().size
		var alpha := minf(_levelup_timer, 0.5) / 0.5
		var c := Color(1.0, 1.0, 0.3, alpha * 0.85)
		draw_string(font, Vector2(0.0, vp.y / 2.0 - 60.0), "LEVELED UP",
				HORIZONTAL_ALIGNMENT_CENTER, vp.x, 22, c)


func _draw_death_screen() -> void:
	var font := ThemeDB.fallback_font
	var vp := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, vp), Color(0.0, 0.0, 0.0, 0.65))
	draw_string(font, Vector2(0.0, vp.y / 2.0 - 20.0), "YOU'VE DIED",
			HORIZONTAL_ALIGNMENT_CENTER, vp.x, 32, Color(0.85, 0.1, 0.1))
	draw_string(font, Vector2(0.0, vp.y / 2.0 + 20.0), "[R] Retry   [Enter] Menu",
			HORIZONTAL_ALIGNMENT_CENTER, vp.x, 14, Color(0.7, 0.7, 0.7))


func _draw_bar(pos: Vector2, ratio: float, color: Color, label: String) -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(pos, Vector2(BAR_W, BAR_H)), Color(0.1, 0.1, 0.1))
	draw_rect(Rect2(pos, Vector2(BAR_W * ratio, BAR_H)), color)
	draw_rect(Rect2(pos, Vector2(BAR_W, BAR_H)), Color(0, 0, 0), false, 1.0)
	draw_string(font, Vector2(pos.x, pos.y + BAR_H - 2.0), label,
			HORIZONTAL_ALIGNMENT_CENTER, BAR_W, FONT_SIZE, Color.BLACK)
