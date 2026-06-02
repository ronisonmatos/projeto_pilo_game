extends CharacterBody2D

@export var speed = 200

@onready var anim = $AnimatedSprite2D

var last_direction = "down"

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

	else:

		match last_direction:

			"down":
				anim.play("idle_down")

			"up":
				anim.play("idle_up")

			"left":
				anim.play("idle_left")

			"right":
				anim.play("idle_right")
