extends FileDialog

@export var browse_button: Button

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	browse_button.pressed.connect(on_browse_clicked)
	files_selected.connect(on_files_selected)


func on_browse_clicked() -> void:
	if visible:
		return
	
	show()


func on_files_selected(files: PackedStringArray) -> void:
	SpriteImport.pal_data = sprite_edit.pal_data
	SpriteImport.obj_data = sprite_edit.obj_data
	SpriteImport.select_files(files)
