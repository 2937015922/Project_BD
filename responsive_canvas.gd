extends CanvasLayer
class_name ResponsiveCanvas

## Design reference resolution (16:9)
const DESIGN_W: float = 1920.0
const DESIGN_H: float = 1080.0
const BASE_FONT: int = 44
const MIN_FONT: int = 14

var _ui_scale: float = 1.0

func _ready() -> void:
	get_tree().root.size_changed.connect(_layout)
	_layout()

func _layout() -> void:
	var vs := get_viewport().get_visible_rect().size
	_ui_scale = minf(vs.x / DESIGN_W, vs.y / DESIGN_H)
	_ui_scale = maxf(_ui_scale, 0.3)
	var fs := maxi(int(BASE_FONT * _ui_scale), MIN_FONT)

	for child in get_children():
		if child is Control:
			_apply_layout(child, fs)

## ── Per‑control anchor + scaled‑margin rules ──────────────────────────────

func _apply_layout(ctrl: Control, fs: int) -> void:
	match ctrl.name:
		"ScoreLabel":
			_pin(ctrl, 0.0, 0.0, 0.0, 0.0)
			_set_offsets(ctrl, 20, 10, 100, 50)
			ctrl.add_theme_font_size_override("font_size", fs)

		"ScoreValue":
			_pin(ctrl, 0.0, 0.0, 0.0, 0.0)
			_set_offsets(ctrl, 110, 10, 180, 50)
			ctrl.add_theme_font_size_override("font_size", fs)

		"CountdownProgressBar":
			_pin(ctrl, 0.0, 0.0, 1.0, 0.0)
			_set_offsets(ctrl, 200, 10, -360, 60)

		"UndoButton":
			_pin(ctrl, 1.0, 0.0, 1.0, 0.0)
			_set_offsets(ctrl, -330, 10, -185, 60)
			ctrl.add_theme_font_size_override("font_size", fs)

		"RestartButton":
			_pin(ctrl, 1.0, 0.0, 1.0, 0.0)
			_set_offsets(ctrl, -165, 10, -15, 60)
			ctrl.add_theme_font_size_override("font_size", fs)

		_:  # unknown children — keep anchors, just scale offsets+font
			if not ctrl.has_meta("_base"):
				ctrl.set_meta("_base", {
					l = ctrl.offset_left, t = ctrl.offset_top,
					r = ctrl.offset_right, b = ctrl.offset_bottom })
			var b = ctrl.get_meta("_base")
			ctrl.offset_left   = b.l * _ui_scale
			ctrl.offset_top    = b.t * _ui_scale
			ctrl.offset_right  = b.r * _ui_scale
			ctrl.offset_bottom = b.b * _ui_scale
			if ctrl is Label or ctrl is Button:
				ctrl.add_theme_font_size_override("font_size", fs)

## ── Helpers ─────────────────────────────────────────────────────────────────

func _pin(ctrl: Control, la: float, ta: float, ra: float, ba: float) -> void:
	ctrl.anchor_left   = la
	ctrl.anchor_top    = ta
	ctrl.anchor_right  = ra
	ctrl.anchor_bottom = ba

func _set_offsets(ctrl: Control, l: float, t: float, r: float, b: float) -> void:
	ctrl.offset_left   = l * _ui_scale
	ctrl.offset_top    = t * _ui_scale
	ctrl.offset_right  = r * _ui_scale
	ctrl.offset_bottom = b * _ui_scale

## ── Public API ──────────────────────────────────────────────────────────────

func get_ui_scale() -> float:
	return _ui_scale

func get_viewport_size() -> Vector2:
	return get_viewport().get_visible_rect().size
