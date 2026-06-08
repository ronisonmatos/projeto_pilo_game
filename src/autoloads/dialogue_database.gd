extends Node

# Banco de dados central de todos os diálogos do jogo.
# Para adicionar um novo diálogo, inclua uma entrada neste dicionário com um ID único.
# Cada linha precisa de: "speaker" (nome do personagem), "text" (fala), "portrait" (caminho da imagem).
const DIALOGUES: Dictionary = {
	"monk_intro": [
		{ "speaker": "Monge",     "text": "Memento Mori.",                  "portrait": "res://portraits/perfil_monge.png"   },
		{ "speaker": "Peregrino", "text": "Ad aeternitatem.",               "portrait": "res://portraits/player_dialogo.png" },
		{ "speaker": "Monge",     "text": "Bem-vindo ao Vallis Virtutum.", "portrait": "res://portraits/perfil_monge.png"   },
		{ "speaker": "Peregrino", "text": "Obrigado!",                      "portrait": "res://portraits/player_dialogo.png" },
	],
}

func get_dialogue(id: String) -> Array:
	if DIALOGUES.has(id):
		return DIALOGUES[id]
	push_warning("[DialogueDatabase] Diálogo não encontrado: '%s'" % id)
	return []
