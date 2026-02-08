extends HBoxContainer

@export var object_dropdown: OptionButton
@export var sprite_index: SteppingSpinBox


func _ready() -> void:
	object_dropdown.item_selected.connect(on_object_selected.unbind(1))
	on_object_selected()


func on_object_selected() -> void:
	var id: int = object_dropdown.get_selected_id()
	var session: Dictionary = SessionData.get_current_session()
	var object: Dictionary = session.data[id]
	visible = not object.has("palettes")
	sprite_index.max_value = object.sprites.size() - 1
	sprite_index.value = 0
