extends Window

@export var label_current: Label
@export var label_max: Label
@export var progress_bar: ProgressBar

var current: int = 0


func start(from: int, to: int) -> void:
	current = 0
	var max_item: int = to - from + 1
	
	progress_bar.max_value = max_item
	
	label_current.text = "0"
	label_max.text = "%d" % max_item
	show()


func progress() -> void:
	current += 1
	label_current.text = "%d" % current
	progress_bar.value = current
	
	if current >= progress_bar.max_value:
		finish()
	

func finish() -> void:
	hide()
