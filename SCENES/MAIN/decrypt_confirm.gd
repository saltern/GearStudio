extends ConfirmationDialog

var decryption_path: String
var task_id: int = -1


func _ready() -> void:
	confirmed.connect(on_confirmed)
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if WorkerThreadPool.is_task_completed(task_id):
		WorkerThreadPool.wait_for_task_completion(task_id)
		set_physics_process(false)


func display(path: String) -> void:
	dialog_text = tr("DECRYPTION_CONFIRM_TEXT").format({"path": path})
	decryption_path = path
	grab_focus.call_deferred()
	show()


func fulfill() -> void:
	DirDecrypter.decrypt_folder(decryption_path, GlobalSignals)


func on_confirmed() -> void:
	task_id = WorkerThreadPool.add_task(fulfill)
	set_physics_process(true)
