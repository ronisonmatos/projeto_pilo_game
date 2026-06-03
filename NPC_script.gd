extends CharacterBody2D

var player_near = false
var dialogo_ja_executado = false
@onready var interaction_icon = $InteractionIcon
@onready var dialog_box = get_node("/root/Main/CanvasLayer/DialogBox")

func _process(delta):

	if player_near and !dialogo_ja_executado:

		if Input.is_action_just_pressed("ui_accept"):

			if !dialog_box.dialogo_ativo:

				dialog_box.iniciar_dialogo()
				dialogo_ja_executado = true

func _on_area_2d_body_entered(body):

	if body.name == "Player":
		player_near = true
		interaction_icon.visible = true

func _on_area_2d_body_exited(body):

	if body.name == "Player":
		player_near = false
		dialogo_ja_executado = false
		interaction_icon.visible = false
		
		
