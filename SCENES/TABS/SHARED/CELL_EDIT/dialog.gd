extends Window

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	title = tr(title).format({ "object": cell_edit.obj_data.name })
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
