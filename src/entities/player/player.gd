extends CharacterBody2D

# ---------------------------------------------------------------------------
# Sinais — mantidos para compatibilidade com conexões diretas no inspetor
# ---------------------------------------------------------------------------
signal health_changed(new_value: int, max_value: int)
signal faith_changed(new_value: int, max_value: int)
signal player_died()

# ---------------------------------------------------------------------------
# Exportações / configuração
# ---------------------------------------------------------------------------
@export var move_speed:        float = 200.0
@export var max_health:        int   = 100
@export var max_faith:         int   = 100
@export var attack_damage:     int   = 5
@export var faith_cost_attack: int   = 1
@export var floating_number_scene: PackedScene

# ---------------------------------------------------------------------------
# Nós filhos
# ---------------------------------------------------------------------------
@onready var _anim:         AnimatedSprite2D    = $AnimatedSprite2D
@onready var _hitbox:       Area2D              = $Hitbox
@onready var _attack_sound: AudioStreamPlayer2D = $AttackSound

# ---------------------------------------------------------------------------
# Estado interno
# ---------------------------------------------------------------------------
const ATTACK_HIT_FRAMES: Array[int] = [2, 6, 8]

var _health_component: HealthComponent
var _faith_component:  FaithComponent
var _last_direction:   String = "down"
var _is_attacking:     bool   = false

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	add_to_group("player")
	_setup_health_component()
	_setup_faith_component()
	# Aguarda um frame para garantir que HUD já conectou seus sinais ao EventBus
	await get_tree().process_frame
	EventBus.player_health_changed.emit(max_health, max_health)
	EventBus.player_faith_changed.emit(max_faith, max_faith)

func _setup_health_component() -> void:
	_health_component            = HealthComponent.new()
	_health_component.max_health = max_health
	add_child(_health_component)
	_health_component.health_changed.connect(_on_health_changed)
	_health_component.damage_taken.connect(_spawn_floating_number)
	_health_component.died.connect(_on_died)

func _setup_faith_component() -> void:
	_faith_component           = FaithComponent.new()
	_faith_component.max_faith = max_faith
	add_child(_faith_component)
	_faith_component.faith_changed.connect(_on_faith_changed)

# ---------------------------------------------------------------------------
# Loop de física
# ---------------------------------------------------------------------------
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		_start_attack()
	if _is_attacking:
		move_and_slide()
		return
	_handle_movement()

# ---------------------------------------------------------------------------
# Movimento
# ---------------------------------------------------------------------------
func _handle_movement() -> void:
	var direction := _read_input_direction()
	velocity = direction.normalized() * move_speed
	move_and_slide()
	if direction != Vector2.ZERO:
		_play_walk_animation(direction)
	else:
		_play_idle_animation()

func _read_input_direction() -> Vector2:
	return Vector2(
		Input.get_axis("ui_left",  "ui_right"),
		Input.get_axis("ui_up",    "ui_down")
	)

func _direction_to_string(direction: Vector2) -> String:
	if abs(direction.x) > abs(direction.y):
		return "right" if direction.x > 0 else "left"
	return "down" if direction.y > 0 else "up"

# ---------------------------------------------------------------------------
# Animações
# ---------------------------------------------------------------------------
func _play_walk_animation(direction: Vector2) -> void:
	_last_direction = _direction_to_string(direction)
	_anim.play("walk_" + _last_direction)

func _play_idle_animation() -> void:
	_anim.play("idle_" + _last_direction)

# ---------------------------------------------------------------------------
# Ataque
# ---------------------------------------------------------------------------
func _start_attack() -> void:
	if _is_attacking:
		return
	_is_attacking = true
	_faith_component.spend(faith_cost_attack)
	_anim.play("attack_" + _last_direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if _anim.animation.begins_with("attack_"):
		_is_attacking      = false
		_hitbox.monitoring = false
		_play_idle_animation()

func _on_animated_sprite_2d_frame_changed() -> void:
	if not _anim.animation.begins_with("attack_"):
		return
	if _anim.frame in ATTACK_HIT_FRAMES:
		_attack_sound.play()
		_hitbox.monitoring = true
	else:
		_hitbox.monitoring = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(attack_damage)

# ---------------------------------------------------------------------------
# Dano / status — interface pública
# ---------------------------------------------------------------------------
func take_damage(amount: int) -> void:
	_health_component.take_damage(amount)

func _spawn_floating_number(amount: int) -> void:
	if not floating_number_scene:
		return
	var popup: Node2D = floating_number_scene.instantiate()
	popup.position    = Vector2(randf_range(-10, 10), -40)
	add_child(popup)
	popup.setup(amount, Color(0.631, 0.0, 0.056, 1.0))

# ---------------------------------------------------------------------------
# Callbacks dos componentes — propagam para sinais locais e EventBus
# ---------------------------------------------------------------------------
func _on_health_changed(new_val: int, max_val: int) -> void:
	health_changed.emit(new_val, max_val)
	EventBus.player_health_changed.emit(new_val, max_val)

func _on_faith_changed(new_val: int, max_val: int) -> void:
	faith_changed.emit(new_val, max_val)
	EventBus.player_faith_changed.emit(new_val, max_val)

func _on_died() -> void:
	player_died.emit()
	EventBus.player_died.emit()
