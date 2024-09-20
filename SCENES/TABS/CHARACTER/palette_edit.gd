class_name PaletteEdit extends MarginContainer

var obj_data: ObjectData
var provider: PaletteProvider = PaletteProvider.new()


func _enter_tree() -> void:
	obj_data = SessionData.object_data_get("player")
	
	provider.sprite_mode = false
	provider.pal_data = SessionData.palette_data_get(get_parent().get_index())
	provider.obj_data = obj_data
	provider.palette_load(0)


func _input(event: InputEvent) -> void:	
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
		
	if not event.pressed or event.echo:
		return
	
	if Input.is_action_just_pressed("undo"):
		provider.undo()
	
	elif Input.is_action_just_pressed("redo"):
		provider.redo()


func get_provider() -> PaletteProvider:
	return provider


#region Sprites/Preview
func sprite_get_count() -> int:
	return obj_data.sprites.size()


func sprite_get(index: int) -> BinSprite:
	return obj_data.sprites[index]
#endregion
