extends Button

@export var window: Window


func _ready() -> void:
	if !window.visible:
		pressed.connect(window.show)
