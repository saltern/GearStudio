extends HBoxContainer

@export var object_dropdown: OptionButton
@export var palette_index: SteppingSpinBox


func _ready() -> void:
	object_dropdown.item_selected.connect(on_object_selected.unbind(1))
	on_object_selected()


func on_object_selected() -> void:
	var id: int = object_dropdown.get_selected_id()
	var session: Dictionary = SessionData.get_current_session()
	var object: Dictionary = session.data[id]
	visible = object.has("palettes")
	if not object.has("palettes"):
		return
	
	palette_index.max_value = object.palettes.size() - 1
