extends Node
class_name HealthComponent

signal invincibility_started()
signal invincibility_ended()
signal health_changed(new_health: float)
signal health_depleted()
signal damage_taken(amount: float)
signal healing_received(amount: float)

@export var invincibility_time: float = 0.5

var current_health: float
var is_invincible: bool = false

func _ready():
	current_health = UpgradesManager.upgrades.Sanity
	health_changed.emit(current_health)

# NOTE: ignore_invincibility is for the constant sanity loss
# and potentially similar additions in the future (e.g. poison damage)
func take_damage(amount: float, ignore_invincibility: bool = false):
	if is_invincible and not ignore_invincibility:
		return
	
	if amount <= 0:
		return
	
	current_health = max(0, current_health - amount)
	damage_taken.emit(amount)
	health_changed.emit(current_health)
	
	if current_health <= 0:
		health_depleted.emit()
		return
	
	if not ignore_invincibility:
		is_invincible = true
		invincibility_started.emit()
		await get_tree().create_timer(invincibility_time).timeout
		is_invincible = false
		invincibility_ended.emit()


func heal(amount: float):
	if amount <= 0 or current_health >= UpgradesManager.upgrades.Sanity:
		return false
	
	current_health = min(current_health + amount, UpgradesManager.upgrades.Sanity)
	health_changed.emit(current_health)
	healing_received.emit(amount)
	return true

func get_health_percentage() -> float:
	return current_health / UpgradesManager.upgrades.Sanity

func is_alive() -> bool:
	return current_health > 0
