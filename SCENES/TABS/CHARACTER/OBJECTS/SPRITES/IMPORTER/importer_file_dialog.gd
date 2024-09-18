extends FileDialog

@export var browse_button: Button


func _ready() -> void:
	browse_button.pressed.connect(show)
	files_selected.connect(on_files_selected)


func on_files_selected(files: PackedStringArray) -> void:
	SpriteImport.obj_state = SessionData.object_state_get(
		get_owner().get_parent().name)
	
	SpriteImport.select_files(files)
