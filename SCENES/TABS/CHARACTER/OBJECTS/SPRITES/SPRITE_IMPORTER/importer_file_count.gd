extends Label


func _ready() -> void:
	SpriteImport.files_selected.connect(on_files_selected)


func on_files_selected() -> void:
	text = "Will import %s sprites." % SpriteImport.import_list.size()
