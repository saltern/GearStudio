extends HBoxContainer

@export var object_dropdown: OptionButton
@export var sprite_index: SteppingSpinBox


func _ready() -> void:
	object_dropdown.item_selected.connect(on_object_selected.unbind(1))
	on_object_selected()


func on_object_selected() -> void:
	var id: int = object_dropdown.get_selected_id()
	var session: Session = SessionData.get_current_session()
	var object: BinObject = session.archive.get_object(id)
	visible = true
	
	if object is BinScriptable && object.has_palettes():
		visible = false
	
	sprite_index.max_value = object.sprites.get_sprite_count() - 1
	sprite_index.value = 0
