extends TextureRect

@onready var select_edit: SelectEdit = owner
@onready var obj_data: Dictionary = select_edit.obj_data


func _ready() -> void:
	var pal_gray: PackedInt32Array = []
	for index in 256:
		pal_gray.append(index)
		pal_gray.append(index)
		pal_gray.append(index)
		pal_gray.append(0xFF)
	
	material.set_shader_parameter("palette", pal_gray)
	mouse_exited.connect(disable_highlight)


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
	
	$tooltip.text = get_string_at(event.position)
	$tooltip.show()
	$tooltip.position = event.position
	$tooltip.position -= Vector2($tooltip.size.x / 2, $tooltip.size.y)
	
	highlight_index(get_index_at(event.position))


func get_string_at(at: Vector2) -> String:
	var index: int = get_index_at(at)
	
	if index > 0x19 && index < 0xFF:
		return "SELECT_CHAR_INVALID"
	
	return "SELECT_CHAR_%02d" % get_index_at(at)


func get_index_at(at: Vector2) -> int:
	var width: int = obj_data["select_width"]
	var height: int = obj_data["select_height"]
	var pixel: int = max(0, at.y - 1) * width + int(at.x)
	
	return obj_data["select_pixels"][pixel]


func highlight_index(index: int) -> void:
	material.set_shader_parameter("hover_index", index)


func disable_highlight() -> void:
	$tooltip.hide()
	material.set_shader_parameter("hover_index", -1)
