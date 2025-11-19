extends Label

@export var grid_flags: Container


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
		13, 15, 17, 22, 24, 27, 28, 29, 30, 31:
			text = "SCRIPT_EDIT_FLAGS_UNKNOWN"
		_:
			text = "SCRIPT_EDIT_FLAGS_%s" % bit
