extends CharacterBody2D

var vida = 50

func receber_dano(valor):
	vida -= valor

	print("Tomou dano:", valor)
	print("Vida restante:", vida)

	if vida <= 0:
		print("NPC derrotado")
		queue_free()
