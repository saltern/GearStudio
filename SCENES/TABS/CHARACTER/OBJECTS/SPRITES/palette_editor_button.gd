extends Button

@export var palette_editor: Window


func _ready() -> void:
	pressed.connect(on_pressed)


func on_pressed() -> void:
	palette_editor.show()
