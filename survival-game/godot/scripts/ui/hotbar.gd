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

# Beide Arrays benutzen denselben Index: slots[0] zeigt slot_item_ids[0] an.
var slots: Array[Button] = []
var slot_item_ids: Array[StringName] = []


# _input() erhält Tastatur- und Mausereignisse des Spiels.
func _input(event: InputEvent) -> void:
	# Mit dem Mausrad wird die Auswahl zyklisch verschoben.
	if event is InputEventMouseButton and event.pressed:
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

		select_slots(selected_index)

	# Die Zahlentasten 1 bis 9 wählen den entsprechenden Slot direkt aus.
	if event is InputEventKey and event.pressed and not event.echo:
		var slot_index: int = event.keycode - KEY_1
		if slot_index < slots.size() and slot_index >= 0:
			select_slots(slot_index)


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

	select_slots(selected_index)

	# Das Inventar kann im Editor fehlen; deshalb wird es vorher geprüft.
	if inventory != null:
		inventory.inventory_changed.connect(_on_inventory_changed)


# Aktiviert genau einen Slot und meldet dessen Gegenstands-ID an den Player.
func select_slots(index: int) -> void:
	selected_index = index

	for slot in slots:
		slot.button_pressed = false

	slots[selected_index].button_pressed = true
	var id: StringName = slot_item_ids[selected_index]
	selected_item_changed.emit(id)


# Reagiert auf jede Mengenänderung im Inventar.
func _on_inventory_changed(item_id: StringName, new_amount: int) -> void:
	# Zuerst wird geprüft, ob der Gegenstand bereits einen Slot besitzt.
	var item_index: int = slot_item_ids.find(item_id)

	# Bei Menge 0 wird der bisher belegte Slot wieder freigegeben.
	if new_amount <= 0:
		if item_index == -1:
			return

		slot_item_ids[item_index] = &""
		slots[item_index].text = ""

		# Wenn der geleerte Slot ausgewählt war, muss der Player ebenfalls die
		# neue leere Gegenstands-ID erhalten.
		if selected_index == item_index:
			select_slots(item_index)
		return

	# -1 bedeutet: Der Gegenstand ist noch keinem Slot zugeordnet.
	if item_index == -1:
		item_index = slot_item_ids.find(&"")

		# Auch die Suche nach einem freien Slot liefert -1, wenn keiner frei ist.
		if item_index == -1:
			print("Kein Platz in der Hotbar")
			return

		# Der gefundene freie Slot gehört ab jetzt zu diesem Gegenstand.
		slot_item_ids[item_index] = item_id

	# Neue und bereits vorhandene Items verwenden dieselbe Textdarstellung.
	var display_name := String(item_id).capitalize()
	slots[item_index].text = display_name + "\n" + str(new_amount) + "x"

	# Ist dieser Slot aktiv, wird seine ID erneut an den Player gemeldet.
	if item_index == selected_index:
		select_slots(item_index)
