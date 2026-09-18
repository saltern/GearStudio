extends Window

@export var label_action: Label
@export var label_current: Label
@export var label_max: Label
@export var progress_bar: ProgressBar

var current: int = 0


func _ready() -> void:
	GlobalSignals.progress_window_start.connect(start)
	GlobalSignals.progress_window_progress.connect(progress)
	GlobalSignals.progress_window_finish.connect(hide)


func start(text: String, count: int = 0) -> void:
	label_action.text = text
	current = 0
	progress_bar.value = 0
	progress_bar.max_value = count
	
	label_current.text = "0"
	label_max.text = "%d" % count
	show()


func progress() -> void:
	current += 1
	label_current.text = "%d" % current
	progress_bar.value = current
