extends CharacterBody2D

# ---------------------------------------------------------------------------
# Sinais
# ---------------------------------------------------------------------------
signal health_changed(new_value: int, max_value: int)
signal died()

# ---------------------------------------------------------------------------
# Exportações / configuração
# ---------------------------------------------------------------------------
@export var max_health:            int   = 50
@export var move_speed:            float = 60.0
@export var attack_damage:         int   = 10
@export var attack_cooldown:       float = 1.2
@export var patrol_radius:         float = 80.0
@export var attack_range:          float = 40.0  # distância para atacar
@export var floating_number_scene: PackedScene

# ---------------------------------------------------------------------------
# Estado da máquina
# ---------------------------------------------------------------------------
enum State { PATROL, CHASE, ATTACK, DEAD }

# ---------------------------------------------------------------------------
# Nós filhos
# ---------------------------------------------------------------------------
@onready var _anim:   AnimatedSprite2D = $AnimatedSprite2D
@onready var _agent:  NavigationAgent2D = $NavigationAgent
@onready var _detection_area: Area2D   = $DetectionArea

# ---------------------------------------------------------------------------
# Estado interno
# ---------------------------------------------------------------------------
var _health:         int
var _state:          State   = State.PATROL
var _player:         Node2D  = null
var _origin:         Vector2
var _attack_timer:   float   = 0.0
var _patrol_timer:   float   = 0.0
var _last_direction: String  = "down"

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	_health = max_health
	_origin = global_position
	add_to_group("enemy")
	# Aguarda um frame para o NavigationAgent estar pronto
	await get_tree().process_frame
	_pick_patrol_target()

func _physics_process(delta: float) -> void:
	match _state:
		State.PATROL: _tick_patrol(delta)
		State.CHASE:  _tick_chase(delta)
		State.ATTACK: _tick_attack(delta)
		State.DEAD:   pass

# ---------------------------------------------------------------------------
# Estados
# ---------------------------------------------------------------------------
func _tick_patrol(delta: float) -> void:
	_patrol_timer -= delta

	if _agent.is_navigation_finished() or _patrol_timer <= 0.0:
		_pick_patrol_target()
		return

	var next := _agent.get_next_path_position()
	var dir  := (next - global_position).normalized()
	velocity  = dir * move_speed * 0.5
	move_and_slide()
	_play_walk_anim(velocity)

func _tick_chase(delta: float) -> void:
	if not is_instance_valid(_player):
		_state = State.PATROL
		return

	var dist := global_position.distance_to(_player.global_position)

	if dist <= attack_range:
		_state   = State.ATTACK
		velocity = Vector2.ZERO
		return

	# Atualiza destino do agente para o player
	_agent.target_position = _player.global_position

	var next := _agent.get_next_path_position()
	var dir  := (next - global_position).normalized()
	velocity  = dir * move_speed
	move_and_slide()
	_play_walk_anim(velocity)

func _tick_attack(delta: float) -> void:
	if not is_instance_valid(_player):
		_state = State.PATROL
		return

	var dist := global_position.distance_to(_player.global_position)
	velocity  = Vector2.ZERO

	# Player fugiu — volta a perseguir
	if dist > attack_range * 2.0:
		_state = State.CHASE
		return

	_attack_timer -= delta
	if _attack_timer <= 0.0:
		_attack_timer = attack_cooldown
		_play_attack_anim(_player.global_position - global_position)
		if _player.has_method("take_damage"):
			_player.take_damage(attack_damage)

# ---------------------------------------------------------------------------
# Patrulha
# ---------------------------------------------------------------------------
func _pick_patrol_target() -> void:
	var angle  := randf() * TAU
	var radius := randf() * patrol_radius
	_agent.target_position = _origin + Vector2(cos(angle), sin(angle)) * radius
	_patrol_timer          = randf_range(2.0, 5.0)

# ---------------------------------------------------------------------------
# Animações
# ---------------------------------------------------------------------------
func _play_walk_anim(vel: Vector2) -> void:
	if vel.length() < 1.0:
		return
	var new_dir: String
	if abs(vel.x) > abs(vel.y):
		new_dir = "right" if vel.x > 0 else "left"
	else:
		new_dir = "down" if vel.y > 0 else "up"
	if new_dir != _last_direction:
		_last_direction = new_dir
		_play("wolf_" + _last_direction)

func _play_attack_anim(dir: Vector2) -> void:
	_play("wolf_attack_right" if dir.x >= 0 else "wolf_attack_left")

func _play(anim_name: String) -> void:
	if _anim.animation != anim_name or not _anim.is_playing():
		_anim.play(anim_name)

# ---------------------------------------------------------------------------
# Detecção do player
# ---------------------------------------------------------------------------
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player = body
		_state  = State.CHASE
		_agent.target_position = _player.global_position

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		_state  = State.PATROL
		_pick_patrol_target()

# ---------------------------------------------------------------------------
# Interface pública
# ---------------------------------------------------------------------------
func take_damage(amount: int) -> void:
	if _state == State.DEAD:
		return
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
		return
	var popup: Node2D = floating_number_scene.instantiate()
	popup.position    = Vector2(randf_range(-10, 10), -40)
	add_child(popup)
	popup.setup(amount)

func _on_death() -> void:
	_state   = State.DEAD
	velocity = Vector2.ZERO
	set_physics_process(false)
	_anim.get_sprite_frames().set_animation_loop("wolf_dead", false)
	_anim.play("wolf_dead")
	emit_signal("died")
	await _anim.animation_finished
	queue_free()
