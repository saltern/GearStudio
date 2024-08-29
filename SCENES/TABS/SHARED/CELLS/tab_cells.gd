extends MarginContainer


func _ready() -> void:
	SessionData.object_state_get(get_parent().name).cell_load(0)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
		
	if not event is InputEventKey:
		return
		
	if not event.pressed or event.echo:
		return
	
	if Input.is_action_just_pressed("undo"):
		SessionData.undo()
	
	elif Input.is_action_just_pressed("redo"):
		SessionData.redo()
