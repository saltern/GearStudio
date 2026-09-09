extends Window


func _ready() -> void:
	close_requested.connect(hide)


func _input(event: InputEvent) -> void:
	if !visible:
		return
	
	if event is InputEventKey:
		match event.keycode:
			KEY_ESCAPE:
				hide()
