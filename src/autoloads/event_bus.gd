extends Node

signal player_health_changed(new_val: int, max_val: int)
signal player_faith_changed(new_val: int, max_val: int)
signal player_died()

signal dialogue_requested(dialogue_id: String)
signal dialogue_finished()

var dialogue_active: bool = false

func _ready() -> void:
	_ensure_bus("Music")
	_ensure_bus("SFX")
	_ensure_bus("Background_Sound_Map_1")

func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	var idx := AudioServer.bus_count
	AudioServer.add_bus(idx)
	AudioServer.set_bus_name(idx, bus_name)
	AudioServer.set_bus_send(idx, "Master")
