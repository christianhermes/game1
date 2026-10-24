class_name FarmPlot
extends Area3D

## Ein FarmPlot ist ein interaktives Feld mit genau drei möglichen Zuständen:
## leer, wachsend oder erntereif. Die konkrete Pflanzenart kommt aus CropData.

# Namen statt Zahlen machen die Zustände im Code leicht verständlich.
enum PlotState {
	EMPTY,
	GROWING,
	READY,
}

# Im Inspektor zugewiesene Daten der Pflanzenart.
@export var crop_data: CropData

# Verweise auf die untergeordneten Nodes dieser Szene.
@onready var crop_visual: MeshInstance3D = $CropVisual
@onready var growth_timer: Timer = $GrowthTimer
@onready var state_label: Label3D = $StateLabel

# Jedes neu geladene Feld beginnt leer.
var state := PlotState.EMPTY

# Eigenes Material dieses Feldes, damit Farbänderungen keine anderen Felder
# beeinflussen, die ursprünglich dasselbe Material benutzt haben.
var crop_material: StandardMaterial3D


# Bereitet das Feld vor, sobald seine Szene geladen wurde.
func _ready() -> void:
	# Der Player berücksichtigt nur Nodes aus dieser Interaktionsgruppe.
	add_to_group("interactable")

	# Wenn der Timer endet, wird automatisch _on_growth_finished() aufgerufen.
	growth_timer.timeout.connect(_on_growth_finished)

	if crop_data == null:
		push_warning("FarmPlot besitzt keine CropData.")

	_create_unique_crop_material()
	_update_visuals()


# Aktualisiert während des Wachstums die sichtbare Restzeit.
func _process(_delta: float) -> void:
	if state == PlotState.GROWING:
		state_label.text = "Wächst\n%d s" % ceili(growth_timer.time_left)


# Verteilt die Interaktion abhängig vom aktuellen Zustand des Feldes.
func interact(actor: Node3D) -> void:
	match state:
		PlotState.EMPTY:
			_plant(actor)
		PlotState.GROWING:
			# Eine wachsende Pflanze darf nicht wieder entfernt werden.
			print("Das Feld wächst noch.")
		PlotState.READY:
			_harvest(actor)


# Prüft Saatgut und startet anschließend das Wachstum.
func _plant(actor: Node3D) -> void:
	if crop_data == null:
		push_warning("Ohne CropData kann nichts gepflanzt werden.")
		return

	# Das Feld kennt nicht die konkrete Player-Klasse. Es verlangt nur die
	# Fähigkeit, einen ausgewählten Gegenstand zu benutzen.
	if not actor.has_method("try_use_selected_item"):
		state_label.text = "Passendes Saatgut auswählen"
		return

	# Genau ein passendes Saatgut wird aus dem Inventar entfernt.
	var seed_used: bool = actor.call(
		"try_use_selected_item",
		crop_data.seed_item_id,
		1,
	)
	if not seed_used:
		state_label.text = "Passendes Saatgut auswählen"
		return

	state = PlotState.GROWING
	growth_timer.start(crop_data.growth_seconds)
	_update_visuals()


# Callback des Timers: Eine wachsende Pflanze wird erntereif.
func _on_growth_finished() -> void:
	if state != PlotState.GROWING:
		return

	state = PlotState.READY
	_update_visuals()


# Übergibt die Ernte an den Actor und setzt das Feld danach zurück.
func _harvest(actor: Node3D) -> void:
	print(
		actor.name,
		" erntet ",
		crop_data.harvest_amount,
		"x ",
		crop_data.display_name,
	)

	if actor.has_method("receive_item"):
		actor.receive_item(crop_data.id, crop_data.harvest_amount)

	state = PlotState.EMPTY
	_update_visuals()


# Erstellt eine Materialkopie, die nur diesem einen Feld gehört.
func _create_unique_crop_material() -> void:
	var source_material := crop_visual.get_active_material(0)
	if source_material is StandardMaterial3D:
		crop_material = source_material.duplicate() as StandardMaterial3D
	else:
		crop_material = StandardMaterial3D.new()

	crop_visual.set_surface_override_material(0, crop_material)


# Hält Modell, Farbe und Beschriftung mit dem Zustand synchron.
func _update_visuals() -> void:
	match state:
		PlotState.EMPTY:
			crop_visual.visible = false
			state_label.text = "Leer"

		PlotState.GROWING:
			crop_visual.visible = true
			crop_material.albedo_color = crop_data.planted_color
			state_label.text = "Wächst"

		PlotState.READY:
			crop_visual.visible = true
			crop_material.albedo_color = crop_data.ready_color
			state_label.text = "Erntereif"
