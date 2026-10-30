class_name ItemPickup
extends Area3D

## Ein ItemPickup ist ein allgemeiner aufhebbarer Gegenstand in der Spielwelt.
## Welche Art Gegenstand es ist, wird über item_id im Inspektor festgelegt.

# Gegenstands-ID und Menge, die beim Aufheben ins Inventar gelangen.
@export var world_id: StringName = &""
@export var item_id: StringName = &""
@export_range(1, 999, 1) var amount: int = 1


# Registriert dieses Objekt als mögliche Interaktion für den Spieler.
func _ready() -> void:
	add_to_group("interactable")
	add_to_group("job_targets")


# Die Welt-ID bleibt auch dann als Auftragsziel erhalten, wenn die sichtbare
# Basisszene vorübergehend nicht geladen ist.
func get_job_target_id() -> StringName:
	return world_id


# Teilt dem gemeinsamen Auftragssystem mit, welcher Auftrag für dieses
# Weltobjekt erzeugt werden muss.
func get_job_type() -> SettlementJobManager.JobType:
	return SettlementJobManager.JobType.PICKUP


## Liefert Name und Menge für das gemeinsame Auswahlfenster.
func get_world_info_title() -> String:
	var item_name := String(item_id)
	return "Unbekannte Ressource" if item_name.is_empty() else item_name.capitalize()


func get_world_info_text() -> String:
	return "Menge: %d" % amount


# actor ist der Node, der mit dem Pickup interagiert, normalerweise der Player.
func interact(actor: Node3D) -> void:
	# Die Methodenprüfung hält das Pickup von einer bestimmten Actor-Klasse
	# unabhängig. Jeder passende Node kann später Gegenstände aufnehmen.
	if actor.has_method("receive_item"):
		amount = actor.call("receive_item", item_id, amount)

		# Ein nicht oder nur teilweise aufgenommenes Pickup bleibt in der Welt.
		if amount == 0:
			queue_free()
