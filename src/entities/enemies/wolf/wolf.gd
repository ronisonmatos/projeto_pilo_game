extends EnemyBase

# ---------------------------------------------------------------------------
# Sinais
# ---------------------------------------------------------------------------
signal health_changed(new_value: int, max_value: int)
signal died()

# ---------------------------------------------------------------------------
# Exportações / configuração
# ---------------------------------------------------------------------------
@export var max_health:      int   = 50
@export var move_speed:      float = 60.0
@export var attack_damage:   int   = 10
@export var attack_cooldown: float = 1.2
@export var patrol_radius:   float = 80.0
@export var attack_range:    float = 40.0

# ---------------------------------------------------------------------------
# Máquina de estados
# ---------------------------------------------------------------------------
enum State { PATROL, CHASE, ATTACK, DEAD }

# ---------------------------------------------------------------------------
# Nós filhos
# ---------------------------------------------------------------------------
@onready var _anim:           AnimatedSprite2D  = $AnimatedSprite2D
@onready var _agent:          NavigationAgent2D = $NavigationAgent
@onready var _detection_area: Area2D            = $DetectionArea

# ---------------------------------------------------------------------------
# Estado interno
# ---------------------------------------------------------------------------
var _health_component: HealthComponent
var _state:            State  = State.PATROL
var _player:           Node2D = null
var _origin:           Vector2
var _attack_timer:     float  = 0.0
var _patrol_timer:     float  = 0.0
var _last_direction:   String = "down"

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	_origin = global_position
	add_to_group("enemy")
	_setup_health_component()
	# Aguarda um frame para o NavigationAgent estar pronto
	await get_tree().process_frame
	_pick_patrol_target()

func _setup_health_component() -> void:
	_health_component            = HealthComponent.new()
	_health_component.max_health = max_health
	add_child(_health_component)
	_health_component.health_changed.connect(func(v: int, m: int): health_changed.emit(v, m))
	_health_component.damage_taken.connect(func(amount: int): _spawn_floating_number(amount))
	_health_component.died.connect(_on_death)

# ---------------------------------------------------------------------------
# Loop de física
# ---------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	match _state:
		State.PATROL: _tick_patrol(delta)
		State.CHASE:  _tick_chase()
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
	if get_real_velocity().length() > 5.0:
		_play_walk_anim(get_real_velocity())

func _tick_chase() -> void:
	if not is_instance_valid(_player):
		_state = State.PATROL
		return
	var dist := global_position.distance_to(_player.global_position)
	if dist <= attack_range:
		_state   = State.ATTACK
		velocity = Vector2.ZERO
		_play_attack_anim(_player.global_position - global_position)
		return
	var to_player := (_player.global_position - global_position).normalized()
	_agent.target_position = _player.global_position - to_player * attack_range
	var next := _agent.get_next_path_position()
	var dir  := (next - global_position).normalized()
	velocity  = dir * move_speed
	move_and_slide()
	if get_real_velocity().length() > 5.0:
		_play_walk_anim(get_real_velocity())

func _tick_attack(delta: float) -> void:
	if not is_instance_valid(_player):
		_state = State.PATROL
		return
	var dist := global_position.distance_to(_player.global_position)
	velocity  = Vector2.ZERO
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
	if vel.length() < 5.0:
		return
	var new_dir: String
	if abs(vel.x) > abs(vel.y):
		new_dir = "right" if vel.x > 0 else "left"
	else:
		new_dir = "down" if vel.y > 0 else "up"
	if new_dir != _last_direction:
		_last_direction = new_dir
		_play_anim("wolf_" + _last_direction)

func _play_attack_anim(dir: Vector2) -> void:
	_play_anim("wolf_attack_right" if dir.x >= 0 else "wolf_attack_left")

func _play_anim(anim_name: String) -> void:
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
	_health_component.take_damage(amount)

# ---------------------------------------------------------------------------
# Morte do player — para de perseguir/atacar
# ---------------------------------------------------------------------------
func _on_player_died() -> void:
	if _state == State.DEAD:
		return
	_player = null
	_state  = State.PATROL
	velocity = Vector2.ZERO
	_pick_patrol_target()

# ---------------------------------------------------------------------------
# Morte
# ---------------------------------------------------------------------------
func _on_death() -> void:
	_state   = State.DEAD
	velocity = Vector2.ZERO
	set_physics_process(false)
	_anim.get_sprite_frames().set_animation_loop("wolf_dead", false)
	_anim.play("wolf_dead")
	died.emit()
	await _anim.animation_finished
	queue_free()
