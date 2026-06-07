extends CharacterBody2D

# ---------------------------------------------------------------------------
# Sinais
# ---------------------------------------------------------------------------
signal health_changed(new_value: int, max_value: int)
signal died()

# ---------------------------------------------------------------------------
# Exportações / configuração
# ---------------------------------------------------------------------------
@export var max_health: int = 50
@export var floating_number_scene: PackedScene

# ---------------------------------------------------------------------------
# Estado interno
# ---------------------------------------------------------------------------
var _health: int

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	_health = max_health
	add_to_group("enemy")

# ---------------------------------------------------------------------------
# Interface pública
# ---------------------------------------------------------------------------
func take_damage(amount: int) -> void:
	_health = clampi(_health - amount, 0, max_health)
	emit_signal("health_changed", _health, max_health)
	_spawn_floating_number(amount)

	if _health == 0:
		_on_death()

# ---------------------------------------------------------------------------
# Internos
# ---------------------------------------------------------------------------
func _spawn_floating_number(amount: int) -> void:
	if not floating_number_scene:
		push_warning("[NPC] floating_number_scene não atribuída no Inspetor")
		return

	var popup: Node2D = floating_number_scene.instantiate()

	# Posiciona ANTES de adicionar na árvore — evita frame em (0,0)
	popup.position = Vector2(randf_range(-10, 10), -40)

	add_child(popup)
	print("NPC global_pos: ", global_position, " | popup pos: ", popup.position)
	popup.setup(amount)

func _on_death() -> void:
	emit_signal("died")
	queue_free()
