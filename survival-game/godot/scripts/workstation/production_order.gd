class_name ProductionOrder
extends RefCounted


# Ein Queue-Eintrag besitzt eine stabile Laufzeit-ID, genau ein Rezept und die
# Anzahl identischer Produktionsläufe, die dieser Stapel noch repräsentiert.
var id: int
var recipe: ProcessingRecipe
var amount: int


func _init(
	order_id: int,
	order_recipe: ProcessingRecipe,
	order_amount: int = 1,
) -> void:
	id = order_id
	recipe = order_recipe
	amount = order_amount
