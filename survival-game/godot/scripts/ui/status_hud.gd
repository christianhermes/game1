extends VBoxContainer

@export var stats: PlayerStats

@onready var health_bar: ProgressBar = $HealthBar
@onready var mana_bar: ProgressBar = $ManaBar
@onready var hunger_bar: ProgressBar = $HungerBar


func _ready() -> void:
	if stats == null:
		push_warning("Dem StatusHUD wurden keine PlayerStats zugewiesen.")
		return

	stats.health_changed.connect(_on_health_changed)
	stats.mana_changed.connect(_on_mana_changed)
	stats.hunger_changed.connect(_on_hunger_changed)
	_on_health_changed(stats.health, stats.max_health)
	_on_mana_changed(stats.mana, stats.max_mana)
	_on_hunger_changed(stats.hunger, stats.max_hunger)

func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	
func _on_mana_changed(current: float, maximum: float) -> void:
	mana_bar.max_value = maximum
	mana_bar.value = current
	
func _on_hunger_changed(current: float, maximum: float) -> void:
	hunger_bar.max_value = maximum
	hunger_bar.value = current
