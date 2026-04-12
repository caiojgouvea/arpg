extends Node2D

const PANEL_W  := 760.0
const PANEL_H  := 520.0
const NODE_R   := 16.0
const MASTER_R := 23.0
const FONT_SIZE := 9

# Corner positions relative to panel top-left
const CORNER_INSTINCT := Vector2(670, 455)
const CORNER_FURY     := Vector2(90,  455)
const CORNER_ARCANE   := Vector2(380, 45)

const CORNER_COLORS := {
	"instinct": Color(0.2,  0.85, 0.2),
	"fury":     Color(0.95, 0.2,  0.2),
	"arcane":   Color(0.65, 0.2,  0.95),
}

# Functional nodes — only Instinto corner for now
const NODES := {
	# Layer 1 — Identidade
	"i_l1_a": {"label": "Pulmão de Ferro", "desc": "+20 Fôlego máximo",    "cost": 1, "requires": [],                      "effect": {"folego_bonus": 20.0},            "pos": Vector2(598, 420), "corner": "instinct"},
	"i_l1_b": {"label": "Mão Firme",       "desc": "+10 Dano Físico",      "cost": 1, "requires": [],                      "effect": {"phys_dmg": 10},                  "pos": Vector2(636, 366), "corner": "instinct"},
	"i_l1_c": {"label": "Reflexo",         "desc": "+10% Atk Speed",       "cost": 1, "requires": [],                      "effect": {"atk_speed": 0.10},               "pos": Vector2(568, 355), "corner": "instinct"},
	# Layer 2 — Especialização
	"i_l2_a": {"label": "Recuperação",     "desc": "Hit: +15 Fôlego",      "cost": 1, "requires": ["i_l1_a"],              "effect": {"folego_on_hit": 15.0},           "pos": Vector2(522, 408), "corner": "instinct"},
	"i_l2_b": {"label": "Flecha de Chama", "desc": "+25% fire no auto",    "cost": 1, "requires": ["i_l1_b"],              "effect": {"fire_chance": 0.25},             "pos": Vector2(558, 325), "corner": "instinct"},
	"i_l2_c": {"label": "Alcance",         "desc": "+200 range",           "cost": 1, "requires": ["i_l1_b", "i_l1_c"],   "effect": {"arrow_range": 200.0},            "pos": Vector2(502, 292), "corner": "instinct"},
	"i_l2_d": {"label": "Precisão",        "desc": "+3% crítico",          "cost": 1, "requires": ["i_l1_c"],              "effect": {"crit": 0.03},                    "pos": Vector2(554, 265), "corner": "instinct"},
	# Layer 3 — Limiar
	"i_l3_a": {"label": "Força do Arco",   "desc": "+25 Dano Físico",      "cost": 2, "requires": ["i_l2_a", "i_l2_b"],   "effect": {"phys_dmg": 25},                  "pos": Vector2(448, 372), "corner": "instinct"},
	"i_l3_b": {"label": "Artilheiro",      "desc": "+5% crit  +150 range", "cost": 2, "requires": ["i_l2_c", "i_l2_d"],   "effect": {"crit": 0.05, "arrow_range": 150.0}, "pos": Vector2(458, 258), "corner": "instinct"},
	# Master Node
	"i_master": {"label": "Perfuracao",    "desc": "Flechas atravessam\n+1 inimigo", "cost": 3, "requires": ["i_l3_a", "i_l3_b"], "effect": {"arrow_pierce": 1}, "pos": Vector2(382, 316), "corner": "instinct", "master": true},
}

# Visual-only placeholder nodes
const PLACEHOLDERS := [
	{"pos": Vector2(148, 415), "corner": "fury"},
	{"pos": Vector2(108, 368), "corner": "fury"},
	{"pos": Vector2(320, 92),  "corner": "arcane"},
	{"pos": Vector2(440, 92),  "corner": "arcane"},
	{"pos": Vector2(300, 255), "corner": "arcane"},
	{"pos": Vector2(370, 210), "corner": "fury"},
]

var _open    := false
var _player  : Node = null
var _unlocked := {}
var _node_rects := {}
var _hovered := ""


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	if not _open:
		return
	var mouse := get_viewport().get_mouse_position()
	var new_hover := ""
	for id in _node_rects:
		if _node_rects[id].has_point(mouse):
			new_hover = id
			break
	if new_hover != _hovered:
		_hovered = new_hover
		queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_Y:
			_open = not _open
			get_tree().paused = _open
			queue_redraw()
			return

	if _open and event is InputEventMouseButton \
			and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for id in _node_rects:
			if _node_rects[id].has_point(event.position):
				_try_unlock(id)
				return


