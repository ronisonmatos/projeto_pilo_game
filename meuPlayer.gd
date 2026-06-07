extends CharacterBody2D

# ---------------------------------------------------------------------------
# Sinais
# ---------------------------------------------------------------------------
signal health_changed(new_value: int, max_value: int)
signal faith_changed(new_value: int, max_value: int)
signal player_died()

# ---------------------------------------------------------------------------
# Exportações / configuração
# ---------------------------------------------------------------------------
@export var move_speed:       float = 200.0
@export var max_health:       int   = 100
@export var max_faith:        int   = 100
@export var attack_damage:    int   = 5
@export var faith_cost_attack: int  = 1
@export var floating_number_scene: PackedScene

# ---------------------------------------------------------------------------
# Nós filhos
# ---------------------------------------------------------------------------
@onready var _anim:         AnimatedSprite2D       = $AnimatedSprite2D
@onready var _hitbox:       Area2D                 = $Hitbox
@onready var _attack_sound: AudioStreamPlayer2D    = $AttackSound

# ---------------------------------------------------------------------------
# Estado interno
# ---------------------------------------------------------------------------
const ATTACK_HIT_FRAMES: Array[int] = [2, 6, 8]

var _last_direction: String = "down"
var _is_attacking:   bool   = false
var _health:         int
var _faith:          int

# ---------------------------------------------------------------------------
# Ciclo de vida
# ---------------------------------------------------------------------------
func _ready() -> void:
	_health = max_health
	_faith  = max_faith
	await get_tree().process_frame
	emit_signal("health_changed", _health, max_health)
	emit_signal("faith_changed",  _faith,  max_faith)

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
	var dir := Vector2.ZERO
	dir.x = Input.get_axis("ui_left", "ui_right")
	dir.y = Input.get_axis("ui_up",   "ui_down")
	return dir

# ---------------------------------------------------------------------------
# Animações
# ---------------------------------------------------------------------------
func _play_walk_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		_last_direction = "right" if direction.x > 0 else "left"
	else:
		_last_direction = "down" if direction.y > 0 else "up"
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
	spend_faith(faith_cost_attack)
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
# Dano / status
# ---------------------------------------------------------------------------
func take_damage(amount: int) -> void:
	_health = clampi(_health - amount, 0, max_health)
	emit_signal("health_changed", _health, max_health)
	_spawn_floating_number(amount)
	if _health == 0:
		emit_signal("player_died")

func _spawn_floating_number(amount: int) -> void:
	if not floating_number_scene:
		return
	var popup: Node2D = floating_number_scene.instantiate()
	popup.position    = Vector2(randf_range(-10, 10), -40)
	add_child(popup)
	popup.setup(amount,  Color(0.631, 0.0, 0.056, 1.0))

func spend_faith(amount: int) -> void:
	_faith = clampi(_faith - amount, 0, max_faith)
	emit_signal("faith_changed", _faith, max_faith)
