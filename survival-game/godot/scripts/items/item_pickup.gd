class_name ItemPickup
extends Area3D

## Ein ItemPickup ist ein allgemeiner aufhebbarer Gegenstand in der Spielwelt.
## Welche Art Gegenstand es ist, wird über item_id im Inspektor festgelegt.

# Gegenstands-ID und Menge, die beim Aufheben ins Inventar gelangen.
@export var world_id: StringName = &""
@export var item_id: StringName = &""
@export_range(1, 99, 1) var amount: int = 1
@onready var item_label: Label3D = $Label3D


# Registriert dieses Objekt als mögliche Interaktion für den Spieler.
func _ready() -> void:
	add_to_group("interactable")
	add_to_group("job_targets")
	_update_label()


# Die Welt-ID bleibt auch dann als Auftragsziel erhalten, wenn die sichtbare
# Basisszene vorübergehend nicht geladen ist.
func get_job_target_id() -> StringName:
	return world_id


# Teilt dem gemeinsamen Auftragssystem mit, welcher Auftrag für dieses
# Weltobjekt erzeugt werden muss.
func get_job_type() -> SettlementJobManager.JobType:
	return SettlementJobManager.JobType.PICKUP


# Zeigt die Item-ID als lesbaren Namen an und kennzeichnet Pickups ohne
# konfigurierte ID eindeutig als unbekannte Ressource.
func _update_label() -> void:
	var display_name = String(item_id)

	if display_name.is_empty():
		item_label.text = "Unbekannte Ressource"
		return
	item_label.text = display_name.capitalize()


# actor ist der Node, der mit dem Pickup interagiert, normalerweise der Player.
func interact(actor: Node3D) -> void:
	# Die Methodenprüfung hält das Pickup von einer bestimmten Actor-Klasse
	# unabhängig. Jeder passende Node kann später Gegenstände aufnehmen.
	if actor.has_method("receive_item"):
		actor.receive_item(item_id, amount)

		# Nach erfolgreicher Übergabe wird das Pickup aus der Szene entfernt.
		queue_free()
