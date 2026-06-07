extends Panel

# ---------------------------------------------------------------------------
# Sinais
# ---------------------------------------------------------------------------
signal dialogue_started()
signal dialogue_advanced(index: int)
signal dialogue_finished()

# ---------------------------------------------------------------------------
# Nós filhos
# ---------------------------------------------------------------------------
@onready var _portrait: TextureRect  = $Portrait
@onready var _text:     RichTextLabel = $Text
@onready var _speaker:  Label        = $Name

# ---------------------------------------------------------------------------
# Estado interno
# ---------------------------------------------------------------------------
var dialogo_ativo: bool = false  # público — NPC_script lê esta propriedade
var _index:        int  = 0

var _lines: Array[Dictionary] = [
	{ "nome": "Monge",     "texto": "Memento Mori.",                  "retrato": "res://portraits/perfil_monge.png"   },
	{ "nome": "Peregrino", "texto": "Ad aeternitatem.",               "retrato": "res://portraits/player_dialogo.png" },
	{ "nome": "Monge",     "texto": "Bem-vindo ao Vallis Virtutum.", "retrato": "res://portraits/perfil_monge.png"   },
	{ "nome": "Peregrino", "texto": "Obrigado!",                      "retrato": "res://portraits/player_dialogo.png" },
]

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if not dialogo_ativo:
		return
	if event.is_action_pressed("ui_accept"):
		_advance()

# ---------------------------------------------------------------------------
# Interface pública
# ---------------------------------------------------------------------------
func iniciar_dialogo() -> void:
	_index        = 0
	dialogo_ativo = true
	show()
	_show_current_line()
	emit_signal("dialogue_started")

# ---------------------------------------------------------------------------
# Internos
# ---------------------------------------------------------------------------
func _show_current_line() -> void:
	var line := _lines[_index]
	_speaker.text     = line["nome"]
	_text.text        = line["texto"]
	_portrait.texture = load(line["retrato"])

func _advance() -> void:
	_index += 1
	emit_signal("dialogue_advanced", _index)

	if _index >= _lines.size():
		_finish()
		return

	_show_current_line()

func _finish() -> void:
	dialogo_ativo = false
	_index        = 0
	hide()
	emit_signal("dialogue_finished")
