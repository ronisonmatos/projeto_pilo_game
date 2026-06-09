class_name HealthComponent
extends Node

signal health_changed(new_val: int, max_val: int)
signal damage_taken(amount: int)
signal died()

@export var max_health: int = 100

var _health: int
var _dead: bool = false

func _ready() -> void:
	_health = max_health

func take_damage(amount: int) -> void:
	if _dead:
		return
	_health = clampi(_health - amount, 0, max_health)
	damage_taken.emit(amount)
	health_changed.emit(_health, max_health)
	if _health == 0:
		_dead = true
		died.emit()

func heal(amount: int) -> void:
	_health = clampi(_health + amount, 0, max_health)
	health_changed.emit(_health, max_health)

func get_health() -> int:
	return _health

func is_alive() -> bool:
	return not _dead

func reset() -> void:
	_dead   = false
	_health = max_health
	health_changed.emit(_health, max_health)
