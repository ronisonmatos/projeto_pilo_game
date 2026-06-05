extends CanvasLayer

@onready var vida = get_node("VidaMoldura/VidaBarra")
@onready var fe   = get_node("FeMoldura/FeBarra")

func _ready():
	# Diagnóstico: mostra null se o caminho estiver errado
	print("VidaBarra: ", vida)
	print("FeBarra: ", fe)

func atualizar_vida(valor):
	if vida:
		vida.value = valor

func atualizar_fe(valor):
	if fe:
		fe.value = valor
