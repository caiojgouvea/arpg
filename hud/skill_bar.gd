extends Node2D

const SLOT_SIZE := 48.0
const GAP := 8.0
const FONT_SIZE := 11

const SKILLS := [
	{"id": "fire",   "name": "Fogo",   "key": "1", "color": Color(1.0, 0.35, 0.05)},
	{"id": "poison", "name": "Veneno", "key": "2", "color": Color(0.2, 0.8,  0.15)},
]

var selected := 0


func _ready() -> void:
	add_to_group("skill_bar")
	queue_redraw()


func get_selected_skill() -> String:
	return SKILLS[selected]["id"]


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1: _select(0)
			KEY_2: _select(1)


func _select(index: int) -> void:
	if index < SKILLS.size():
		selected = index
		queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var vp := get_viewport_rect().size
	var total_w := SKILLS.size() * SLOT_SIZE + (SKILLS.size() - 1) * GAP
	var start_x := (vp.x - total_w) / 2.0
	var start_y := vp.y - SLOT_SIZE - 20.0

	for i in SKILLS.size():
		var skill: Dictionary = SKILLS[i]
		var sx := start_x + i * (SLOT_SIZE + GAP)
		var rect := Rect2(Vector2(sx, start_y), Vector2(SLOT_SIZE, SLOT_SIZE))

		var bg: Color = skill["color"]
		if i != selected:
			bg = bg.darkened(0.55)

		draw_rect(rect, Color(0.08, 0.08, 0.08))
		draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4)), bg)

		var border_color := Color.WHITE if i == selected else Color(0.35, 0.35, 0.35)
		draw_rect(rect, border_color, false, 2.0 if i == selected else 1.0)

		# Número da tecla
		draw_string(font, Vector2(sx + 4, start_y + 12), skill["key"],
				HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, Color.WHITE)

		# Nome abaixo do slot
		draw_string(font, Vector2(sx, start_y + SLOT_SIZE + 13), skill["name"],
				HORIZONTAL_ALIGNMENT_CENTER, SLOT_SIZE, FONT_SIZE - 1, Color.WHITE)
