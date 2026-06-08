extends Node2D

# ---------------------------------------------------------------------------
# Configuração
# ---------------------------------------------------------------------------
@export var rise_speed: float = 80.0
@export var duration:   float = 0.9
@export var font_size:  int   = 18
@export var color:      Color = Color(1.0, 0.9, 0.0)

# ---------------------------------------------------------------------------
# Estado interno
# ---------------------------------------------------------------------------
var _elapsed: float = 0.0
var _label:   Label
var _shadow:  Label

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	_shadow                      = Label.new()
	_shadow.add_theme_font_size_override("font_size", font_size)
	_shadow.add_theme_color_override("font_color", Color(0, 0, 0, 0.8))
	_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_shadow.position             = Vector2(2, 2)
	add_child(_shadow)

	_label                       = Label.new()
	_label.add_theme_font_size_override("font_size", font_size)
	_label.add_theme_color_override("font_color", color)
	_label.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_label)

func _process(delta: float) -> void:
	_elapsed   += delta
	position.y -= rise_speed * delta
	modulate.a  = 1.0 - (_elapsed / duration)
	if _elapsed >= duration:
		queue_free()

# ---------------------------------------------------------------------------
# Interface pública
# ---------------------------------------------------------------------------
func setup(amount: int, custom_color: Color = Color(-1, -1, -1)) -> void:
	if not _label:
		return
	_label.text  = "-%d" % amount
	_shadow.text = "-%d" % amount
	if custom_color.r >= 0:
		_label.add_theme_color_override("font_color", custom_color)
