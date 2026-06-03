extends Panel

@onready var portrait = $Portrait
@onready var text = $Text
@onready var speaker = $Name

var dialogo_ativo = false
var indice = 0

var dialogos = [
	{
		"nome":"Monge",
		"texto":"Memento Mori.",
		"retrato":"res://portraits/perfil_monge.png"
	},

	{
		"nome":"Peregrino",
		"texto":"Ad aeternitatem.",
		"retrato":"res://portraits/player_dialogo.png"
	},

	{
		"nome":"Monge",
		"texto":"Bem-vindo ao Vale das Virtudes.",
		"retrato":"res://portraits/perfil_monge.png"
	},

	{
		"nome":"Peregrino",
		"texto":"Obrigado!",
		"retrato":"res://portraits/player_dialogo.png"
	}
]

func _ready():
	hide()

func iniciar_dialogo():

	indice = 0
	dialogo_ativo = true

	show()

	mostrar_dialogo()

func mostrar_dialogo():

	var fala = dialogos[indice]
	speaker.text = dialogos[indice]["nome"]
	text.text = dialogos[indice]["texto"]
	portrait.texture = load(fala["retrato"])

func _input(event):

	if !dialogo_ativo:
		return

	if event.is_action_pressed("ui_accept"):

		indice += 1

		if indice >= dialogos.size():

			hide()

			dialogo_ativo = false
			indice = 0

			return

		mostrar_dialogo()
