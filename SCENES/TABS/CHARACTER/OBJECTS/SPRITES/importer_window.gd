extends Window

@export var import_path_dialog: FileDialog


func _ready() -> void:
	title = "Import '%s' sprites..." % get_owner().get_parent().name

	close_requested.connect(hide)
