extends VBoxContainer

@export var stats: PlayerStats

@onready var health_bar: ProgressBar = $HealthBar
@onready var mana_bar: ProgressBar = $ManaBar
@onready var hunger_bar: ProgressBar = $HungerBar

var previous_health := 0.0
var health_feedback_tween: Tween


func _ready() -> void:
	if stats == null:
		push_warning("Dem StatusHUD wurden keine PlayerStats zugewiesen.")
		return

	stats.health_changed.connect(_on_health_changed)
	stats.mana_changed.connect(_on_mana_changed)
	stats.hunger_changed.connect(_on_hunger_changed)
	previous_health = stats.health
	_on_health_changed(stats.health, stats.max_health)
	_on_mana_changed(stats.mana, stats.max_mana)
	_on_hunger_changed(stats.hunger, stats.max_hunger)

## Aktualisiert die Lebensleiste und hebt ausschließlich verlorene Lebenspunkte
## kurz rot hervor. Heilung aktualisiert nur den Vergleichswert.
func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	if current < previous_health:
		if health_feedback_tween != null:
			health_feedback_tween.kill()
		health_bar.modulate = Color(1.0, 0.25, 0.2, 1.0)
		health_feedback_tween = create_tween()
		health_feedback_tween.tween_property(
			health_bar,
			"modulate",
			Color.WHITE,
			0.25,
		)
	previous_health = current


func _on_mana_changed(current: float, maximum: float) -> void:
	mana_bar.max_value = maximum
	mana_bar.value = current


func _on_hunger_changed(current: float, maximum: float) -> void:
	hunger_bar.max_value = maximum
	hunger_bar.value = current
