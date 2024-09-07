extends Button

@export var export_window: Window


func _ready() -> void:
	pressed.connect(export_window.show)