func _try_unlock(id: String) -> void:
	if _unlocked.get(id, false):
		return
	var node: Dictionary = NODES[id]
	if _player == null or _player.talent_points < node["cost"]:
		return
	for req in node["requires"]:
		if not _unlocked.get(req, false):
			return
	_player.talent_points -= node["cost"]
	_unlocked[id] = true
	_apply_effect(node["effect"])
	queue_redraw()


func _apply_effect(effect: Dictionary) -> void:
	for key in effect:
		match key:
			"folego_bonus":  _player.talent_folego_bonus  += effect[key]
			"phys_dmg":      _player.talent_phys_dmg      += effect[key]
			"atk_speed":     _player.talent_atk_speed     += effect[key]
			"crit":          _player.talent_crit          += effect[key]
			"folego_on_hit": _player.talent_folego_on_hit += effect[key]
			"arrow_range":   _player.talent_arrow_range   += effect[key]
			"fire_chance":   _player.talent_fire_chance   += effect[key]
			"arrow_pierce":  _player.arrow_pierce         += effect[key]


func _draw() -> void:
	if not _open or _player == null:
		return

	var font := ThemeDB.fallback_font
	var vp   := get_viewport_rect().size
	var ox   := (vp.x - PANEL_W) / 2.0
	var oy   := (vp.y - PANEL_H) / 2.0

	# Background
	draw_rect(Rect2(ox, oy, PANEL_W, PANEL_H), Color(0.06, 0.06, 0.1, 0.97))
	draw_rect(Rect2(ox, oy, PANEL_W, PANEL_H), Color(0.4, 0.4, 0.5), false, 1.5)

	# Header
	draw_string(font, Vector2(ox, oy + 20.0), "ARVORE DE TALENTOS",
			HORIZONTAL_ALIGNMENT_CENTER, PANEL_W, 14, Color.WHITE)
	var pts_color := Color(0.6, 0.4, 0.9) if _player.talent_points > 0 else Color(0.4, 0.4, 0.4)
	draw_string(font, Vector2(ox, oy + 36.0), "Pontos: %d" % _player.talent_points,
			HORIZONTAL_ALIGNMENT_CENTER, PANEL_W, 11, pts_color)

	# Triangle outline
	var ci := Vector2(ox, oy) + CORNER_INSTINCT
	var cf := Vector2(ox, oy) + CORNER_FURY
	var ca := Vector2(ox, oy) + CORNER_ARCANE
	var tri_color := Color(0.22, 0.22, 0.28)
	draw_line(ci, cf, tri_color, 1.0)
	draw_line(cf, ca, tri_color, 1.0)
	draw_line(ca, ci, tri_color, 1.0)

	# Corner labels
	draw_string(font, ci + Vector2(-34, 14), "INSTINTO", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, CORNER_COLORS["instinct"])
	draw_string(font, cf + Vector2(-12, 14), "FURIA",    HORIZONTAL_ALIGNMENT_LEFT, -1, 9, CORNER_COLORS["fury"])
	draw_string(font, ca + Vector2(-18, -6), "ARCANO",   HORIZONTAL_ALIGNMENT_LEFT, -1, 9, CORNER_COLORS["arcane"])

	# Connection lines (drawn before nodes)
	for id in NODES:
		var node: Dictionary = NODES[id]
		var npos: Vector2 = Vector2(ox, oy) + (node["pos"] as Vector2)
		for req in node["requires"]:
			var rpos: Vector2 = Vector2(ox, oy) + ((NODES[req] as Dictionary)["pos"] as Vector2)
			var lit: bool = _unlocked.get(id, false) and _unlocked.get(req, false)
			draw_line(rpos, npos, Color(0.3, 0.65, 0.3, 0.75) if lit else Color(0.22, 0.22, 0.28, 0.8), 1.5)

	# Placeholder nodes
	for ph in PLACEHOLDERS:
		var ppos: Vector2 = Vector2(ox, oy) + ((ph as Dictionary)["pos"] as Vector2)
		var pcol: Color = CORNER_COLORS[(ph as Dictionary)["corner"]]
		draw_circle(ppos, NODE_R, Color(0.1, 0.1, 0.14))
		draw_arc(ppos, NODE_R, 0, TAU, 32, pcol.darkened(0.6), 1.0)
		draw_string(font, ppos + Vector2(-4, 4), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, pcol.darkened(0.4))

	# Functional nodes
	_node_rects.clear()
	for id in NODES:
		_draw_node(font, ox, oy, id)

	# Tooltip for hovered node
	if _hovered != "":
		_draw_tooltip(font, ox, oy)

	# Footer
	draw_string(font, Vector2(ox, oy + PANEL_H - 8.0), "[Y] Fechar",
			HORIZONTAL_ALIGNMENT_CENTER, PANEL_W, 10, Color(0.32, 0.32, 0.38))


