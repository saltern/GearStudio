extends CheckButton


func _ready() -> void:
	button_pressed = false
	SessionData.box_set_editing(false)
	
	toggled.connect(SessionData.box_set_editing)
