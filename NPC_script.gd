extends CharacterBody2D

# ---------------------------------------------------------------------------
# Sinais
# ---------------------------------------------------------------------------
signal dialogue_requested()

# ---------------------------------------------------------------------------
# Exportações / configuração
# ---------------------------------------------------------------------------
## Dados do diálogo que este NPC deve exibir (configurável pelo inspetor)
@export var dialogue_id: String = ""

# ---------------------------------------------------------------------------
# Nós filhos
# ---------------------------------------------------------------------------
@onready var _interaction_icon: Node2D = $InteractionIcon

# ---------------------------------------------------------------------------
# Estado interno
# ---------------------------------------------------------------------------
var _player_nearby:       bool = false
var _dialogue_played:     bool = false
var _dialogue_box: Node        = null

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	_interaction_icon.visible = false
	_dialogue_box = get_node_or_null("/root/Main/CanvasLayer/DialogBox")
	if not _dialogue_box:
		push_error("[NPC] DialogBox não encontrado em /root/Main/CanvasLayer/DialogBox")

func _process(_delta: float) -> void:
	if _can_start_dialogue() and Input.is_action_just_pressed("ui_accept"):
		_start_dialogue()

# ---------------------------------------------------------------------------
# Lógica de diálogo
# ---------------------------------------------------------------------------
func _can_start_dialogue() -> bool:
	return (
		_player_nearby
		and not _dialogue_played
		and _dialogue_box != null
		and not _dialogue_box.dialogo_ativo
	)

func _start_dialogue() -> void:
	_dialogue_played = true
	_dialogue_box.iniciar_dialogo()
	emit_signal("dialogue_requested")

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
