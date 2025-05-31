extends Window

@onready var cell_edit: CellEdit = owner


func _enter_tree() -> void:
	close_requested.connect(hide)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if not event is InputEventKey:
		return
	
	if not event.pressed:
		return
	
	if event.echo:
		return
	
	match event.keycode:
		KEY_ESCAPE:
			hide()
