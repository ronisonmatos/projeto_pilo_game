class_name EnemyBase
extends CharacterBody2D

# Cena dos números flutuantes de dano — atribuída no inspetor de cada inimigo
@export var floating_number_scene: PackedScene

func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)

# Chamado automaticamente quando o player morre.
# Sobrescrever em cada inimigo concreto para parar o ataque.
func _on_player_died() -> void:
	pass

# Sobrescrito por cada inimigo concreto
func take_damage(amount: int) -> void:
	pass

# Utilitário compartilhado por todos os inimigos para exibir dano recebido
func _spawn_floating_number(amount: int, custom_color: Color = Color(-1, -1, -1)) -> void:
	if not floating_number_scene:
		return
	var popup: Node2D = floating_number_scene.instantiate()
	popup.position    = Vector2(randf_range(-10, 10), -40)
	add_child(popup)
	popup.setup(amount, custom_color)
