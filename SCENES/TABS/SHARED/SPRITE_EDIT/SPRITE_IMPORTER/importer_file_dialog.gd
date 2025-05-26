extends FileDialog

@export var browse_button: Button

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	browse_button.pressed.connect(on_browse_clicked)
	files_selected.connect(on_files_selected)


func on_browse_clicked() -> void:
	if visible:
		return
	
	current_path = FileMemory.sprite_sprite_import
	show()


func on_files_selected(files: PackedStringArray) -> void:
	FileMemory.sprite_sprite_import = current_path
