extends HSlider

enum EndMode {
	STOP,
	UNK_1,
	UNK_2,
	LOOP,
	JUMP,
	UNK_5,
	UNK_6,
	UNK_7,
	UNK_8,
}

@export var action_spinbox: SteppingSpinBox
@export var button_play_from_start: Button
@export var button_play: Button
@export var button_stop: Button

var playback: bool = false
var end_mode: EndMode = EndMode.STOP

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	min_value = 1
	
	script_edit.action_loaded.connect(update)
	script_edit.action_seek_to_frame.connect(external_seek)
	script_edit.inst_cell_jump.connect(on_cell_jump)
	script_edit.inst_end_action.connect(set_end_mode)
	button_play_from_start.pressed.connect(play_from_start)
	button_play.pressed.connect(play)
	button_stop.pressed.connect(stop)
	value_changed.connect(load_frame)


func _physics_process(_delta: float) -> void:
	if not playback:
		return
	
	if value == max_value:
		if end_mode == EndMode.LOOP:
			value = 0
		else:
			playback = false
			return
	
	value += 1


func reset() -> void:
	value = 1


func update() -> void:
	max_value = script_edit.script_animation_get_length()
	reset()


func external_seek(frame: int) -> void:
	set_value_no_signal(frame)


func set_end_mode(new_mode: int) -> void:
	end_mode = new_mode as EndMode


func load_frame(frame: int) -> void:
	script_edit.script_animation_load_frame(frame)


func play_from_start() -> void:
	reset()
	play()


func play() -> void:
	playback = true


func stop() -> void:
	playback = false


#region Instruction Simulation
func on_cell_jump(index: int) -> void:
	var frame: int = script_edit.script_instruction_get_cell_frame(index)
	value = frame
#endregion
