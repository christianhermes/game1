extends HBoxContainer

## Die Hotbar zeigt einen kleinen, direkt auswählbaren Teil des Inventars.
## Sie speichert keine Mengen selbst, sondern reagiert auf Änderungen des
## Inventars und meldet die Auswahl an den Player.

# Dieses Signal wird ausgelöst, sobald ein anderer Slot ausgewählt wird.
signal selected_item_changed(item_id: StringName)

# Das Inventar wird im Inspektor zugewiesen.
@export var inventory: Inventory

# Index des aktuell ausgewählten Slots. Der erste Slot hat den Index 0.
var selected_index: int = 0

# Im Basismodus verwendet die Kamera das Mausrad zum Zoomen.
var mouse_wheel_enabled := true

# Beide Arrays benutzen denselben Index: slots[0] zeigt slot_item_ids[0] an.
var slots: Array[Button] = []
var slot_item_ids: Array[StringName] = []


# _input() erhält Tastatur- und Mausereignisse des Spiels.
func _input(event: InputEvent) -> void:
	# Mit dem Mausrad wird die Auswahl zyklisch verschoben.
	if mouse_wheel_enabled and event is InputEventMouseButton and event.pressed:
		var direction: String = ""

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			direction = "up"
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			direction = "down"

		# wrapi springt hinter dem letzten Slot wieder zum ersten und umgekehrt.
		if direction == "up":
			selected_index = wrapi(selected_index - 1, 0, slots.size())
		elif direction == "down":
			selected_index = wrapi(selected_index + 1, 0, slots.size())

		if direction != "":
			select_slots(selected_index)

	# Die Zahlentasten 1 bis 9 wählen den entsprechenden Slot direkt aus.
	if event is InputEventKey and event.pressed and not event.echo:
		var slot_index: int = event.keycode - KEY_1
		if slot_index < slots.size() and slot_index >= 0:
			select_slots(slot_index)


func set_mouse_wheel_enabled(enabled: bool) -> void:
	mouse_wheel_enabled = enabled


# Sammelt die Button-Kinder ein und verbindet alle benötigten Signale.
func _ready() -> void:
	for child in get_children():
		if child is Button:
			child.toggle_mode = true
			slots.append(child)

	for i in range(slots.size()):
		var current_slot: Button = slots[i]

		# Eine leere StringName-ID bedeutet: Dieser Slot ist noch frei.
		slot_item_ids.append(&"")

		# bind(i) merkt sich für jeden Button seinen eigenen Index.
		current_slot.pressed.connect(select_slots.bind(i))

	# Das Inventar kann im Editor fehlen; deshalb wird es vorher geprüft.
	if inventory != null:
		inventory.contents_changed.connect(_refresh_from_inventory)
		_refresh_from_inventory()
	else:
		select_slots(selected_index)


# Aktiviert genau einen Slot und meldet dessen Gegenstands-ID an den Player.
func select_slots(index: int) -> void:
	selected_index = index

	for slot in slots:
		slot.button_pressed = false

	slots[selected_index].button_pressed = true
	var id: StringName = slot_item_ids[selected_index]
	selected_item_changed.emit(id)


# Spiegelt die ersten Hotbar-Plätze direkt auf die physischen Inventarslots.
# Zwei Stapel derselben Itemart bleiben dadurch als zwei Einträge sichtbar.
func _refresh_from_inventory() -> void:
	if inventory == null:
		return

	var inventory_slots := inventory.get_slots_snapshot()
	for index in range(slots.size()):
		if index >= inventory_slots.size():
			slot_item_ids[index] = &""
			slots[index].text = ""
			continue

		var stack := inventory_slots[index]
		if stack == null or stack.is_empty():
			slot_item_ids[index] = &""
			slots[index].text = ""
			continue

		slot_item_ids[index] = stack.item_id
		var display_name := String(stack.item_id).capitalize()
		if inventory.item_catalog != null:
			var definition := inventory.item_catalog.get_definition(stack.item_id)
			if definition != null:
				display_name = definition.display_name
		slots[index].text = display_name + "\n" + str(stack.amount) + "x"

	# Mengenänderungen können den ausgewählten Slot leeren oder neu belegen.
	select_slots(selected_index)
