extends Button

@export var editor_window: Window


func _ready() -> void:
	pressed.connect(editor_window.show)
