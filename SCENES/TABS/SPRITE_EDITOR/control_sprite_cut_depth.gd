extends Button

@onready var editor: SpriteEditor = owner


func _pressed() -> void:
	editor.control_cut_depth()
