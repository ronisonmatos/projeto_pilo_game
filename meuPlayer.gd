extends CharacterBody2D

@export var speed = 200
@onready var anim = $AnimatedSprite2D
@onready var hitbox = $Hitbox

var last_direction := "down"
var atacando := false
var vida = 100
var fe = 100

func _physics_process(_delta):
	if Input.is_action_just_pressed("attack"):
		atacar()

	if atacando:
		move_and_slide()
		return

	_handle_movement()

func _handle_movement():
	var direction := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	velocity = direction.normalized() * speed
	move_and_slide()

	if direction != Vector2.ZERO:
		_play_walk_animation(direction)
	else:
		_play_idle_animation()

func _play_walk_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			last_direction = "right"
			anim.play("walk_right")
		else:
			last_direction = "left"
			anim.play("walk_left")
	else:
		if direction.y > 0:
			last_direction = "down"
			anim.play("walk_down")
		else:
			last_direction = "up"
			anim.play("walk_up")

func _play_idle_animation():
	anim.play("idle_" + last_direction)

func atacar():
	if atacando:
		return
	atacando = true
	anim.play("attack_" + last_direction)

func _on_animated_sprite_2d_animation_finished():
	if anim.animation.begins_with("attack_"):
		atacando = false
		hitbox.monitoring = false
		_play_idle_animation()
				
func _ready():
	# Aguarda o HUD estar pronto na árvore
	await get_tree().process_frame

	var hud = get_node_or_null("/root/Main/HUD")
	if hud:
		hud.atualizar_vida(vida)
		hud.atualizar_fe(fe)
	else:
		push_error("HUD não encontrado! Verifique o caminho /HUD")
		
#Remover esse teste da vida e da fé		
func _input(event):

	if event.is_action_pressed("ui_accept"):
		vida -= 10

		if vida < 0:
			vida = 0

		var hud = get_node("/root/Main/HUD")
		hud.atualizar_vida(vida)
		
	if event.is_action_pressed("attack"):
		fe -= 1

		if fe < 0:
			fe = 0

		var hud = get_node("/root/Main/HUD")
		hud.atualizar_fe(fe)


func _on_animated_sprite_2d_frame_changed():
	# Corrigido: begins_with em vez de == "attack"
	if not anim.animation.begins_with("attack_"):
		return

	if anim.frame in [2, 6, 8]:
		$AttackSound.play()
		hitbox.monitoring = true
	else:
		hitbox.monitoring = false

func _on_hitbox_body_entered(body):
	print("Encostou em:", body.name)
	if body.is_in_group("enemy"):
		body.receber_dano(10)
