class_name FaithComponent
extends Node

signal faith_changed(new_val: int, max_val: int)
signal faith_depleted()

@export var max_faith: int = 100

var _faith: int

func _ready() -> void:
	_faith = max_faith

# Gasta fé. Sempre aplica o gasto (clampado em 0); retorna true se havia fé suficiente.
func spend(amount: int) -> bool:
	var had_enough := _faith >= amount
	_faith = maxi(0, _faith - amount)
	faith_changed.emit(_faith, max_faith)
	if _faith == 0:
		faith_depleted.emit()
	return had_enough

func restore(amount: int) -> void:
	_faith = clampi(_faith + amount, 0, max_faith)
	faith_changed.emit(_faith, max_faith)

func get_faith() -> int:
	return _faith

func get_max_faith() -> int:
	return max_faith
