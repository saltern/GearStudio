extends Button

enum Mode {
	HORIZONTAL,
	VERTICAL
}

@export var mode: Mode

@onready var editor: SpriteEditor = owner


func _pressed() -> void:
	match mode:
		Mode.HORIZONTAL:
			editor.control_flip_h()
		Mode.VERTICAL:
			editor.control_flip_v()
