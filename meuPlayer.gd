extends CharacterBody2D

@export var speed = 200

@onready var anim = $AnimatedSprite2D

func _physics_process(delta):

	var direction = Vector2.ZERO

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

		if anim.animation != "walk_down":
			anim.play("walk_down")

		if direction.x < 0:
			anim.flip_h = true
		elif direction.x > 0:
			anim.flip_h = false

	else:

		if anim.animation != "idle_down":
			anim.play("idle_down")
