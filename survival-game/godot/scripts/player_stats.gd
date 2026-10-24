class_name PlayerStats
extends Node

signal health_changed(current: float, maximum: float)
signal mana_changed(current: float, maximum: float)
signal hunger_changed(current: float, maximum: float)
signal died


# maximale Werte für die ANzeigeleisten
@export var max_health := 100.0
@export var max_mana := 50.0
@export var max_hunger := 100.0

# automatische Abnahme von Hunger und Mana Regeneration sowie Schaden durch Verhungern
@export var mana_regeneration_per_second := 2.0
@export var hunger_loss_per_second := 0.25
@export var starvation_damage_per_second := 5.0

var health: float
var mana: float
var hunger: float


func _ready() -> void:
	health = max_health
	mana = max_mana
	hunger = max_hunger
	
func reset_stats() -> void:
	health = max_health
	mana = max_mana
	hunger = max_hunger
	
	health_changed.emit(health, max_health)
	hunger_changed.emit(hunger, max_hunger)
	mana_changed.emit(mana, max_mana)
	
	
func take_damage(amount: float) -> void:
	if amount <= 0.0 or health <= 0.0:
		return

	health = clampf(health - amount, 0.0, max_health)
	health_changed.emit(health, max_health)

	if health <= 0.0:
		died.emit()
		
		
func heal(amount: float) -> void:
	if amount <= 0.0 or health >= max_health:
		return
	health = clampf(health + amount, 0.0, max_health)
	health_changed.emit(health, max_health)
	
	
func try_use_mana(amount: float) -> bool:
	if amount <= 0.0:
		return false

	if mana < amount:
		return false

	mana = clampf(mana - amount, 0.0, max_mana)
	mana_changed.emit(mana, max_mana)
	return true
	
func restore_mana(amount: float) -> void:
	if amount <= 0.0 or mana >= max_mana:
		return
	
	mana = clampf(mana + amount, 0.0, max_mana)
	mana_changed.emit(mana, max_mana)
	
	
	
func reduce_hunger(amount: float) -> void:
	if amount <= 0.0 or hunger <= 0.0:
		return
		
	hunger = clampf(hunger - amount, 0.0, max_hunger)
	hunger_changed.emit(hunger, max_hunger)

func eat(amount: float) -> void:
	if amount <= 0.0 or hunger >= max_hunger:
		return
		
	hunger = clampf(hunger + amount, 0.0, max_hunger)
	hunger_changed.emit(hunger, max_hunger)
	
	
	
	
	
	
func _process(delta: float) -> void:
	restore_mana(mana_regeneration_per_second * delta)
	reduce_hunger(hunger_loss_per_second * delta)

	if hunger <= 0.0:
		take_damage(starvation_damage_per_second * delta)
