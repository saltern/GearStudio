extends HSlider

@export var action_spinbox: SteppingSpinBox
@export var button_play_from_start: Button
@export var button_play: Button

var playback: bool = false

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	min_value = 1
	
	script_edit.action_loaded.connect(update)
	button_play_from_start.pressed.connect(play_from_start)
	button_play.pressed.connect(play)
	value_changed.connect(load_frame)


func _physics_process(_delta: float) -> void:
	if not playback:
		return
	
	if value == max_value:
		playback = false
		return
	
	value += 1


func reset() -> void:
	value = 1


func update() -> void:
	max_value = script_edit.script_get_animation_frames()
	reset()


func load_frame(frame: int) -> void:
	script_edit.script_load_frame(frame)


func play_from_start() -> void:
	reset()
	play()


func play() -> void:
	playback = true
