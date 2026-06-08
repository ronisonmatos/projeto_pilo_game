extends Node

# Sinais do jogador — usados pelo HUD e qualquer sistema que precise reagir ao estado do player
signal player_health_changed(new_val: int, max_val: int)
signal player_faith_changed(new_val: int, max_val: int)
signal player_died()

# Sinais de diálogo
signal dialogue_requested(dialogue_id: String)
signal dialogue_finished()

# Estado global de diálogo — impede que o player inicie novo diálogo enquanto um está ativo
var dialogue_active: bool = false
