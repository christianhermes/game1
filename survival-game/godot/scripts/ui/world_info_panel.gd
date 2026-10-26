class_name WorldInfoPanel
extends PanelContainer

## Zeigt Informationen des zuletzt angeklickten Weltobjekts. Das Ziel liefert
## Titel und Inhalt selbst, damit dieses UI keine konkreten Objektklassen kennen
## muss und später ohne Umbau um neue Gebäude oder NPCs erweitert werden kann.

@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var details_label: Label = $Margin/VBox/DetailsLabel

var current_target: Node


func _ready() -> void:
	visible = false


func _process(_delta: float) -> void:
	if not visible:
		return
	if not is_instance_valid(current_target) or current_target.is_queued_for_deletion():
		close_panel()
		return

	_refresh_content()


## Öffnet das Fenster nur für Nodes, die die gemeinsame Informationsschnittstelle
## vollständig anbieten. Der Rückgabewert zeigt, ob das Ziel angezeigt wurde.
func show_target(target: Node) -> bool:
	if (
		target == null
		or not target.has_method("get_world_info_title")
		or not target.has_method("get_world_info_text")
	):
		close_panel()
		return false

	current_target = target
	visible = true
	_refresh_content()
	return true


func close_panel() -> void:
	current_target = null
	visible = false


func _refresh_content() -> void:
	title_label.text = str(current_target.call("get_world_info_title"))
	details_label.text = str(current_target.call("get_world_info_text"))
