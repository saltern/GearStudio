extends SteppingSpinBox

enum CoordType {
	X,
	Y,
	WIDTH,
	HEIGHT,
}


@export var coord_type: CoordType


func _ready() -> void:
	value_changed.connect(update)
	
	match coord_type:
		CoordType.X:
			set_value_no_signal(Settings.box_collision.position.x)
		CoordType.Y:
			set_value_no_signal(Settings.box_collision.position.y)
		CoordType.WIDTH:
			set_value_no_signal(Settings.box_collision.size.x)
		CoordType.HEIGHT:
			set_value_no_signal(Settings.box_collision.size.y)


func update(new_value: int) -> void:
	match coord_type:
		CoordType.X:
			Settings.box_collision.position.x = new_value
		CoordType.Y:
			Settings.box_collision.position.y = new_value
		CoordType.WIDTH:
			Settings.box_collision.size.x = new_value
		CoordType.HEIGHT:
			Settings.box_collision.size.y = new_value
