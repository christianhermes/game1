extends SceneTree


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var catalog := load("res://data/items/item_catalog.tres") as ItemCatalog
	assert(catalog != null and catalog.is_valid())

	var inventory := _create_inventory(catalog, 4)
	assert(inventory.add_item(&"wood", 100) == 0)
	var wood_slots := inventory.get_slots_snapshot()
	assert(wood_slots[0].amount == 99)
	assert(wood_slots[1].amount == 1)
	wood_slots[0].amount = 1
	assert(inventory.get_amount(&"wood") == 100)

	assert(inventory.add_item(&"hammer", 2) == 0)
	var filled_slots := inventory.get_slots_snapshot()
	assert(filled_slots[2].item_id == &"hammer" and filled_slots[2].amount == 1)
	assert(filled_slots[3].item_id == &"hammer" and filled_slots[3].amount == 1)
	assert(inventory.add_item(&"stone", 1) == 1)
	_test_hotbar_stack_display(inventory)

	assert(inventory.remove_item(&"wood", 100))
	assert(inventory.get_amount(&"wood") == 0)
	assert(inventory.get_amount(&"hammer") == 2)

	var one_slot_inventory := _create_inventory(catalog, 1)
	var seed_output := ItemAmount.new()
	seed_output.item_id = &"wheat_seed"
	seed_output.amount = 2
	var straw_output := ItemAmount.new()
	straw_output.item_id = &"straw"
	straw_output.amount = 1
	var competing_outputs: Array[ItemAmount] = [seed_output, straw_output]
	assert(not one_slot_inventory.can_add_items(competing_outputs))

	var source := _create_inventory(catalog, 4)
	var target := _create_inventory(catalog, 1)
	assert(source.add_item(&"wood", 50) == 0)
	assert(target.add_item(&"wood", 90) == 0)
	assert(source.transfer_to(target, &"wood", 50) == 9)
	assert(source.get_amount(&"wood") == 41)
	assert(target.get_amount(&"wood") == 99)
	assert(source.transfer_to(target, &"wood", 10) == 0)
	assert(source.get_amount(&"wood") == 41)
	assert(source.transfer_to(source, &"wood", 10) == 0)

	var slot_source := _create_inventory(catalog, 2)
	var slot_target := _create_inventory(catalog, 2)
	assert(slot_source.add_item(&"wood", 100) == 0)
	assert(slot_source.transfer_slot_to(slot_target, 1, 1) == 1)
	var slot_source_snapshot := slot_source.get_slots_snapshot()
	assert(slot_source_snapshot[0].amount == 99)
	assert(slot_source_snapshot[1].is_empty())
	assert(slot_target.get_amount(&"wood") == 1)

	print("INVENTORY_SMOKE_TEST_OK")
	quit()


func _create_inventory(catalog: ItemCatalog, capacity: int) -> Inventory:
	var inventory := Inventory.new()
	inventory.item_catalog = catalog
	inventory.slot_capacity = capacity
	root.add_child(inventory)
	return inventory


func _test_hotbar_stack_display(inventory: Inventory) -> void:
	var hotbar := HBoxContainer.new()
	hotbar.set_script(load("res://scripts/ui/hotbar.gd"))
	hotbar.set("inventory", inventory)

	var buttons: Array[Button] = []
	for _index in range(9):
		var button := Button.new()
		buttons.append(button)
		hotbar.add_child(button)
	root.add_child(hotbar)

	assert(buttons[0].text == "Holz\n99x")
	assert(buttons[1].text == "Holz\n1x")
	assert(buttons[2].text == "Hammer\n1x")
	assert(buttons[3].text == "Hammer\n1x")
