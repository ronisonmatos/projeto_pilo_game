extends CharacterBody2D

var player_near = false

@onready var dialog_label = get_node("/root/Main/CanvasLayer/Label")

func _process(delta):

	if player_near and Input.is_action_just_pressed("ui_accept"):

		dialog_label.visible = true
		dialog_label.text = "Olá Fulano!"

func _on_area_2d_body_entered(body):
	player_near = true

func _on_area_2d_body_exited(body):
	player_near = false
	dialog_label.visible = false
