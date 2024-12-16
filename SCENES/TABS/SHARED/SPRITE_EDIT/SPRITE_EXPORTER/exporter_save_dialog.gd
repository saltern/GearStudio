extends FileDialog

@export var export_button: Button

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	export_button.pressed.connect(display)
	dir_selected.connect(on_dir_selected)


func display() -> void:
	if visible:
		return
	
	current_dir = FileMemory.sprite_sprite_export
	current_file = ""
	show()


func on_dir_selected(path: String) -> void:
	current_path.get_base_dir()
	SpriteExport.obj_data = sprite_edit.obj_data
	SpriteExport.export(path)
	FileMemory.sprite_sprite_export = current_path
