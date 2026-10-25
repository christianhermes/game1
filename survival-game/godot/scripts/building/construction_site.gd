class_name ConstructionSite
extends Area3D

@export var recipe: BuildRecipe
# Jede dynamisch platzierte Baustelle benötigt eine eindeutige Welt-ID, damit
# ein Auftrag keine kurzlebige Node-Referenz speichern muss.
@export var world_id: StringName = &""
var delivered_materials: Dictionary = {}
var current_work: int = 0
@onready var site_label: Label3D = $SiteLabel

func _ready() -> void:
	add_to_group("interactable")
	# Die Gruppe und world_id machen auch dynamisch platzierte Baustellen zu
	# auflösbaren Zielen für den SettlementJobManager.
	add_to_group("job_targets")

	if recipe == null:
		site_label.text = "Kein Rezept ausgewählt"
		return

	_update_label()


# Liefert die stabile Ziel-ID, unter der Bewohner diese Baustelle wiederfinden.
func get_job_target_id() -> StringName:
	return world_id


# Kennzeichnet Interaktionen mit dieser Baustelle als Bauauftrag.
func get_job_type() -> SettlementJobManager.JobType:
	return SettlementJobManager.JobType.BUILD


# TODO AUFGABE 19: Übergib in einem Auftrag alle benötigten Materialien.
#
# Teile die Materiallogik dafür in zwei Hilfsfunktionen auf:
#
# 1. _has_all_materials() -> bool
#    - Durchlaufe recipe.required_materials.
#    - Vergleiche für jeden Eintrag die gelieferte Menge aus
#      delivered_materials mit material.amount.
#    - Sobald eine Menge fehlt: return false. Sonst am Ende return true.
#
# 2. _deliver_all_materials(actor: Node3D) -> bool
#    - Prüfe zuerst, ob actor die Methode try_use_item besitzt.
#    - Durchlaufe alle benötigten Materialien.
#    - Solange delivered kleiner als material.amount ist, versuche mit
#      try_use_item genau ein Stück aus dem Inventar zu entnehmen.
#    - Bei fehlendem Material: Label aktualisieren und return false.
#    - Nach jedem Erfolg delivered erhöhen und im Dictionary speichern.
#    - Nach vollständiger Übergabe Label aktualisieren und true zurückgeben.
#
# Vereinfache interact() danach auf diesen Ablauf:
# - Wenn _deliver_all_materials(actor) false liefert: return.
# - Andernfalls einmal _try_build(actor) aufrufen.
#
# Wichtig: Eine while-Schleife darf hier Material übertragen, weil keine
# sichtbare Arbeitszeit simuliert wird. Die Hammerschläge erhalten in Aufgabe
# 21 dagegen bewusst einen Timer.
func interact(actor: Node3D) -> void:
	# Autonome Bauaufträge greifen direkt auf das Inventar des Bewohners zu und
	# hängen deshalb nicht von dessen ausgewähltem Hotbar-Slot ab.
	if not actor.has_method("try_use_item"):
		return

	for material in recipe.required_materials:
		var delivered: int = delivered_materials.get(material.item_id, 0)
		if delivered >= material.amount:
			continue

		var material_used: bool = actor.call(
			"try_use_item",
			material.item_id,
			1,
		)
		if not material_used:
			return

		delivered_materials[material.item_id] = delivered + 1
		_update_label()
		return
	_try_build(actor)

func _update_label() -> void:
	var material: ItemAmount = recipe.required_materials[0]
	var delivered: int = delivered_materials.get(material.item_id, 0)
	site_label.text = "%s\n%s: %d/%d" % [
	recipe.display_name,
	String(material.item_id).capitalize(),
	delivered,
	material.amount,
	]
	if delivered >= material.amount:
		site_label.text = "%s\n%s\nArbeit: %d/%d" % [
		recipe.display_name,
		String(recipe.required_tool_id).capitalize(),
		current_work,
		recipe.required_work,
		]
		return

func _try_build(actor: Node3D) -> void:
	if not actor.has_method("has_item"):
		return

	var correct_tool_selected: bool = actor.call(
		"has_item",
		recipe.required_tool_id,
	)
	if not correct_tool_selected:
		return

	current_work += 1
	if current_work >= recipe.required_work:
		_complete_building()
		return

	_update_label()


# TODO AUFGABE 21: Führe einen vollständigen Bauauftrag mit Arbeitszeit aus.
#
# Ergänze eine asynchrone Funktion:
#   perform_build_job(actor: Node3D, job_id: int) -> bool
#
# Ablauf:
# 1. Rufe _deliver_all_materials(actor) auf. Bei false ebenfalls false
#    zurückgeben. Der Auftrag wartet in V1 nicht auf Material aus einer Kiste.
# 2. Prüfe has_item und den Besitz von recipe.required_tool_id. Das Werkzeug
#    wird nur benötigt, aber nicht verbraucht.
# 3. Solange current_work kleiner als recipe.required_work ist:
#    - Prüfe mit actor.is_current_job(job_id), ob der Auftrag noch aktiv ist.
#      Fehlt die Methode oder ist das Ergebnis false: return false.
#    - Warte mit
#        await get_tree().create_timer(0.75).timeout
#      auf den nächsten sichtbaren Hammerschlag.
#    - Prüfe den Auftrag direkt nach dem Warten erneut. So führt ein während
#      des Timers erteilter neuer Befehl keinen alten Hammerschlag mehr aus.
#    - Erhöhe current_work um eins und rufe _update_label() auf.
# 4. Rufe nach der Schleife _complete_building() auf und gib true zurück.
#
# Verwende hier nicht _try_build(), weil diese ältere Einzelschritt-Methode
# keinen zeitlichen Abstand und keinen job_id-basierten Abbruch kennt.


func _complete_building() -> void:
	var finished_building: Node3D = recipe.finished_scene.instantiate()
	get_parent().add_child(finished_building)
	finished_building.global_transform = global_transform
	queue_free()
