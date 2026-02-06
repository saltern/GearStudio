extends Window


func _ready() -> void:
	GlobalSignals.save_start.connect(display)
	GlobalSignals.save_complete.connect(hide)
	GlobalSignals.save_object.connect(object)
	GlobalSignals.save_sub_object.connect(sub_object)


func display() -> void:
	$content/step.text = ""
	$content/sub.text = ""
	show()


func object(obj_name: String) -> void:
	$content/step.text = tr("SAVE_PROGRESS_OBJECT").format({"object": obj_name})


func sub_object(sub_obj_name: String) -> void:
	$content/sub.text = sub_obj_name
