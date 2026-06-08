extends CharacterBody2D

# ---------------------------------------------------------------------------
# Sinais
# ---------------------------------------------------------------------------
signal dialogue_requested(dialogue_id: String)

# ---------------------------------------------------------------------------
# Exportações / configuração
# ---------------------------------------------------------------------------
## ID do diálogo que este NPC inicia. Deve corresponder a uma chave em DialogueDatabase.
@export var dialogue_id: String = "monk_intro"

# ---------------------------------------------------------------------------
# Nós filhos
# ---------------------------------------------------------------------------
@onready var _interaction_icon: Node2D = $InteractionIcon

# ---------------------------------------------------------------------------
# Estado interno
# ---------------------------------------------------------------------------
var _player_nearby:   bool = false
var _dialogue_played: bool = false

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	_interaction_icon.visible = false
	# Reseta o estado quando um diálogo termina, permitindo nova conversa
	EventBus.dialogue_finished.connect(_on_dialogue_finished)

# ---------------------------------------------------------------------------
# Input — usa _unhandled_input para não conflitar com a caixa de diálogo
# ---------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if not _player_nearby or _dialogue_played or EventBus.dialogue_active:
		return
	if event.is_action_pressed("ui_accept"):
		_start_dialogue()

# ---------------------------------------------------------------------------
# Lógica de diálogo
# ---------------------------------------------------------------------------
func _start_dialogue() -> void:
	_dialogue_played = true
	EventBus.dialogue_requested.emit(dialogue_id)
	dialogue_requested.emit(dialogue_id)

# ---------------------------------------------------------------------------
# Sinais de área
# ---------------------------------------------------------------------------
func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_nearby            = true
	_interaction_icon.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_nearby            = false
	_dialogue_played          = false
	_interaction_icon.visible = false

# ---------------------------------------------------------------------------
# Callbacks do EventBus
# ---------------------------------------------------------------------------
func _on_dialogue_finished() -> void:
	# Permite que o NPC inicie diálogo novamente após o atual ser concluído
	if _player_nearby:
		_dialogue_played = false
