class_name ItemPickup
extends Area3D

## Ein ItemPickup ist ein allgemeiner aufhebbarer Gegenstand in der Spielwelt.
## Welche Art Gegenstand es ist, wird über item_id im Inspektor festgelegt.

# Gegenstands-ID und Menge, die beim Aufheben ins Inventar gelangen.
@export var item_id: StringName = &""
@export_range(1, 99, 1) var amount: int = 1


# Registriert dieses Objekt als mögliche Interaktion für den Spieler.
func _ready() -> void:
	add_to_group("interactable")


# actor ist der Node, der mit dem Pickup interagiert, normalerweise der Player.
func interact(actor: Node3D) -> void:
	# Die Methodenprüfung hält das Pickup von einer bestimmten Actor-Klasse
	# unabhängig. Jeder passende Node kann später Gegenstände aufnehmen.
	if actor.has_method("receive_item"):
		actor.receive_item(item_id, amount)

		# Nach erfolgreicher Übergabe wird das Pickup aus der Szene entfernt.
		queue_free()
