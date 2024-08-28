extends Control

@export var palette_number: SpinBox
@export var color_grid: GridContainer
@export var preview_sprite: TextureRect

var pal_state: PaletteEditState
var obj_state: ObjectEditState


func _enter_tree() -> void:
	pal_state = SessionData.palette_state_get(get_parent().get_index())
	pal_state.load_palette(0)
	
	obj_state = SessionData.object_state_get("player")
	preview_sprite.obj_state = obj_state
	
	palette_number.value_changed.connect(change_palette)
	color_grid.pal_state = pal_state
	preview_sprite.pal_state = pal_state


func change_palette(new_value: int = 0) -> void:
	pal_state.load_palette(new_value)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
		
	if not event is InputEventKey:
		return
		
	if not event.pressed or event.echo:
		return
	
	if Input.is_action_just_pressed("undo"):
		SessionData.undo_pal()
	
	elif Input.is_action_just_pressed("redo"):
		SessionData.redo_pal()
