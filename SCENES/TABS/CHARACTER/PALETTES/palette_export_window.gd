extends FileDialog

@export var summon_button: Button

@onready var provider: PaletteProvider = get_owner().provider


func _ready() -> void:
	summon_button.pressed.connect(display)
	file_selected.connect(on_file_selected)
	close_requested.connect(hide)


func display() -> void:
	if visible:
		return
	
	current_path = FileMemory.palette_export
	show()


func on_file_selected(path: String) -> void:
	FileMemory.palette_export = current_path
	
	match path.get_extension().to_lower():
		"bin":
			provider.palette.to_bin_file(path)
		"act":
			provider.palette.to_act_file(path)
