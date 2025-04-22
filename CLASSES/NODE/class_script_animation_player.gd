class_name ScriptAnimationPlayer extends AnimationPlayer

signal cell_clear
signal action_loaded
signal seek_to_frame

@warning_ignore_start("unused_signal")
signal inst_cell
signal inst_semitrans
signal inst_scale
signal inst_rotate
signal inst_draw_normal
signal inst_draw_reverse
signal inst_cell_jump
signal inst_visual
signal inst_end_action
@warning_ignore_restore("unused_signal")

@export var reference_mode: bool = false

var provider: Object

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	add_animation_library("", AnimationLibrary.new())
	
	if reference_mode:
		provider.ref_data_set.connect(on_ref_data_set.unbind(1))
		provider.ref_data_cleared.connect(on_ref_data_cleared)


func on_ref_data_set() -> void:
	load_action(script_edit.action_index)
	load_frame(script_edit.script_animation_get_current_frame())


func on_ref_data_cleared() -> void:
	stop()
	cell_clear.emit()


func load_action(index: int) -> void:
	if provider.obj_data.is_empty():
		return
	
	if provider.obj_data.scripts.actions.size() <= index:
		cell_clear.emit()
		action_loaded.emit()
		return
	
	var action: ScriptAction = provider.obj_data.scripts.actions[index]
	var anim: Animation = action.get_animation()
	
	# Restart animation
	if anim.track_get_key_count(0) == 0:
		cell_clear.emit()

	var library: AnimationLibrary = get_animation_library("")
	library.add_animation(&"anim", anim)
	play(&"anim")

	action_loaded.emit()


func load_frame(frame: int) -> void:
	if assigned_animation == "" or current_animation == "":
		return
	
	if frame > current_animation_length:
		cell_clear.emit()
		return
	
	var time = current_animation_position
	
	if frame > time:
		advance(frame - time)
	else:
		# Likely slower, but required by instructions using additive operations
		seek(0, true)
		advance(frame)

	seek_to_frame.emit(frame)
