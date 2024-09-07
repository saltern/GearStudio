extends Window

@export var export_path_dialog: FileDialog


func _ready() -> void:
	title = "Export '%s' sprites..." % get_owner().get_parent().name

	close_requested.connect(hide)
