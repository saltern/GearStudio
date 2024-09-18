extends Window


func _ready() -> void:
	SpriteImport.sprite_import_started.connect(on_sprite_import_started)
	SpriteImport.sprite_import_finished.connect(hide)


func on_sprite_import_started(object_name: String) -> void:
	if get_owner().get_parent().name == object_name:
		show()
