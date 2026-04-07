extends Node2D

const PANEL_W := 300.0
const FONT_SIZE := 12
const BTN_SIZE := 22.0
const SECTION_COLOR := Color(0.5, 0.5, 0.6)

const ATTRS := ["fury", "instinct", "arcane"]
const ATTR_LABELS := {"fury": "Furia", "instinct": "Instinto", "arcane": "Arcano"}
const ATTR_COLORS := {
	"fury":     Color(0.95, 0.2,  0.2),
	"instinct": Color(0.2,  0.85, 0.2),
	"arcane":   Color(0.65, 0.2,  0.95),
}
const ATTR_DESC := {
	"fury":     "+2 dano fisico  +5 HP max",
	"instinct": "+0.5% vel  +2% atk spd  +0.3% crit  +5 Folego max",
	"arcane":   "+2 dano magico  +5 Mana max",
}

var _open := false
var _player: Node = null
var _btn_rects := {}


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_player = get_tree().get_first_node_in_group("player")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_C:
			_open = not _open
			get_tree().paused = _open
			queue_redraw()

	if _open and event is InputEventMouseButton \
			and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for attr in _btn_rects:
			if _btn_rects[attr].has_point(event.position):
				_spend_point(attr)
				return


func _spend_point(attr: String) -> void:
	if _player == null or _player.attribute_points <= 0:
		return
	_player.attribute_points -= 1
	_player[attr] += 1
	queue_redraw()


func _draw() -> void:
	if not _open or _player == null:
		return

	var font := ThemeDB.fallback_font
	var vp := get_viewport_rect().size
	var px := 0.0

	# Altura dinâmica: header + attrs + stats + footer
	var attr_h := ATTRS.size() * 48.0
	var stats_h := 160.0
	var panel_h := 90.0 + attr_h + stats_h + 20.0
	var py := (vp.y - panel_h) / 2.0

	# Fundo
	draw_rect(Rect2(px, py, PANEL_W, panel_h), Color(0.07, 0.07, 0.12, 0.96))
	draw_rect(Rect2(px, py, PANEL_W, panel_h), Color(0.45, 0.45, 0.55), false, 1.5)

	var cy := py + 20.0

	# === CABEÇALHO ===
	draw_string(font, Vector2(px, cy), "PERSONAGEM",
			HORIZONTAL_ALIGNMENT_CENTER, PANEL_W, 15, Color.WHITE)
	cy += 18.0
	draw_string(font, Vector2(px, cy), "Nivel %d" % _player.level,
			HORIZONTAL_ALIGNMENT_CENTER, PANEL_W, 11, Color(0.75, 0.75, 0.8))
	cy += 18.0

	var pts_color := Color(1.0, 0.85, 0.15) if _player.attribute_points > 0 else Color(0.5, 0.5, 0.5)
	draw_string(font, Vector2(px, cy), "Pontos de atributo: %d" % _player.attribute_points,
			HORIZONTAL_ALIGNMENT_CENTER, PANEL_W, FONT_SIZE, pts_color)
	cy += 16.0
	draw_string(font, Vector2(px, cy), "Pontos de talento: %d" % _player.talent_points,
			HORIZONTAL_ALIGNMENT_CENTER, PANEL_W, FONT_SIZE, Color(0.6, 0.4, 0.9))
	cy += 20.0

	# === ATRIBUTOS ===
	_draw_separator(font, px, cy, "ATRIBUTOS")
	cy += 16.0
	for attr in ATTRS:
		_draw_attr_row(font, px, cy, attr)
		cy += 48.0

	# === STATS ===
	_draw_separator(font, px, cy, "STATS")
	cy += 18.0

	var stats := [
		["Vida",           "%d / %d" % [_player.health, _player.MAX_HEALTH],              Color(0.9, 0.2, 0.2)],
		["Folego",         "%d / %d" % [int(_player.folego), int(_player.MAX_FOLEGO)],    Color(0.2, 0.8, 0.3)],
		["Mana",           "%d / %d" % [int(_player.mana), int(_player.MAX_MANA)],        Color(0.15, 0.35, 0.9)],
		["Vel. Movimento", "%.0f px/s" % _player.move_speed,                              Color(0.8, 0.8, 0.2)],
		["Atk Speed",      "%.2fx/s" % _player.attack_speed,                              Color(0.9, 0.6, 0.1)],
		["Dano Fisico",    "+%d" % _player.physical_damage,                               Color(0.95, 0.2, 0.2)],
		["Dano Magico",    "+%d" % _player.magic_damage,                                  Color(0.65, 0.2, 0.95)],
		["Critico",        "%.1f%%" % (_player.crit_chance * 100.0),                      Color(0.9, 0.85, 0.1)],
	]

	for stat in stats:
		draw_string(font, Vector2(px + 14.0, cy), stat[0],
				HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, Color(0.7, 0.7, 0.75))
		draw_string(font, Vector2(px, cy), stat[1],
				HORIZONTAL_ALIGNMENT_RIGHT, PANEL_W - 14.0, FONT_SIZE, stat[2])
		cy += 20.0

	# Dica fechar
	draw_string(font, Vector2(px, py + panel_h - 8.0), "[C] Fechar",
			HORIZONTAL_ALIGNMENT_CENTER, PANEL_W, 10, Color(0.4, 0.4, 0.45))


func _draw_separator(font: Font, px: float, cy: float, label: String) -> void:
	draw_line(Vector2(px + 10, cy - 4), Vector2(px + PANEL_W - 10, cy - 4), SECTION_COLOR, 1.0)
	draw_string(font, Vector2(px, cy + 8.0), label,
			HORIZONTAL_ALIGNMENT_CENTER, PANEL_W, 10, SECTION_COLOR)


func _draw_attr_row(font: Font, px: float, row_y: float, attr: String) -> void:
	var color: Color = ATTR_COLORS[attr]
	var can_spend: bool = _player.attribute_points > 0

	draw_string(font, Vector2(px + 14.0, row_y + 14.0),
			ATTR_LABELS[attr], HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, color)
	draw_string(font, Vector2(px + 120.0, row_y + 14.0),
			str(_player[attr]), HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, Color.WHITE)
	draw_string(font, Vector2(px + 14.0, row_y + 30.0),
			ATTR_DESC[attr], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.55, 0.55, 0.6))

	var btn_rect := Rect2(px + PANEL_W - 40.0, row_y + 4.0, BTN_SIZE, BTN_SIZE)
	_btn_rects[attr] = btn_rect
	var btn_bg := Color(0.15, 0.45, 0.15) if can_spend else Color(0.2, 0.2, 0.22)
	draw_rect(btn_rect, btn_bg)
	draw_rect(btn_rect, color if can_spend else Color(0.35, 0.35, 0.35), false, 1.0)
	draw_string(font, Vector2(btn_rect.position.x, btn_rect.position.y + BTN_SIZE - 3.0),
			"+", HORIZONTAL_ALIGNMENT_CENTER, BTN_SIZE, 15, Color.WHITE)
