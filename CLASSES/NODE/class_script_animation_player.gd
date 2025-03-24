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

var provider: Object


func _ready() -> void:
	add_animation_library("", AnimationLibrary.new())


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

	action_loaded.emit()


func load_frame(frame: int) -> void:
	var time = current_animation_position
	
	if frame > time:
		advance(frame - time)
	else:
		# Likely slower, but required by instructions using additive operations
		seek(0, true)
		advance(frame)

	seek_to_frame.emit(frame)
