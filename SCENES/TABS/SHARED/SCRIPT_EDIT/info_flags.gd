extends Label

@export var grid_flags: GridContainer


func _ready() -> void:
	for bit in 32:
		var group: int = bit / 8
		var child: int = bit % 8
		var button: Button = grid_flags.get_child(group).get_child(child)
		
		button.mouse_exited.connect(hide_info)
		button.mouse_entered.connect(show_info.bind(bit))


func hide_info() -> void:
	text = "-"
	

func show_info(bit: int) -> void:
	match bit:
		0:
			text = "Is weak attack"
		2:
			text = "Is special attack"
		4:
			text = "Is sweep"
		8:
			text = "Knocks down"
		9:
			text = "Launches (Dust)"
		10:
			text = "Can be blocked high"
		11:
			text = "Can be blocked low"
		12:
			text = "Can be blocked in the air"
		14:
			text = "Requires FD to air block"
		18:
			text = "Enables fire effect"
		19:
			text = "Enables lightning effect"
		20:
			text = "No hitstop"
		21:
			text = "Reduced hitstop"
		23:
			text = "Seals Burst (both players)"
		25:
			text = "Is Instant Kill"
		26:
			text = "Seals Burst (?)"
		_:
			text = "Unknown"
