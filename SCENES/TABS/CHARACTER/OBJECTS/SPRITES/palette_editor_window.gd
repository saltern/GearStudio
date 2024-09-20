extends Window

@onready var provider: PaletteProvider = get_owner().get_provider()


func _ready() -> void:
	close_requested.connect(hide)


func _input(event: InputEvent) -> void:	
	if not visible:
		return
	
	if not event is InputEventKey:
		return
		
	if not event.pressed or event.echo:
		return
	
	if Input.is_action_just_pressed("undo"):
		provider.undo()
	
	elif Input.is_action_just_pressed("redo"):
		provider.redo()
