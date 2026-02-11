extends CheckButton


func _ready() -> void:
	button_pressed = Settings.box_collision_default


func _toggled(toggled_on: bool) -> void:
	Settings.box_collision_default = button_pressed
