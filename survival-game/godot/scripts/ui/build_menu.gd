class_name BuildMenu
extends PanelContainer

signal recipe_selected(recipe: BuildRecipe)

@onready var recipe_buttons: VBoxContainer = $Margin/VBox/RecipeButtons


func _ready() -> void:
	visible = false


## Ersetzt die bisherigen Buttons durch je einen Button pro gültigem Rezept.
## Jeder Button bindet sein eigenes Rezept an den Callback; das Menü meldet die
## Auswahl nur über recipe_selected und verändert den BuildManager nicht selbst.
func set_recipes(recipes: Array[BuildRecipe]) -> void:
	for child in recipe_buttons.get_children():
		if not child == null:
			child.queue_free()

	for recipe in recipes:
		if recipe == null:
			continue
		var btn = Button.new()
		btn.text = String(recipe.display_name)
		btn.pressed.connect(_on_recipe_button_pressed.bind(recipe))
		recipe_buttons.add_child(btn)


func set_catalog_visible(is_visible: bool) -> void:
	visible = is_visible


## Leitet die Auswahl als Signal weiter. Dieser Teil ist bereits fertig, damit
## du dich in Aufgabe 46 auf dynamisch erzeugte Buttons konzentrieren kannst.
func _on_recipe_button_pressed(recipe: BuildRecipe) -> void:
	recipe_selected.emit(recipe)
