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
@onready var _portrait: TextureRect   = $Portrait
@onready var _text:     RichTextLabel = $Text
@onready var _speaker:  Label         = $Name

# ---------------------------------------------------------------------------
# Estado interno
# ---------------------------------------------------------------------------
var _is_active:   bool  = false
var _can_advance: bool  = false  # guard de um frame — impede avançar no mesmo frame em que o diálogo abriu
var _index:       int   = 0
var _lines:       Array = []

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	hide()
	EventBus.dialogue_requested.connect(start_dialogue)

# ---------------------------------------------------------------------------
# Input — consume o evento para que outros nós não o recebam durante diálogo
# ---------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if not _is_active or not _can_advance:
		return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_advance()

# ---------------------------------------------------------------------------
# Interface pública
# ---------------------------------------------------------------------------
func start_dialogue(dialogue_id: String) -> void:
	_lines = DialogueDatabase.get_dialogue(dialogue_id)
	if _lines.is_empty():
		return
	_index                   = 0
	_is_active               = true
	_can_advance             = false  # bloqueia avanço até o próximo frame
	EventBus.dialogue_active = true
	show()
	_show_current_line()
	dialogue_started.emit()
	await get_tree().process_frame
	_can_advance = true

# ---------------------------------------------------------------------------
# Internos
# ---------------------------------------------------------------------------
func _show_current_line() -> void:
	var line: Dictionary = _lines[_index]
	_speaker.text     = line["speaker"]
	_text.text        = line["text"]
	_portrait.texture = load(line["portrait"])

func _advance() -> void:
	_index += 1
	dialogue_advanced.emit(_index)
	if _index >= _lines.size():
		_finish()
		return
	_show_current_line()

func _finish() -> void:
	_is_active               = false
	_index                   = 0
	EventBus.dialogue_active = false
	hide()
	dialogue_finished.emit()
	EventBus.dialogue_finished.emit()
