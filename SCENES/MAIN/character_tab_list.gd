extends TabContainer

@export var load_dialog: FileDialog
@export var character_scene: PackedScene


func _ready() -> void:
	load_dialog.dir_selected.connect(load_character)


func load_character(path: String) -> void:
	var new_character: Control = character_scene.instantiate()
	new_character.load_from_path(path)
	new_character.name = path.split("\\")[-1]
	add_child(new_character)
