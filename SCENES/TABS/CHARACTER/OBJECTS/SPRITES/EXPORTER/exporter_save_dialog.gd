extends FileDialog

@export var export_button: Button


func _ready() -> void:
	export_button.pressed.connect(show)
	dir_selected.connect(on_dir_selected)


func on_dir_selected(path: String) -> void:
	SpriteExport.obj_state = SessionData.object_state_get(
		get_owner().get_parent().name)
	
	SpriteExport.pal_state = SessionData.palette_state_get(
		get_owner().get_parent().get_parent().get_index())
	
	SpriteExport.export(path)
