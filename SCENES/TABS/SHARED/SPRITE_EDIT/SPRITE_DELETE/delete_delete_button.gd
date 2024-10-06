extends Button

@export var confirmation_window: ConfirmationDialog


func _ready() -> void:
	pressed.connect(confirmation_window.display)
