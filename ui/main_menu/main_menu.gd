extends Node2D

const WORLD_SCENE = "res://world/world.tscn"

var _play_rect  := Rect2()
var _quit_rect  := Rect2()
var _hovered    := ""
var _time       := 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()
	var mouse := get_viewport().get_mouse_position()
	var new_hover := ""
	if _play_rect.has_point(mouse): new_hover = "play"
	elif _quit_rect.has_point(mouse): new_hover = "quit"
	if new_hover != _hovered:
		_hovered = new_hover


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _play_rect.has_point(event.position):
			get_tree().change_scene_to_file(WORLD_SCENE)
		elif _quit_rect.has_point(event.position):
			get_tree().quit()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var vp   := get_viewport_rect().size
	var cx   := vp.x / 2.0
	var cy   := vp.y / 2.0

	# Fundo
	draw_rect(Rect2(Vector2.ZERO, vp), Color(0.04, 0.03, 0.05))

	# Partículas de fundo (estrelas/faíscas atmosféricas)
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in 80:
		var px := rng.randf_range(0, vp.x)
		var py := rng.randf_range(0, vp.y)
		var pulse := sin(_time * rng.randf_range(0.5, 1.5) + rng.randf_range(0, TAU))
		var alpha := remap(pulse, -1.0, 1.0, 0.05, 0.35)
		var size  := rng.randf_range(1.0, 2.5)
		draw_circle(Vector2(px, py), size, Color(0.6, 0.4, 0.9, alpha))

	# Linha decorativa topo
	var line_alpha := 0.18 + sin(_time * 0.7) * 0.06
	draw_line(Vector2(cx - 220, cy - 110), Vector2(cx + 220, cy - 110),
			Color(0.5, 0.2, 0.8, line_alpha), 1.0)

	# Título — HERETIC
	var title_y   := cy - 60.0
	var title_sz  := 52
	var glow_alpha := 0.08 + sin(_time * 1.2) * 0.04

	# Glow atrás do título
	for off in [Vector2(-2,0), Vector2(2,0), Vector2(0,-2), Vector2(0,2)]:
		draw_string(font, Vector2(cx - 145, title_y) + off * 2.0, "HERETIC",
				HORIZONTAL_ALIGNMENT_LEFT, -1, title_sz, Color(0.6, 0.2, 0.9, glow_alpha * 3))
	draw_string(font, Vector2(cx - 145, title_y), "HERETIC",
			HORIZONTAL_ALIGNMENT_LEFT, -1, title_sz, Color(0.88, 0.82, 0.95))

	# Subtítulo
	draw_string(font, Vector2(cx - 145, title_y + 24), "You were not invited.",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.45, 0.35, 0.55))

	# Linha decorativa abaixo do título
	draw_line(Vector2(cx - 220, cy - 18), Vector2(cx + 220, cy - 18),
			Color(0.5, 0.2, 0.8, line_alpha), 1.0)

	# Botão PLAY
	var bw := 180.0
	var bh := 36.0
	var play_x := cx - bw / 2.0
	var play_y := cy + 10.0
	_play_rect = Rect2(play_x, play_y, bw, bh)
	var play_hover := _hovered == "play"
	var play_fill  := Color(0.18, 0.1, 0.25) if play_hover else Color(0.1, 0.06, 0.15)
	var play_bord  := Color(0.65, 0.3, 0.9) if play_hover else Color(0.4, 0.2, 0.6)
	draw_rect(_play_rect, play_fill)
	draw_rect(_play_rect, play_bord, false, 1.5)
	draw_string(font, Vector2(play_x, play_y + bh - 10.0), "PLAY",
			HORIZONTAL_ALIGNMENT_CENTER, bw, 16,
			Color(0.9, 0.85, 1.0) if play_hover else Color(0.7, 0.65, 0.8))

	# Botão QUIT
	var quit_y := play_y + bh + 12.0
	_quit_rect = Rect2(play_x, quit_y, bw, bh)
	var quit_hover := _hovered == "quit"
	var quit_fill  := Color(0.15, 0.06, 0.06) if quit_hover else Color(0.08, 0.05, 0.05)
	var quit_bord  := Color(0.6, 0.2, 0.2) if quit_hover else Color(0.3, 0.15, 0.15)
	draw_rect(_quit_rect, quit_fill)
	draw_rect(_quit_rect, quit_bord, false, 1.5)
	draw_string(font, Vector2(play_x, quit_y + bh - 10.0), "QUIT",
			HORIZONTAL_ALIGNMENT_CENTER, bw, 16,
			Color(0.9, 0.7, 0.7) if quit_hover else Color(0.55, 0.4, 0.4))

	# Versão
	draw_string(font, Vector2(8, vp.y - 6), "v0.1 — early dev",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.25, 0.2, 0.3))
