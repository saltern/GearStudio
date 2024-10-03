extends FileDialog

@export var export_button: Button

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	export_button.pressed.connect(show)
	dir_selected.connect(on_dir_selected)


func on_dir_selected(path: String) -> void:
	SpriteExport.obj_data = sprite_edit.obj_data
	SpriteExport.export(path)
