extends Label

@export var grid_flags: GridContainer


func _ready() -> void:
	for bit in 32:
		var group: int = bit / 8
		var child: int = bit % 8
		var button: Button = grid_flags.get_child(group).get_child(child)
		
		button.mouse_exited.connect(hide_info)
		button.mouse_entered.connect(show_info.bind(bit))
	
	hide_info()


func hide_info() -> void:
	text = "-"
	

func show_info(bit: int) -> void:
	match bit:
		1, 3, 5, 6, 7, 13, 15, 16, 17, 22, 24, 27, 28, 29, 30, 31:
			text = "SCRIPT_EDIT_FLAGS_UNKNOWN"
		_:
			text = "SCRIPT_EDIT_FLAGS_%s" % bit
