extends SteppingSpinBox

enum CoordType {
	X,
	Y,
	WIDTH,
	HEIGHT,
}

@export var coord_type: CoordType


func _ready() -> void:
	match coord_type:
		CoordType.X:
			value = Settings.box_collision.position.x
		CoordType.Y:
			value = Settings.box_collision.position.y
		CoordType.WIDTH:
			value = Settings.box_collision.size.x
		CoordType.HEIGHT:
			value = Settings.box_collision.size.y
