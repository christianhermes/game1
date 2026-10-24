class_name CropData
extends Resource

## CropData enthält nur die einstellbaren Daten einer Pflanzenart.
## Das eigentliche Verhalten liegt in FarmPlot. So kann dasselbe Feld später
## unterschiedliche Pflanzen anbauen, ohne dass dafür neuer Code nötig ist.

# ID des Gegenstands, den der Spieler bei der Ernte erhält.
@export var id: StringName

# Lesbarer Name für Texte und Ausgaben.
@export var display_name: String

# Wachstumsdauer in Sekunden. @export_range begrenzt die Werte im Inspektor.
@export_range(0.1, 3600.0, 0.1) var growth_seconds := 5.0

# Anzahl der Gegenstände, die eine Ernte liefert.
@export_range(1, 100, 1) var harvest_amount := 1

# Farben der Pflanze während des Wachstums und nach der Reifung.
@export var planted_color := Color(0.35, 0.65, 0.2)
@export var ready_color := Color(0.9, 0.75, 0.2)

# ID des Saatguts, das zum Pflanzen ausgewählt und verbraucht werden muss.
@export var seed_item_id: StringName
