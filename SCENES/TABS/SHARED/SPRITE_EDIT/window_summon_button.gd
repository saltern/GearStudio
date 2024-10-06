extends Button

@export var window: Window


func _ready() -> void:
	pressed.connect(window.show)