func _draw_node(font: Font, ox: float, oy: float, id: String) -> void:
	var node: Dictionary   = NODES[id]
	var npos: Vector2      = Vector2(ox, oy) + (node["pos"] as Vector2)
	var is_master: bool    = node.get("master", false)
	var r                  := MASTER_R if is_master else NODE_R
	var unlocked: bool     = _unlocked.get(id, false)
	var can_unlock: bool   = _can_unlock(id)
	var hovered: bool      = _hovered == id
	var corner: String     = node["corner"]
	var base_color: Color  = CORNER_COLORS[corner]

	var fill: Color
	if unlocked:        fill = base_color.darkened(0.25)
	elif can_unlock:    fill = Color(0.1, 0.16, 0.1)
	else:               fill = Color(0.08, 0.08, 0.11)

	var border: Color
	if unlocked:        border = base_color
	elif can_unlock:    border = base_color.darkened(0.35)
	elif hovered:       border = Color(0.5, 0.5, 0.55)
	else:               border = Color(0.2, 0.2, 0.25)

	draw_circle(npos, r, fill)
	if is_master:
		draw_arc(npos, r + 4, 0, TAU, 64, border.lightened(0.2) if unlocked else Color(0.3, 0.3, 0.35), 1.0)
	draw_arc(npos, r, 0, TAU, 48, border, 1.5)

	if unlocked:
		draw_string(font, npos + Vector2(-5, 4), "V", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
	elif not unlocked and is_master:
		draw_string(font, npos + Vector2(-4, 4), "*", HORIZONTAL_ALIGNMENT_LEFT, -1, 12,
				base_color if can_unlock else Color(0.35, 0.35, 0.4))

	# Cost badge (top-right of node)
	if not unlocked:
		var bp: Vector2 = npos + Vector2(r - 3, -r + 3)
		draw_circle(bp, 7.0, Color(0.08, 0.08, 0.12))
		draw_arc(bp, 7.0, 0, TAU, 16, Color(0.55, 0.45, 0.0), 1.0)
		draw_string(font, bp + Vector2(-3, 4), str(node["cost"]),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.95, 0.8, 0.1))

	# Label below node
	var lc := base_color if unlocked else (Color(0.75, 0.75, 0.8) if can_unlock else Color(0.38, 0.38, 0.42))
	draw_string(font, Vector2(npos.x - 44, npos.y + r + 11), node["label"],
			HORIZONTAL_ALIGNMENT_CENTER, 88.0, 8, lc)

	_node_rects[id] = Rect2(npos - Vector2(r, r), Vector2(r * 2, r * 2))


func _draw_tooltip(font: Font, ox: float, oy: float) -> void:
	var node: Dictionary = NODES[_hovered]
	var npos: Vector2 = Vector2(ox, oy) + (node["pos"] as Vector2)
	var corner: String = node["corner"]
	var base_color: Color = CORNER_COLORS[corner]
	var unlocked: bool = _unlocked.get(_hovered, false)
	var can_unlock: bool = _can_unlock(_hovered)

	var lines := [node["label"], node["desc"],
		"Custo: %d ponto%s" % [node["cost"], "s" if node["cost"] > 1 else ""]]
	if unlocked:
		lines.append("[ Desbloqueado ]")
	elif not can_unlock:
		if _player.talent_points < node["cost"]:
			lines.append("Sem pontos suficientes")
		else:
			lines.append("Requer nos anteriores")

	var TW := 170.0
	var TH := float(lines.size()) * 14.0 + 10.0
	var tx := clampf(npos.x - TW / 2.0, ox + 4.0, ox + PANEL_W - TW - 4.0)
	var ty := npos.y - TH - 10.0
	if ty < oy + 50.0:
		ty = npos.y + 30.0

	draw_rect(Rect2(tx, ty, TW, TH), Color(0.05, 0.05, 0.1, 0.95))
	draw_rect(Rect2(tx, ty, TW, TH), base_color.darkened(0.3), false, 1.0)
	var cy := ty + 12.0
	for i in lines.size():
		var lc := base_color if i == 0 else (Color(0.85, 0.85, 0.9) if i == 1 else Color(0.55, 0.55, 0.6))
		draw_string(font, Vector2(tx + 6.0, cy), lines[i],
				HORIZONTAL_ALIGNMENT_LEFT, TW - 10.0, 9, lc)
		cy += 14.0


func _can_unlock(id: String) -> bool:
	if _unlocked.get(id, false):
		return false
	var node: Dictionary = NODES[id]
	if _player == null or _player.talent_points < node["cost"]:
		return false
	for req in node["requires"]:
		if not _unlocked.get(req, false):
			return false
	return true
