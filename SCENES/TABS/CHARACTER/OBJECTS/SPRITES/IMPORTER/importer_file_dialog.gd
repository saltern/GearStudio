extends FileDialog

@export var browse_button: Button

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	browse_button.pressed.connect(show)
	files_selected.connect(on_files_selected)


func on_files_selected(files: PackedStringArray) -> void:
	SpriteImport.obj_data = sprite_edit.obj_data
	SpriteImport.select_files(files)
