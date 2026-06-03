extends Panel

@onready var text = $Text
@onready var speaker = $Name

var dialogos = [
	{
		"nome":"Padre Miguel",
		"texto":"Bem vindo peregrino."
	},
	{
		"nome":"Padre Miguel",
		"texto":"A igreja precisa da sua ajuda."
	},
	{
		"nome":"Padre Miguel",
		"texto":"Vá até a capela."
	}
]

var indice = 0

func _ready():
	mostrar_dialogo()

func mostrar_dialogo():
	speaker.text = dialogos[indice]["nome"]
	text.text = dialogos[indice]["texto"]

func _input(event):
	if visible and event.is_action_pressed("ui_accept"):
		indice += 1

		if indice >= dialogos.size():
			hide()
			return

		mostrar_dialogo()
