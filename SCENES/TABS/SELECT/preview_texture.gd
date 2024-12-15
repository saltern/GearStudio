extends TextureRect

@onready var select_edit: SelectEdit = owner
@onready var obj_data: Dictionary = select_edit.obj_data


func _get_tooltip(at: Vector2) -> String:
	var width: int = obj_data["select_width"]
	var height: int = obj_data["select_height"]
	var pixel: int = max(0, at.y - 1) * width + int(at.x)
	var value: int = obj_data["select_pixels"][pixel]
	
	return "SELECT_CHAR_%02d" % value
